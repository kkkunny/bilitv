import 'package:bilitv/apis/bilibili.dart' show bilibiliHttpClient;
import 'package:cached_network_image/cached_network_image.dart'
    show CachedNetworkImage, CachedNetworkImageProvider;
import 'package:flutter/material.dart';

class BilibiliNetworkImage extends CachedNetworkImage {
  BilibiliNetworkImage(String url, {super.key})
    : super(
        imageUrl: url,
        fit: BoxFit.cover,
        httpHeaders: bilibiliHttpClient.options.headers.cast<String, String>(),
      );
}

class BilibiliAvatar extends CircleAvatar {
  BilibiliAvatar(String url, {super.key, super.radius})
    : super(
        backgroundImage: CachedNetworkImageProvider(
          url,
          headers: bilibiliHttpClient.options.headers.cast<String, String>(),
        ),
      );
}
