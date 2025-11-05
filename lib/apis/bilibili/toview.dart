import 'package:bilitv/models/video.dart' show MediaCardInfo;

import 'client.dart';

// 获取稍后再看列表
Future<List<MediaCardInfo>> listToView() async {
  final data = await bilibiliGet(
    'https://api.bilibili.com/x/v2/history/toview',
  );
  return ((data['list'] ?? []) as List<dynamic>)
      .map((item) => MediaCardInfo.fromJson(item))
      .toList();
}
