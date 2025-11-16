import 'client.dart';

// 稿件id转动态id
Future<String> avidToDynamicId(int avid) async {
  final data = await bilibiliRequest(
    'GET',
    "https://api.bilibili.com/x/polymer/web-dynamic/v1/detail",
    queries: {'rid': avid, 'type': 8},
  );
  return data['item']['id_str'];
}
