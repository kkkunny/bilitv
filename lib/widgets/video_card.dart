import 'package:bilitv/consts/bilibili.dart';
import 'package:bilitv/models/video.dart';
import 'package:bilitv/utils/format.dart';
import 'package:bilitv/widgets/bilibili_image.dart';
import 'package:flutter/material.dart';

const videoCardWidth = 400.0;
const videoCardHigh = videoCardWidth / coverSizeRatio + 65.0;

class VideoCard extends StatefulWidget {
  final MediaCardInfo video;

  const VideoCard({super.key, required this.video});

  @override
  State<VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<VideoCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [_buildThumbnail(), _buildVideoInfo()],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    return Stack(
      children: [
        SizedBox(
          width: videoCardWidth,
          height: videoCardWidth / coverSizeRatio,
          child: BilibiliNetworkImage(widget.video.cover),
        ),
        Positioned(
          top: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(6),
              color: Colors.black.withValues(alpha: 0.3),
            ),
            child: Row(
              children: [
                ClipOval(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: BilibiliAvatar(widget.video.userAvatar),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  widget.video.userName,
                  style: TextStyle(fontSize: 12, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          left: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.black26.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.play_circle_outline_sharp,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  amountString(widget.video.viewCount),
                  style: TextStyle(fontSize: 12, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: Colors.black26.withValues(alpha: 0.1),
            ),
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    Icons.access_time_sharp,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  videoDurationString(widget.video.duration),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVideoInfo() {
    return Container(
      width: videoCardWidth,
      height: videoCardHigh - videoCardWidth / coverSizeRatio,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white),
      child: Text(
        widget.video.title,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
          height: 1.3,
        ),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
