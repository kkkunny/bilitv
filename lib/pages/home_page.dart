import 'package:bilitv/apis/rcmd.dart';
import 'package:bilitv/pages/video_detail_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:bilitv/pages/qr_login_page.dart';
import '../apis/video.dart';
import '../models/video.dart';
import '../widgets/loading.dart';
import '../widgets/video_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        builder: (context) => Loading(
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

  Future<void> _onLogin(BuildContext context) async {
    final token = await Navigator.push(
      context,
      MaterialPageRoute(builder: (c) => const QRLoginPage()),
    );
    if (token != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('登录成功: $token')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(children: [_buildAppBar(context), _buildVideoGrid()]),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          SvgPicture.network(
            'https://www.tapafun.com/wp-content/uploads/2024/11/Bilibili_tv_a.svg',
            fit: BoxFit.cover,
            width: 40,
            height: 40,
            placeholderBuilder: (context) => Container(
              color: Colors.black,
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorBuilder: (context, url, error) => Container(
              color: Colors.black,
              child: const Icon(Icons.live_tv),
            ),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '哔哩哔哩TV',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A1D6),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '发弹幕看视频必备APP',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          Expanded(child: Container()),
          ElevatedButton(
            onPressed: () => _onLogin(context),
            child: const Text('登录'),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoGrid() {
    if (_isLoading) {
      return Expanded(
        child: Center(
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
        ),
      );
    }

    return Expanded(
      child: Container(
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
      ),
    );
  }
}
