import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/storages/cookie.dart' show loadCookie;
import 'package:dio/dio.dart' show Headers;

import 'client.dart';

// 获取稍后再看列表
Future<List<MediaCardInfo>> listToView({int count = 30, int page = 1}) async {
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/v2/history/toview/web',
    queries: {'pn': page, 'ps': count, 'viewed': 0, 'asc': false},
  );
  return ((data['list'] ?? []) as List<dynamic>)
      .map((item) => MediaCardInfo.fromToViewJson(item))
      .toList();
}

// 添加到稍后再看
Future<void> addToView({int? avid, String? bvid}) async {
  final csrf = (await loadCookie())
      .firstWhere((c) => c.name == 'bili_jct')
      .value;
  Map<String, dynamic> body = {'csrf': csrf};
  if (avid != null) {
    body['aid'] = avid;
  } else {
    body['bvid'] = bvid;
  }
  await bilibiliRequest(
    'POST',
    'https://api.bilibili.com/x/v2/history/toview/add',
    contentType: Headers.formUrlEncodedContentType,
    body: body,
  );
}

// 从稍后再看中删除
Future<void> deleteToView(int avid) async {
  final csrf = (await loadCookie())
      .firstWhere((c) => c.name == 'bili_jct')
      .value;
  await bilibiliRequest(
    'POST',
    'https://api.bilibili.com/x/v2/history/toview/del',
    contentType: Headers.formUrlEncodedContentType,
    body: {'aid': avid, 'csrf': csrf},
  );
}
