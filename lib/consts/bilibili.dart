// app鉴权
const appKey = '1d8b6e7d45233436';
const appSec = '560c52ccd288fed045859ed18bffd973';

// 封面宽高比
const coverSizeRatio = 16 / 10;

class VideoQuality {
  final int index;
  final String name;
  final bool needLogin;
  final bool needVIP;

  const VideoQuality(
    this.index,
    this.name, {
    this.needLogin = false,
    this.needVIP = false,
  });

  // static const vq240P = VideoQuality(6, '240P 极速');
  static const vq360P = VideoQuality(16, '360P 流畅');
  static const vq480P = VideoQuality(32, '480P 清晰');
  static const vq720P = VideoQuality(64, '720P 高清');
  static const vq720P60 = VideoQuality(74, '720P60 高帧率', needLogin: true);
  static const vq1080P = VideoQuality(80, '1080P 高清', needLogin: true);
  static const vqRepair = VideoQuality(100, '智能修复', needLogin: true, needVIP: true);
  static const vq1080PPlus = VideoQuality(
    112,
    '1080P+ 高码率',
    needLogin: true,
    needVIP: true,
  );
  static const vq4K = VideoQuality(120, '4K 超清', needLogin: true, needVIP: true);
// static const vqHDR = VideoQuality(125, 'HDR 真彩色', needLogin: true, needVIP: true);
// static const vqDolbyVision = VideoQuality(126, '杜比视界', needLogin: true, needVIP: true);
// static const vq8K = VideoQuality(127, '8K 超高清', needLogin: true, needVIP: true);
  static const vqHDRVivid = VideoQuality(
    129,
    'HDR Vivid',
    needLogin: true,
    needVIP: true,
  );

  static const List<VideoQuality> values = [
    // vq240P,
    vq360P,
    vq480P,
    vq720P,
    vq720P60,
    vq1080P,
    vqRepair,
    vq1080PPlus,
    vq4K,
    // vqHDR,
    // vqDolbyVision,
    // vq8K,
    vqHDRVivid,
  ];
}

// 弹幕分块间隔时长
const danmakuChunkIntervalDuration = Duration(minutes: 6);
