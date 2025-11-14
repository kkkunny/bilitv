import 'package:bilitv/storages/cookie.dart' show loadCookie, loginInfoNotifier;
import 'package:dio/dio.dart';

import 'client.dart';

class MediaPlayInfo {
  final int lastPlayCid;
  final Duration lastPlayTime;
  final int onlineCount; // 当前在线人数

  MediaPlayInfo({
    required this.lastPlayCid,
    required this.lastPlayTime,
    required this.onlineCount,
  });

  factory MediaPlayInfo.fromJson(Map<String, dynamic> json) {
    return MediaPlayInfo(
      lastPlayCid: json['last_play_cid'] ?? 0,
      lastPlayTime: Duration(milliseconds: json['last_play_time'] ?? 0),
      onlineCount: json['online_count'] ?? 0,
    );
  }
}

// 获取播放信息
Future<MediaPlayInfo> getMediaPlayInfo({
  int? avid,
  String? bvid,
  required int cid,
}) async {
  Map<String, dynamic> queryParams = {'cid': cid};
  if (avid != null) {
    queryParams['aid'] = avid;
  } else {
    queryParams['bvid'] = bvid;
  }
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/player/v2',
    queries: queryParams,
  );
  return MediaPlayInfo.fromJson(data);
}

// 上报播放开始
Future<void> reportPlayStart(int? avid, int cid) async {
  final Map<String, dynamic> body = {'aid': avid, 'cid': cid};
  if (loginInfoNotifier.value.isLogin) {
    final csrf = (await loadCookie())
        .firstWhere((c) => c.name == 'bili_jct')
        .value;
    body['mid'] = loginInfoNotifier.value.mid;
    body['csrf'] = csrf;
  }
  await bilibiliRequest(
    'POST',
    'https://api.bilibili.com/x/click-interface/click/web/h5',
    contentType: Headers.formUrlEncodedContentType,
    body: body,
  );
}

// 上报播放进度
Future<void> reportPlayProgress(int? avid, int cid, Duration progress) async {
  final csrf = (await loadCookie())
      .firstWhere((c) => c.name == 'bili_jct')
      .value;
  Map<String, dynamic> queryParams = {
    'aid': avid,
    'cid': cid,
    'csrf': csrf,
    'progress': progress.inSeconds,
  };
  await bilibiliRequest(
    'POST',
    'https://api.bilibili.com/x/v2/history/report',
    queries: queryParams,
  );
}

// 播放心跳
Future<void> reportPlayHeartbeat({
  int? avid,
  String? bvid,
  required int cid,
  required Duration progress,
}) async {
  final csrf = (await loadCookie())
      .firstWhere((c) => c.name == 'bili_jct')
      .value;
  Map<String, dynamic> body = {
    'mid': loginInfoNotifier.value.mid,
    'cid': cid,
    'csrf': csrf,
    'played_time': progress.inSeconds,
  };
  if (avid != null) {
    body['aid'] = avid;
  } else {
    body['bvid'] = bvid;
  }
  await bilibiliRequest(
    'POST',
    'https://api.bilibili.com/x/click-interface/web/heartbeat',
    contentType: Headers.formUrlEncodedContentType,
    body: body,
  );
}
