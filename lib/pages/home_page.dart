import 'package:bilitv/pages/video_player_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../apis/video.dart';
import '../data/mock_data.dart';
import '../models/video.dart';
import '../widgets/video_card.dart';
import '../widgets/category_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _videoScrollController = ScrollController();

  int _selectedCategoryIndex = 0;
  int page = 0;
  final pageVideoCount = 30;
  List<VideoCardInfo> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _onRefresh();
    _videoScrollController.addListener(_onListenScroll);
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
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

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    page = 0;
    _videos.clear();
    _onRefresh();
  }

  void _onVideoTapped(VideoCardInfo video) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => VideoPlayerPage(video: video),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [_buildAppBar(), _buildCategoryTabs(), _buildVideoGrid()],
      ),
    );
  }

  Widget _buildAppBar() {
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
            color: Colors.black.withOpacity(0.08),
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
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = MockData.getCategories();

    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryTab(
            title: categories[index],
            isSelected: index == _selectedCategoryIndex,
            onTap: () => _onCategorySelected(index),
          );
        },
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
                child: VideoCard(video: _videos[index]),
              ),
            );
          },
        ),
      ),
    );
  }
}
