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
