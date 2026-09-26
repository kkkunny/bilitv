import 'package:bilitv/models/video.dart';
import 'package:flutter_test/flutter_test.dart';

// 搜索接口的video结果：id字段是aid，不包含cid
Map<String, dynamic> _searchVideoJson() => {
  'type': 'video',
  'id': 170001,
  'aid': 170001,
  'bvid': 'BV17x411w7KC',
  'title': '测试<em class="keyword">视频</em>标题',
  'pic': '//i0.hdslb.com/bfs/archive/cover.jpg',
  'duration': '1:02:03',
  'mid': 123,
  'author': '测试UP主',
  'upic': '//i0.hdslb.com/bfs/face/avatar.jpg',
  'pubdate': 1700000000,
};

void main() {
  group('MediaCardInfo.fromSearchJson', () {
    test('不把id(aid)当作cid', () {
      final video = MediaCardInfo.fromSearchJson(_searchVideoJson());

      expect(video.cid, isNull);
      expect(video.avid, 170001);
      expect(video.bvid, 'BV17x411w7KC');
    });

    test('解析时长与去除标题高亮标签', () {
      final video = MediaCardInfo.fromSearchJson(_searchVideoJson());

      expect(video.duration, const Duration(hours: 1, minutes: 2, seconds: 3));
      expect(video.title, '测试视频标题');
    });
  });
}
