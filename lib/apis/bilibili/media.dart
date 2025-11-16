import 'package:bilitv/models/pbs/dm.pb.dart';
import 'package:bilitv/models/video.dart' show VideoPlayInfo, Video;
import 'package:bilitv/storages/cookie.dart' show loadCookie;
import 'package:dio/dio.dart';

import 'client.dart';
import 'dynamic.dart';

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
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/player/wbi/playurl',
    queries: queryParams,
  );
  final List<VideoPlayInfo> videos = [];
  for (final item in data['durl']) {
    videos.add(VideoPlayInfo.fromJson(item));
  }
  return videos;
}

// 获取视频信息
Future<Video> getVideoInfo({int? avid, String? bvid}) async {
  Map<String, dynamic> queryParams = {};
  if (avid != null) {
    queryParams['aid'] = avid;
  } else {
    queryParams['bvid'] = bvid;
  }
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/web-interface/view',
    queries: queryParams,
  );
  return Video.fromJson(data);
}

class ArchiveRelation {
  bool like;
  bool dislike;
  bool favorite;
  int coin;
  bool seasonFav;

  ArchiveRelation({
    this.like = false,
    this.dislike = false,
    this.favorite = false,
    this.coin = 0,
    this.seasonFav = false,
  });

  factory ArchiveRelation.fromJson(Map<String, dynamic> json) {
    return ArchiveRelation(
      like: json['like'],
      dislike: json['dislike'],
      favorite: json['favorite'],
      coin: json['coin'],
      seasonFav: json['season_fav'],
    );
  }
}

// 获取视频关系
Future<ArchiveRelation> getArchiveRelation({int? avid, String? bvid}) async {
  Map<String, dynamic> queryParams = {};
  if (avid != null) {
    queryParams['aid'] = avid;
  } else {
    queryParams['bvid'] = bvid;
  }
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/web-interface/archive/relation',
    queries: queryParams,
  );
  return ArchiveRelation.fromJson(data);
}

// 获取弹幕
Future<DmSegMobileReply> getDanmaku(int cid, int segmentIndex) async {
  Map<String, dynamic> queryParams = {
    'type': 1,
    'oid': cid,
    'segment_index': segmentIndex,
  };
  final response = await bilibiliHttpClient.get(
    'https://api.bilibili.com/x/v2/dm/web/seg.so',
    queryParameters: queryParams,
    options: Options(responseType: ResponseType.bytes),
  );
  return DmSegMobileReply.fromBuffer(response.data);
}

// // 点赞
// // 该接口会报-403 账号异常,操作失败 https://github.com/SocialSisterYi/bilibili-API-collect/issues/1251
// Future<void> likeMedia({int? avid, String? bvid, required bool like}) async {
//   final csrf = (await loadCookie())
//       .firstWhere((c) => c.name == 'bili_jct')
//       .value;
//   Map<String, dynamic> body = {'like': like ? 1 : 2, 'csrf': csrf};
//   if (avid != null) {
//     body['aid'] = avid;
//   } else {
//     body['bvid'] = bvid;
//   }
//   await bilibiliRequest(
//     'POST',
//     'https://api.bilibili.com/x/web-interface/archive/like',
//     contentType: Headers.formUrlEncodedContentType,
//     body: body,
//   );
// }

// 点赞
Future<void> likeMedia(int avid, {required bool like}) async {
  final dynamicId = await avidToDynamicId(avid);

  final csrf = (await loadCookie())
      .firstWhere((c) => c.name == 'bili_jct')
      .value;
  await bilibiliRequest(
    'POST',
    "https://api.bilibili.com/x/dynamic/feed/dyn/thumb",
    contentType: Headers.jsonContentType,
    queries: {'csrf': csrf},
    body: {'dyn_id_str': dynamicId, 'up': like ? 1 : 2},
  );
}

// 投币
Future<void> insertCoin({
  int? avid,
  String? bvid,
  int count = 1,
  bool like = false,
}) async {
  final csrf = (await loadCookie())
      .firstWhere((c) => c.name == 'bili_jct')
      .value;
  Map<String, dynamic> body = {
    'multiply': count,
    'select_like': like ? 1 : 0,
    'csrf': csrf,
  };
  if (avid != null) {
    body['aid'] = avid;
  } else {
    body['bvid'] = bvid;
  }
  await bilibiliRequest(
    'POST',
    'https://api.bilibili.com/x/web-interface/coin/add',
    contentType: Headers.formUrlEncodedContentType,
    body: body,
  );
}
