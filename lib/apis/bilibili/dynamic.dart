import 'package:bilitv/models/video.dart';

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

class ListDynamicResponse {
  final bool hasMore;
  final List<MediaCardInfo> medias;
  final int offset;

  ListDynamicResponse({
    required this.hasMore,
    required this.medias,
    required this.offset,
  });

  factory ListDynamicResponse.fromJson(Map<String, dynamic> json) {
    return ListDynamicResponse(
      hasMore: json['has_more'],
      medias: ((json['items'] ?? []) as List<dynamic>)
          .map((e) => MediaCardInfo.fromDynamicJson(e))
          .toList(),
      offset: int.parse(json['offset']),
    );
  }
}

// 拉取动态
Future<ListDynamicResponse> listDynamic(int offset) async {
  final Map<String, dynamic> queries = {'type': 'video'};
  if (offset > 0) {
    queries['offset'] = offset;
  }
  final data = await bilibiliRequest(
    'GET',
    "https://api.bilibili.com/x/polymer/web-dynamic/v1/feed/all",
    queries: queries,
  );
  return ListDynamicResponse.fromJson(data);
}
