import 'package:bilitv/apis/bilibili.dart'
    show fetchRecommendVideos, getVideoInfo, fetchRelatedVideos;
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/video_card.dart';
import 'package:flutter/material.dart';

class RecommendPage extends StatefulWidget {
  const RecommendPage({super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  final ScrollController _videoScrollController = ScrollController();

  int page = 0;
  final pageVideoCount = 30;
  List<MediaCardInfo> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _onRefresh();
    _videoScrollController.addListener(_onListenScroll);
  }

  @override
  void dispose() {
    _videoScrollController.dispose();
    super.dispose();
  }

  void _onListenScroll() {
    if (!_videoScrollController.position.atEdge ||
        _videoScrollController.position.pixels == 0) {
      return;
    }
    _onRefresh();
  }

  void _onRefresh() {
    page++;

    if (_videos.isEmpty) {
      setState(() {
        _isLoading = true;
      });

      fetchRecommendVideos(page: page, count: pageVideoCount).then((videos) {
        setState(() {
          _videos = videos;
          _isLoading = false;
        });
      });
      return;
    }

    fetchRecommendVideos(
      page: page,
      count: pageVideoCount,
      removeAvids: _videos.map((e) => e.avid).toList(),
    ).then((videos) {
      setState(() {
        _videos.addAll(videos);
      });
    });
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
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[500]!),
            ),
            const SizedBox(height: 16),
            Text(
              '加载中...',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        controller: _videoScrollController,
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: videoCardWidth,
          mainAxisExtent: videoCardHigh + 8,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
        ),
        itemCount: _videos.length,
        itemBuilder: (context, index) {
          return Material(
            child: InkWell(
              onTap: () => _onVideoTapped(_videos[index]),
              focusColor: Colors.blue.shade100,
              hoverColor: Colors.blue.shade100,
              child: VideoCard(video: _videos[index]),
            ),
          );
        },
      ),
    );
  }
}
