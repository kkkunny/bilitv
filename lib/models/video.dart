class VideoCardInfo {
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

  VideoCardInfo({
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

  factory VideoCardInfo.fromJson(Map<String, dynamic> json) {
    return VideoCardInfo(
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
