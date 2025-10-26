enum MediaType {
  unknown,
  video, // 视频
  live, // 直播
  ogv, // 边栏
}

// 媒体卡片信息
class MediaCardInfo {
  final MediaType type;
  final int avid;
  final String bvid;
  final int cid;
  final String title;
  final String cover;
  final Duration duration;
  final int viewCount;
  final int likeCount;
  final int danmakuCount;
  final String userName;
  final String userAvatar;
  final DateTime publishTime;

  MediaCardInfo({
    required this.type,
    required this.avid,
    required this.bvid,
    required this.cid,
    required this.title,
    required this.cover,
    required this.duration,
    required this.viewCount,
    required this.likeCount,
    required this.danmakuCount,
    required this.userName,
    required this.userAvatar,
    required this.publishTime,
  });

  factory MediaCardInfo.fromJson(Map<String, dynamic> json) {
    return MediaCardInfo(
      type: json['goto'] == 'av'
          ? MediaType.video
          : (json['goto'] == 'live'
                ? MediaType.live
                : (json['goto'] == 'ogv' ? MediaType.ogv : MediaType.unknown)),
      avid: json['id'] ?? 0,
      bvid: json['bvid'] ?? '',
      cid: json['cid'] ?? 0,
      title: json['title'] ?? '',
      cover: json['pic'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
      viewCount: json['stat']['view'] ?? 0,
      likeCount: json['stat']['like'] ?? 0,
      danmakuCount: json['stat']['danmaku'] ?? 0,
      userName: json['owner']['name'] ?? '',
      userAvatar: json['owner']['face'] ?? '',
      publishTime: DateTime.fromMillisecondsSinceEpoch(
        (json['pubdate'] ?? DateTime.timestamp()) *
            Duration.millisecondsPerSecond,
      ),
    );
  }
}

class VideoPlayInfo {
  final int order;
  final Duration length;
  final int size; // byte
  final List<String> urls;

  VideoPlayInfo({
    required this.order,
    required this.length,
    required this.size,
    required this.urls,
  });

  factory VideoPlayInfo.fromJson(Map<String, dynamic> json) {
    List<String> urls = [];
    final url = json['url'] ?? "";
    if (url == "") {
      urls.add(url);
    }
    urls.addAll((json['backup_url'] ?? []).cast<String>());
    return VideoPlayInfo(
      order: json['order'] ?? 0,
      length: Duration(milliseconds: json['length'] ?? 0),
      size: json['size'] ?? 0,
      urls: urls,
    );
  }
}
