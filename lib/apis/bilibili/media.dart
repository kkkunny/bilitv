import 'package:bilitv/models/video.dart' show VideoPlayInfo, Video;

import 'client.dart';

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
  final data = await bilibiliGet(
    'https://api.bilibili.com/x/player/wbi/playurl',
    queryParameters: queryParams,
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
  final data = await bilibiliGet(
    'https://api.bilibili.com/x/web-interface/view',
    queryParameters: queryParams,
  );
  return Video.fromJson(data);
}

class ArchiveRelation {
  final bool like;
  final bool dislike;
  final bool favorite;
  final bool inPlayList;
  final int coin;
  final bool seasonFav;

  ArchiveRelation({
    required this.like,
    required this.dislike,
    required this.favorite,
    required this.inPlayList,
    required this.coin,
    required this.seasonFav,
  });

  factory ArchiveRelation.fromJson(Map<String, dynamic> json) {
    return ArchiveRelation(
      like: json['like'],
      dislike: json['dislike'],
      favorite: json['favorite'],
      inPlayList: json['attention'],
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
  final data = await bilibiliGet(
    'https://api.bilibili.com/x/web-interface/archive/relation',
    queryParameters: queryParams,
  );
  return ArchiveRelation.fromJson(data);
}
