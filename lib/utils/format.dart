// 视频时长格式化
String videoDurationString(Duration duration) {
  final ms = (duration.inMinutes % 60).toString().padLeft(2, '0');
  final ss = (duration.inSeconds % 60).toString().padLeft(2, '0');
  if (duration.inHours == 0) {
    return '$ms:$ss';
  }
  return '${duration.inHours}:$ms:$ss';
}

// 视频时长格式化
Duration fromVideoDurationString(String duration) {
  if (duration.isEmpty) {
    return Duration.zero;
  }
  // 支持 "SS" / "M:SS" / "H:MM:SS" 以及带小数的秒数
  final res = duration.split(':');
  if (res.length > 3) {
    return Duration.zero;
  }
  var seconds = 0.0;
  for (final part in res) {
    final value = double.tryParse(part.trim());
    if (value == null || value < 0) {
      return Duration.zero;
    }
    seconds = seconds * 60 + value;
  }
  return Duration(milliseconds: (seconds * 1000).round());
}

// 数量格式化
String amountString(int viewCount) {
  if (viewCount >= 100000000) {
    return '${(viewCount / 100000000).toStringAsFixed(1)}亿';
  } else if (viewCount >= 10000) {
    return '${(viewCount / 10000).toStringAsFixed(1)}万';
  } else if (viewCount >= 1000) {
    return '${(viewCount / 1000).toStringAsFixed(1)}千';
  }
  return viewCount.toString();
}

// 日期格式化
String datetimeString(DateTime dateTime) {
  return '${dateTime.year.toString().padLeft(4, '0')}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
}
