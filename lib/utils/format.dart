// 视频时长格式化
String videoDurationString(Duration duration) {
  final ms = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
  if (duration.inHours == 0) {
    return '$ms:$ss';
  }
  return '${duration.inHours}:$ms:$ss';
}

// 播放量格式化
String videoViewCountString(int viewCount) {
  if (viewCount > 100000000) {
    return '${(viewCount / 100000000).toStringAsFixed(1)}亿';
  } else if (viewCount > 10000) {
    return '${(viewCount / 10000).toStringAsFixed(1)}万';
  } else if (viewCount > 1000) {
    return '${(viewCount / 1000).toStringAsFixed(1)}千';
  }
  return viewCount.toString();
}
