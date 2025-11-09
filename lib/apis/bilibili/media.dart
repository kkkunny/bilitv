import 'package:bilitv/models/pbs/dm.pb.dart';
import 'package:bilitv/models/video.dart' show VideoPlayInfo, Video;
import 'package:dio/dio.dart';

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
  final data = await bilibiliRequest(
    'GET',
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
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/web-interface/view',
    queryParameters: queryParams,
  );
  return Video.fromJson(data);
}

class ArchiveRelation {
  bool like;
  bool dislike;
  bool favorite;
  bool inPlayList;
  int coin;
  bool seasonFav;

  ArchiveRelation({
    this.like = false,
    this.dislike = false,
    this.favorite = false,
    this.inPlayList = false,
    this.coin = 0,
    this.seasonFav = false,
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
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/web-interface/archive/relation',
    queryParameters: queryParams,
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
