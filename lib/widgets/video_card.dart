import 'package:bilitv/models/video.dart';
import 'package:bilitv/utils/format.dart';
import 'package:bilitv/widgets/bilibili_image.dart';
import 'package:bilitv/widgets/text.dart';
import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

const videoCardAspectRatio = 1.2;

class VideoCard extends StatelessWidget {
  final MediaCardInfo video;
  final void Function()? onTap;
  final void Function()? onFocus;

  const VideoCard({super.key, required this.video, this.onTap, this.onFocus});

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(video.avid.toString()),
      onVisibilityChanged: null,
      child: AspectRatio(
        aspectRatio: videoCardAspectRatio,
        child: InkWell(
          onTap: onTap,
          onFocusChange: (focus) {
            if (!focus || onFocus == null) return;
            onFocus!();
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCover(),
                  ?_buildProgress(),
                  _buildTitle(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget? _buildProgress() {
    if (video.progress == null) return null;
    final progressRatio =
        video.progress!.duration().inSeconds / video.duration.inSeconds;
    if (progressRatio < 0.01) return null;
    return LinearProgressIndicator(
      value: progressRatio,
      color: Colors.pinkAccent,
      backgroundColor: Colors.grey.shade400,
    );
  }

  Widget _buildCover() {
    return Stack(
      children: [
        BilibiliMediaThumbnail(video.cover),
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
                    child: BilibiliAvatar(video.userAvatar),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  video.userName,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        ?video.progress != null && video.progress!.finished()
            ? Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.black.withValues(alpha: 0.3),
                  ),
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Icon(Icons.done, size: 14, color: Colors.green),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        "已看完",
                        style: const TextStyle(
                          color: Colors.green,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : null,
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
                  amountString(video.stat.viewCount),
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
                  videoDurationString(video.duration),
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

  Widget _buildTitle(BuildContext context) {
    return Expanded(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(8),
        color: Colors.white,
        child: FixedLineAdaptiveText(
          video.title,
          line: 2,
          lineHeight: 1.4,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
