import 'package:bilitv/storages/cookie.dart' show loadCookie, loginInfoNotifier;

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
    queryParameters: queryParams,
  );
  return MediaPlayInfo.fromJson(data);
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
    queryParameters: queryParams,
  );
}
