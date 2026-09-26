import 'package:get/get.dart';

// 视频输出驱动
enum VideoOutputDrivers {
  gpu('gpu'),
  gpuNext('gpu-next'),
  sdl('sdl'),
  vaapi('vaapi'),
  libmpv('libmpv'),
  drm('drm'),
  mediacodecEmbed('mediacodec_embed');

  final String value;

  const VideoOutputDrivers(this.value);

  static VideoOutputDrivers? parse(String v) {
    return VideoOutputDrivers.values.firstWhereOrNull((e) => e.value == v);
  }

  @override
  String toString() => value;
}

// 画面比例
enum PlayerAspectMode {
  fit('fit', '适应'),
  fill('fill', '全屏（拉伸）'),
  cover('cover', '裁剪');

  final String value;
  final String description;

  const PlayerAspectMode(this.value, this.description);

  static PlayerAspectMode? parse(String? v) {
    return PlayerAspectMode.values.firstWhereOrNull((e) => e.value == v);
  }

  @override
  String toString() => description;
}

// 循环播放
enum PlayerLoopMode {
  none('none', '不循环'),
  single('single', '单个循环');

  final String value;
  final String description;

  const PlayerLoopMode(this.value, this.description);

  static PlayerLoopMode? parse(String? v) {
    return PlayerLoopMode.values.firstWhereOrNull((e) => e.value == v);
  }

  @override
  String toString() => description;
}

// 播放倍速可选项
const playerPlaybackRates = <double>[0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

// 倍速文案：1.0 -> 1.0x
String playbackRateString(double rate) => '${rate}x';

// 视频硬解方式
enum HardwareVideoDecoder {
  no('no'), // 总是软解
  auto('auto'),
  yes('yes'),
  autoSafe('auto-safe'),
  autoUnsafe('auto-unsafe'),
  vulkan('vulkan'),
  vulkanCopy('vulkan-copy'),
  mediacodec('mediacodec'),
  mediacodecCopy('mediacodec-copy');

  final String value;

  const HardwareVideoDecoder(this.value);

  static HardwareVideoDecoder? parse(String v) {
    return HardwareVideoDecoder.values.firstWhereOrNull((e) => e.value == v);
  }

  @override
  String toString() => value;
}
