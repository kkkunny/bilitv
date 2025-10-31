import 'dart:convert' show utf8;
import 'dart:io' show Cookie;

import 'package:bilitv/models/video.dart'
    show MediaCardInfo, MediaType, VideoPlayInfo, VideoInfo;
import 'package:bilitv/storages/cookie.dart' show loadCookie;
import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'dart:collection' show SplayTreeMap;

final Dio bilibiliHttpClient = () {
  final client = Dio(
    BaseOptions(
      headers: {
        'Referer': 'https://www.bilibili.com/',
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0',
      },
    ),
  );

  // cookie自动加载
  client.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final cookie = await loadCookie();
        if (cookie.isNotEmpty) {
          options.headers['Cookie'] = cookie;
        }
        return handler.next(options);
      },
    ),
  );

  return client;
}();

// ******************* 鉴权 *******************

const noLoginError = AuthError(1, '未登录');

class AuthError implements Exception {
  final int code;
  final String message;
  const AuthError(this.code, this.message);
}

class QR {
  final String key;
  final String url;
  final Duration expire;

  QR({
    required this.key,
    required this.url,
    this.expire = const Duration(minutes: 3),
  });

  factory QR.fromJson(Map<String, dynamic> json) {
    return QR(key: json['qrcode_key'], url: json['url']);
  }
}

Future<QR> createQR() async {
  final response = await bilibiliHttpClient.get(
    'https://passport.bilibili.com/x/passport-login/web/qrcode/generate',
  );
  if (response.statusCode != 200) {
    throw Exception(
      'http error, code=${response.statusCode}, msg=${response.data}',
    );
  }
  final data = response.data as Map<String, dynamic>;
  if (data['code'] != 0) {
    throw Exception(
      'bilibili api error, code=${data['code']}, msg=${data['message']}',
    );
  }

  return QR.fromJson(data['data']);
}

enum QRState { waiting, scanned, confirmed, expired, error }

class QRStatus {
  final QRState state;
  final String? refreshToken;
  late List<Cookie> cookies;

  QRStatus({required this.state, this.refreshToken, this.cookies = const []});

  factory QRStatus.fromJson(Map<String, dynamic> json) {
    switch (json['code']) {
      case 0:
        return QRStatus(
          state: QRState.confirmed,
          refreshToken: json['refresh_token'],
        );
      case 86038:
        return QRStatus(state: QRState.expired);
      case 86090:
        return QRStatus(state: QRState.scanned);
      case 86101:
        return QRStatus(state: QRState.waiting);
      default:
        throw Exception(
          'bilibili api error, code=${json['code']}, msg=${json['message']}',
        );
    }
  }
}

Future<QRStatus> checkQRStatus(String key) async {
  final response = await bilibiliHttpClient.get(
    'https://passport.bilibili.com/x/passport-login/web/qrcode/poll',
    queryParameters: {'qrcode_key': key},
  );
  if (response.statusCode != 200) {
    throw Exception(
      'http error, code=${response.statusCode}, msg=${response.data}',
    );
  }
  final data = response.data as Map<String, dynamic>;
  if (data['code'] != 0) {
    throw Exception(
      'bilibili api error, code=${data['code']}, msg=${data['message']}',
    );
  }

  var qrStatus = QRStatus.fromJson(data['data']);
  if (qrStatus.state == QRState.confirmed) {
    qrStatus.cookies = response.headers['set-cookie']!.map((cookie) {
      return Cookie.fromSetCookieValue(cookie);
    }).toList();
  }
  return qrStatus;
}

// APP 签名
Map<String, dynamic> appSign(
  Map<String, dynamic> params,
  String appKey,
  String appSec,
) {
  params = Map.from(params);
  params['appkey'] = appKey;
  final sortParams = SplayTreeMap<String, dynamic>.from(
    params,
    (key1, key2) => key1.compareTo(key2),
  );
  final query = Uri.encodeFull(
    sortParams.keys
        .map((String key) {
          return '$key=${sortParams[key]}';
        })
        .join('&'),
  );
  final sign = crypto.md5.convert(utf8.encode(query + appSec)).toString();
  params['sign'] = sign;
  return params;
}

// ******************* 推荐 *******************

