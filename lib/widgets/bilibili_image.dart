import 'package:bilitv/apis/bilibili/client.dart' show bilibiliHttpClient;
import 'package:bilitv/consts/assets.dart';
import 'package:bilitv/consts/bilibili.dart' show coverSizeRatio;
import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage, CachedNetworkImageProvider;
import 'package:flutter/material.dart';

// bilibili网络图片提供方，带上了header
class BilibiliNetworkImageProvider extends CachedNetworkImageProvider {
  BilibiliNetworkImageProvider(super.url)
    : super(headers: bilibiliHttpClient.options.headers.cast<String, String>());
}

// bilibili网络图片，带上了header
class BilibiliNetworkImage extends CachedNetworkImage {
  BilibiliNetworkImage(String url, {super.key})
    : super(
        imageUrl: url,
        fit: BoxFit.cover,
        httpHeaders: bilibiliHttpClient.options.headers.cast<String, String>(),
      );
}

// bilibili媒体缩略图，固定了纵横比
class BilibiliMediaThumbnail extends StatelessWidget {
  final String url;

  const BilibiliMediaThumbnail(this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: coverSizeRatio,
      child: BilibiliNetworkImage(url),
    );
  }
}

// bilibili头像，带上了header和默认头像
class BilibiliAvatar extends CircleAvatar {
  BilibiliAvatar(
    String? url, {
    super.key,
    super.radius,
    void Function(Object, StackTrace?)? onError,
  }) : super(
         backgroundImage: AssetImage(Images.noface),
         foregroundImage: url == null
             ? null
             : BilibiliNetworkImageProvider(url),
         onForegroundImageError: onError,
       );
}
