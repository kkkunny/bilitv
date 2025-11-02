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
      avid: json['id'] ?? (json['aid'] ?? 0),
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

// 视频信息
class VideoInfo {
  final int avid;
  final String bvid;
  final int cid;
  final String title;
  final String cover;
  final String desc;
  final Duration duration;
  final int favoriteCount;
  final int likeCount;
  final int dislikeCount;
  final int coinCount;
  final int shareCount;
  final String userName;
  final String userAvatar;
  final DateTime publishTime;

  VideoInfo({
    required this.avid,
    required this.bvid,
    required this.cid,
    required this.title,
    required this.cover,
    required this.desc,
    required this.duration,
    required this.favoriteCount,
    required this.likeCount,
    required this.dislikeCount,
    required this.coinCount,
    required this.shareCount,
    required this.userName,
    required this.userAvatar,
    required this.publishTime,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      avid: json['aid'] ?? 0,
      bvid: json['bvid'] ?? '',
      cid: json['cid'] ?? 0,
      title: json['title'] ?? '',
      cover: json['pic'] ?? '',
      desc: json['desc'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
      favoriteCount: json['stat']['favorite'] ?? 0,
      likeCount: json['stat']['like'] ?? 0,
      dislikeCount: json['stat']['dislike'] ?? 0,
      coinCount: json['stat']['coin'] ?? 0,
      shareCount: json['stat']['share'] ?? 0,
      userName: json['owner']['name'] ?? '',
      userAvatar: json['owner']['face'] ?? '',
      publishTime: DateTime.fromMillisecondsSinceEpoch(
        (json['pubdate'] ?? DateTime.timestamp()) *
            Duration.millisecondsPerSecond,
      ),
    );
  }
}
