enum MediaType {
  unknown,
  video, // 视频
  live, // 直播
  ogv, // 边栏
}

// 播放进度
class PlayProgress {
  final int progress; // 播放时长秒数

  PlayProgress(this.progress);

  factory PlayProgress.fromJson(Map<String, dynamic> json) {
    return PlayProgress(json['progress'] ?? 0);
  }

  bool finished() => progress < 0;

  Duration duration() => Duration(seconds: progress);
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
  final PlayProgress? progress;
  final Stat? stat;
  final int userMid;
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
    this.progress,
    this.stat,
    required this.userMid,
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
      avid: json['aid'] ?? json['id'],
      bvid: json['bvid'],
      cid: json['cid'],
      title: json['title'],
      cover: json['pic'],
      duration: Duration(seconds: json['duration']),
      progress: json['progress'] == null ? null : PlayProgress.fromJson(json),
      stat: Stat.fromJson(json['stat'] ?? {}),
      userMid: json['owner']['mid'],
      userName: json['owner']['name'],
      userAvatar: json['owner']['face'],
      publishTime: DateTime.fromMillisecondsSinceEpoch(
        json['pubdate'] * Duration.millisecondsPerSecond,
      ),
    );
  }

  factory MediaCardInfo.fromToViewJson(Map<String, dynamic> json) {
    return MediaCardInfo(
      type: MediaType.video,
      avid: json['aid'],
      bvid: json['bvid'],
      cid: json['cid'],
      title: json['title'],
      cover: json['pic'],
      duration: Duration(seconds: json['duration']),
      progress: json['progress'] == null ? null : PlayProgress.fromJson(json),
      stat: Stat.fromJson(json['stat'] ?? {}),
      userMid: json['owner']['mid'],
      userName: json['owner']['name'],
      userAvatar: json['owner']['face'],
      publishTime: DateTime.fromMillisecondsSinceEpoch(
        json['pubdate'] * Duration.millisecondsPerSecond,
      ),
    );
  }

  factory MediaCardInfo.fromHistoryJson(Map<String, dynamic> json) {
    return MediaCardInfo(
      type: json['goto'] == 'av'
          ? MediaType.video
          : (json['goto'] == 'live'
                ? MediaType.live
                : (json['goto'] == 'ogv' ? MediaType.ogv : MediaType.unknown)),
      avid: json['history']?['oid'],
      bvid: json['history']?['bvid'],
      cid: json['history']?['cid'],
      title: json['title'],
      cover: json['cover'],
      duration: Duration(seconds: json['duration']),
      progress: json['progress'] == null ? null : PlayProgress.fromJson(json),
      userMid: json['author_mid'],
      userName: json['author_name'],
      userAvatar: json['author_face'],
      publishTime: DateTime.fromMillisecondsSinceEpoch(
        json['view_at'] * Duration.millisecondsPerSecond,
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

// 统计信息
class Stat {
  final int viewCount;
  final int favoriteCount;
  final int likeCount;
  final int dislikeCount;
  final int coinCount;
  final int shareCount;

  Stat({
    required this.viewCount,
    required this.favoriteCount,
    required this.likeCount,
    required this.dislikeCount,
    required this.coinCount,
    required this.shareCount,
  });

  factory Stat.fromJson(Map<String, dynamic> json) {
    return Stat(
      viewCount: json['view'] ?? 0,
      favoriteCount: json['favorite'] ?? 0,
      likeCount: json['like'] ?? 0,
      dislikeCount: json['dislike'] ?? 0,
      coinCount: json['coin'] ?? 0,
      shareCount: json['share'] ?? 0,
    );
  }
}

// 剧集信息
class Episode {
  final int index; // 从1开始
  final int cid;
  final String title;
  final Duration duration;

  const Episode({
    required this.index,
    required this.cid,
    required this.title,
    required this.duration,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      index: json['page'] ?? 1,
      cid: json['cid'] ?? 0,
      title: json['part'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
    );
  }
}

// 视频信息
class Video {
  final int avid;
  final String bvid;
  final String title;
  final String cover;
  final String desc;
  final Duration duration;
  final Stat stat;
  final String userName;
  final String userAvatar;
  final DateTime publishTime;
  final int cid; // 分P起始位置
  final List<Episode> episodes; // 分P

  Video({
    required this.avid,
    required this.bvid,
    required this.title,
    required this.cover,
    required this.desc,
    required this.duration,
    required this.stat,
    required this.userName,
    required this.userAvatar,
    required this.publishTime,
    required this.cid,
    required this.episodes,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    final episodes = ((json['pages'] ?? []) as List<dynamic>)
        .map((e) => Episode.fromJson(e))
        .toList();
    episodes.sort((a, b) => a.index.compareTo(b.index));
    return Video(
      avid: json['aid'] ?? 0,
      bvid: json['bvid'] ?? '',
      title: json['title'] ?? '',
      cover: json['pic'] ?? '',
      desc: json['desc'] ?? '',
      duration: Duration(seconds: json['duration'] ?? 0),
      stat: Stat.fromJson(json['stat'] ?? {}),
      userName: json['owner']['name'] ?? '',
      userAvatar: json['owner']['face'] ?? '',
      publishTime: DateTime.fromMillisecondsSinceEpoch(
        (json['pubdate'] ?? DateTime.timestamp()) *
            Duration.millisecondsPerSecond,
      ),
      cid: json['cid'] ?? 0,
      episodes: episodes,
    );
  }
}
