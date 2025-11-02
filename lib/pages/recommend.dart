import 'package:bilitv/apis/bilibili/rcmd.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/video_card.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class RecommendPage extends StatefulWidget {
  final ValueNotifier<int> _tappedListener;

  const RecommendPage(this._tappedListener, {super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  final ScrollController _videoScrollController = ScrollController();

  int page = 0;
  final pageVideoCount = 30;
  final List<MediaCardInfo> _videos = [];
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);
  bool _isLoadingMore = false;

  @override
  void initState() {
    _videoScrollController.addListener(_onListenScroll);
    widget._tappedListener.addListener(_onRefresh);
    super.initState();
  }

  @override
  void dispose() {
    _videoScrollController.dispose();
    widget._tappedListener.removeListener(_onRefresh);
    super.dispose();
  }

  DateTime? _lastRefresh;
  void _onRefresh() {
    if (_isLoading.value) return;

    final now = DateTime.now();
    if (_lastRefresh != null &&
        now.difference(_lastRefresh!).inMilliseconds < 500) {
      return;
    }
    _lastRefresh = now;

    _isLoading.value = true;
    page = 0;
    _videos.clear();
    _pullMoreVideos().then((_) {
      _isLoading.value = false;
    });
  }

  DateTime? _lastLoadMore;
  void _onListenScroll() {
    if (_isLoading.value ||
        _isLoadingMore ||
        !_videoScrollController.position.atEdge ||
        _videoScrollController.position.pixels == 0) {
      return;
    }

    final now = DateTime.now();
    if (_lastLoadMore != null &&
        now.difference(_lastLoadMore!).inMilliseconds < 500) {
      return;
    }
    _lastLoadMore = now;

    _isLoadingMore = true;
    _pullMoreVideos();
  }

  // 拉取更多视频
  Future<void> _pullMoreVideos() async {
    page++;

    final videos = await fetchRecommendVideos(
      page: page,
      count: pageVideoCount,
      removeAvids: _videos.map((e) => e.avid).toList(),
    );

    if (!mounted) return;
    setState(() {
      _videos.addAll(videos);
      _isLoadingMore = false;
    });
  }

  void _onVideoTapped(MediaCardInfo video) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => VideoDetailPageWrap(avid: video.avid),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      isLoading: _isLoading,
      loader: _pullMoreVideos,
      builder: (context, _) {
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
                  child: VideoCard(video: _videos[index]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
