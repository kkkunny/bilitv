import 'package:bilitv/apis/bilibili/rcmd.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/video_grid_view.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class RecommendPage extends StatefulWidget {
  final ValueNotifier<int> _tappedListener;

  const RecommendPage(this._tappedListener, {super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
  int page = 0;
  final pageVideoCount = 30;
  final _videos = VideoGridViewProvider();
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);

  @override
  void initState() {
    widget._tappedListener.addListener(_onRefresh);
    _videos.onLoad = _pullMoreVideos;
    super.initState();
  }

  @override
  void dispose() {
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
    _pullMoreVideos().then((res) {
      _videos.addAll(res.$1);
      _isLoading.value = false;
    });
  }

  void _onVideoTapped(_, MediaCardInfo video) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => VideoDetailPageWrap(avid: video.avid),
      ),
    );
  }

  bool _isFetchingMore = false;
  DateTime? _lastFetchMore;
  Future<void> _onVideoFocused(int index, MediaCardInfo video) async {
    final lastLine = (index / 5).floor() == ((_videos.length - 1) / 5).floor();
    if (!lastLine || _isFetchingMore) return;

    final now = DateTime.now();
    if (_lastFetchMore != null &&
        now.difference(_lastFetchMore!).inMilliseconds < 500) {
      return;
    }
    _lastFetchMore = now;

    _isFetchingMore = true;
    await _videos.fetchData(isFetchMore: true);
    _isFetchingMore = false;
  }

  Future<(List<MediaCardInfo>, bool)> _pullMoreVideos({
    bool isFetchMore = false,
  }) async {
    page++;

    final videos = await fetchRecommendVideos(
      page: page,
      count: pageVideoCount,
      removeAvids: _videos.toList().map((e) => e.avid).toList(),
    );

    return (videos, true);
  }

  @override
  Widget build(BuildContext context) {
    return LoadingWidget(
      isLoading: _isLoading,
      loader: () async => await _pullMoreVideos().then((res) {
        _videos.addAll(res.$1);
      }),
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: VideoGridView(
            provider: _videos,
            onTap: _onVideoTapped,
            onFocus: _onVideoFocused,
          ),
        );
      },
    );
  }
}
