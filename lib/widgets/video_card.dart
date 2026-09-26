import 'package:bilitv/models/video.dart';
import 'package:bilitv/utils/format.dart';
import 'package:bilitv/widgets/bilibili_image.dart';
import 'package:bilitv/widgets/text.dart';
import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';

const videoCardAspectRatio = 1.2;

class VideoCard extends StatelessWidget {
  final MediaCardInfo video;
  final void Function()? onTap;
  final void Function()? onFocus;
  final bool showStats; // 是否在标题下方展示播放量/评论数
  final double aspectRatio; // 卡片宽高比
  final FocusEffectBuilder? focusEffect; // 选中特效，默认光晕

  const VideoCard({
    super.key,
    required this.video,
    this.onTap,
    this.onFocus,
    this.showStats = false,
    this.aspectRatio = videoCardAspectRatio,
    this.focusEffect,
  });

  @override
  Widget build(BuildContext context) {
    return DpadFocusable(
      builder:
          focusEffect ??
          FocusEffects.glow(
            glowColor: Theme.of(context).highlightColor,
            borderRadius: BorderRadius.circular(12),
            spreadRadius: 10,
          ),
      onSelect: onTap,
      onFocus: onFocus,
      child: AspectRatio(
        aspectRatio: aspectRatio,
        child: Material(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCover(),
              ?_buildProgress(),
              _buildTitle(context),
              ?(showStats ? _buildStats() : null),
            ],
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
                SizedBox(
                  width: 20,
                  height: 20,
                  child: BilibiliAvatar(video.userAvatar),
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
                  child: const Row(
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(Icons.done, size: 14, color: Colors.green),
                      ),
                      SizedBox(width: 4),
                      Text(
                        "已看完",
                        style: TextStyle(
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
        ?video.stat == null || showStats
            ? null
            : Positioned(
                bottom: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: Colors.black26.withValues(alpha: 0.1),
                  ),
                  child: Row(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 2),
                        child: Icon(
                          Icons.play_circle_outline_sharp,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        amountString(video.stat!.viewCount),
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
                const Padding(
                  padding: EdgeInsets.only(top: 2),
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 与卡片宽度成比例，保证不同分辨率下观感一致
          final padding = showStats
              ? (constraints.maxWidth * 0.025).clamp(3.0, 12.0)
              : 8.0;
          return Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(
              padding,
              padding,
              padding,
              showStats ? padding * 0.25 : padding,
            ),
            color: Colors.white,
            child: FixedLineAdaptiveText(
              video.title,
              line: 2,
              lineHeight: 1.4,
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ),
    );
  }

  // 播放量/评论数（相关推荐卡片使用）
  Widget _buildStats() {
    return LayoutBuilder(
      builder: (context, constraints) {
        // 与卡片宽度成比例，保证不同分辨率下观感一致
        final ratio = constraints.maxWidth * 0.025;
        final fontSize = constraints.maxWidth * 0.073;
        final iconSize = fontSize * 1.3;
        final gap = ratio * 0.5;
        final style = TextStyle(fontSize: fontSize, color: Colors.grey.shade600);
        final iconColor = Colors.grey.shade600;

        return Container(
          width: double.infinity,
          color: Colors.white,
          padding: EdgeInsets.fromLTRB(
            ratio.clamp(3.0, 12.0),
            0,
            ratio.clamp(3.0, 12.0),
            ratio.clamp(2.0, 8.0),
          ),
          child: Row(
            children: [
              Icon(
                Icons.play_circle_fill_rounded,
                size: iconSize,
                color: iconColor,
              ),
              SizedBox(width: gap),
              Text(amountString(video.stat?.viewCount ?? 0), style: style),
              const Spacer(),
              Icon(Icons.comment_outlined, size: iconSize, color: iconColor),
              SizedBox(width: gap),
              Text(amountString(video.stat?.commentCount ?? 0), style: style),
            ],
          ),
        );
      },
    );
  }
}