// 获取推荐视频
Future<List<MediaCardInfo>> fetchRecommendVideos({
  int freshType = 4,
  int count = 30,
  int page = 1,
  List<int> removeAvids = const [],
}) async {
  final response = await bilibiliHttpClient.get(
    'https://api.bilibili.com/x/web-interface/wbi/index/top/feed/rcmd',
    queryParameters: {
      'fresh_type': freshType,
      'ps': count,
      'fresh_idx': page,
      'last_show_list': removeAvids.map((v) => 'av_$v').join(','),
    },
  );
  if (response.statusCode != 200) {
    throw Exception(
      'http error, code=${response.statusCode}, msg=${response.data}',
    );
  }
  final data = response.data as Map<String, dynamic>;
  if (data['code'] != 0) {
    throw Exception(
      'bilibili api error, code=${data['code']}, msg=${data['message']}',
    );
  }

  final List<MediaCardInfo> videos = [];
  for (final item in data['data']['item']) {
    // 过滤掉非视频媒体
    final media = MediaCardInfo.fromJson(item);
    if (media.type != MediaType.video) {
      continue;
    }
    videos.add(media);
  }
  return videos;
}

// 获取相关视频
Future<List<MediaCardInfo>> fetchRelatedVideos({
  int? avid,
  String? bvid,
}) async {
  Map<String, dynamic> queryParams = {};
  if (avid != null) {
    queryParams['aid'] = avid;
  } else {
    queryParams['bvid'] = bvid;
  }
  final response = await bilibiliHttpClient.get(
    'https://api.bilibili.com/x/web-interface/archive/related',
    queryParameters: queryParams,
  );
  if (response.statusCode != 200) {
    throw Exception(
      'http error, code=${response.statusCode}, msg=${response.data}',
    );
  }
  final data = response.data as Map<String, dynamic>;
  if (data['code'] != 0) {
    throw Exception(
      'bilibili api error, code=${data['code']}, msg=${data['message']}',
    );
  }

  final List<MediaCardInfo> videos = [];
  for (final item in data['data']) {
    videos.add(MediaCardInfo.fromJson(item));
  }
  return videos;
}

// ******************* 用户 *******************

class MySelf {
  final String name;
  final String avatar;
  final int level;

  MySelf({required this.name, required this.avatar, required this.level});

  factory MySelf.fromJson(Map<String, dynamic> json) {
    return MySelf(
      name: json['uname'] ?? '',
      avatar: json['face'] ?? '',
      level: json['level_info']['current_level'] ?? 0,
    );
  }
}

Future<MySelf> getMySelfInfo() async {
  final response = await bilibiliHttpClient.get(
    'https://api.bilibili.com/x/web-interface/nav',
  );
  if (response.statusCode != 200) {
    throw Exception(
      'http error, code=${response.statusCode}, msg=${response.data}',
    );
  }
  final data = response.data as Map<String, dynamic>;
  if (data['code'] == -101) {
    throw noLoginError;
  } else if (data['code'] != 0) {
    throw Exception(
      'bilibili api error, code=${data['code']}, msg=${data['message']}',
    );
  }

  return MySelf.fromJson(data['data']);
}

// ******************* 视频 *******************

// 获取视频播放地址
Future<List<VideoPlayInfo>> getVideoPlayURL({
  int? avid,
  String? bvid,
  required int cid,
  int quality = 32,
}) async {
  Map<String, dynamic> queryParams = {'cid': cid, 'qn': quality};
  if (avid != null) {
    queryParams['avid'] = avid;
  } else {
    queryParams['bvid'] = bvid;
  }
  final response = await bilibiliHttpClient.get(
    'https://api.bilibili.com/x/player/wbi/playurl',
    queryParameters: queryParams,
  );
  if (response.statusCode != 200) {
    throw Exception(
      'http error, code=${response.statusCode}, msg=${response.data}',
    );
  }
  final data = response.data as Map<String, dynamic>;
  if (data['code'] != 0) {
    throw Exception(
      'bilibili api error, code=${data['code']}, msg=${data['message']}',
    );
  }

  final List<VideoPlayInfo> videos = [];
  for (final item in data['data']['durl']) {
    videos.add(VideoPlayInfo.fromJson(item));
  }
  return videos;
}

// 获取视频信息
Future<VideoInfo> getVideoInfo({int? avid, String? bvid}) async {
  Map<String, dynamic> queryParams = {};
  if (avid != null) {
    queryParams['aid'] = avid;
  } else {
    queryParams['bvid'] = bvid;
  }
  final response = await bilibiliHttpClient.get(
    'https://api.bilibili.com/x/web-interface/view',
    queryParameters: queryParams,
  );
  if (response.statusCode != 200) {
    throw Exception(
      'http error, code=${response.statusCode}, msg=${response.data}',
    );
  }
  final data = response.data as Map<String, dynamic>;
  if (data['code'] != 0) {
    throw Exception(
      'bilibili api error, code=${data['code']}, msg=${data['message']}',
    );
  }

  return VideoInfo.fromJson(data['data']);
}
