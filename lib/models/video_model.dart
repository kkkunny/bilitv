class VideoModel {
  final String id;
  final String title;
  final String description;
  final String thumbnail;
  final String duration;
  final String viewCount;
  final String danmakuCount;
  final String userName;
  final String userAvatar;
  final DateTime publishTime;

  VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnail,
    required this.duration,
    required this.viewCount,
    required this.danmakuCount,
    required this.userName,
    required this.userAvatar,
    required this.publishTime,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      duration: json['duration'] ?? '',
      viewCount: json['viewCount'] ?? '',
      danmakuCount: json['danmakuCount'] ?? '',
      userName: json['userName'] ?? '',
      userAvatar: json['userAvatar'] ?? '',
      publishTime: DateTime.parse(
        json['publishTime'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'thumbnail': thumbnail,
      'duration': duration,
      'viewCount': viewCount,
      'danmakuCount': danmakuCount,
      'userName': userName,
      'userAvatar': userAvatar,
      'publishTime': publishTime.toIso8601String(),
    };
  }
}
