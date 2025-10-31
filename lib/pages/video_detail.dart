import 'package:bilitv/apis/bilibili.dart'
    show getVideoInfo, fetchRelatedVideos;
import 'package:bilitv/consts/bilibili.dart';
import 'package:bilitv/models/video.dart';
import 'package:bilitv/pages/video_player.dart';
import 'package:bilitv/utils/format.dart';
import 'package:bilitv/widgets/bilibili_image.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/video_card.dart';
import 'package:flutter/material.dart';

class VideoDetailPageInput {
  final VideoInfo video;
  final List<MediaCardInfo> relatedVideos;

  VideoDetailPageInput(this.video, this.relatedVideos);
}

class VideoDetailPage extends StatefulWidget {
  final VideoInfo video;
  final List<MediaCardInfo> relatedVideos;

  const VideoDetailPage({
    super.key,
    required this.video,
    this.relatedVideos = const [],
  });

  @override
  State<VideoDetailPage> createState() => _VideoDetailPageState();
}

class _VideoDetailPageState extends State<VideoDetailPage> {
  void _onCoverTapped() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => VideoPlayerPage(video: widget.video),
      ),
    );
  }

  void _onVideoTapped(MediaCardInfo video) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => LoadingWidget(
          loader: () async {
            final v = await getVideoInfo(avid: video.avid);
            final relatedVs = await fetchRelatedVideos(avid: video.avid);
            return VideoDetailPageInput(v, relatedVs);
          },
          builder: (context, input) {
            return VideoDetailPage(
              video: input.video,
              relatedVideos: input.relatedVideos,
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildVideoHeader(),
            // const SizedBox(height: 24),
            // _buildVideoEpisodes(),
            const SizedBox(height: 24),
            _buildRelatedVideos(),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoHeader() {
    return Row(children: [_buildVideoPlayer(), _buildVideoInfo()]);
  }

  Widget _buildVideoPlayer() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: InkWell(
          onTap: () => _onCoverTapped(),
          focusColor: Colors.blue.shade100,
          hoverColor: Colors.blue.shade100,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(
              alignment: Alignment.center,
              children: [
                AspectRatio(
                  aspectRatio: coverSizeRatio,
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: BilibiliNetworkImage(widget.video.cover),
                    ),
                  ),
                ),
                Icon(Icons.play_circle_sharp, size: 150, color: Colors.black54),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoInfo() {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Card(
          child: AspectRatio(
            aspectRatio: coverSizeRatio,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 170,
                    child: Text(
                      widget.video.title,
                      style: const TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: Colors.black,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_outline_sharp,
                              size: 30,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              amountString(widget.video.viewCount),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.thumb_up_outlined,
                              size: 30,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              amountString(widget.video.likeCount),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline_sharp,
                              size: 30,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              amountString(widget.video.replyCount),
                              style: TextStyle(
                                fontSize: 20,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '视频简介',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Text(
                      widget.video.desc,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ClipOval(
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: BilibiliAvatar(widget.video.userAvatar),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.video.userName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'UP主',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '发布日期: ${datetimeString(widget.video.publishTime)}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVideoEpisodes() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '视频分P',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.play_circle_outline,
                    size: 32,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'P1 ${widget.video.title}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    videoDurationString(widget.video.duration),
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRelatedVideos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '相关视频',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: videoCardWidth,
            mainAxisExtent: videoCardHigh + 8,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: widget.relatedVideos.length,
          itemBuilder: (context, index) {
            return Material(
              child: InkWell(
                onTap: () => _onVideoTapped(widget.relatedVideos[index]),
                focusColor: Colors.blue.shade100,
                hoverColor: Colors.blue.shade100,
                child: VideoCard(video: widget.relatedVideos[index]),
              ),
            );
          },
        ),
      ],
    );
  }
}
