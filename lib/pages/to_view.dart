import 'package:bilitv/apis/bilibili/toview.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/video_card.dart';
import 'dart:async';
import 'package:flutter/material.dart';

class ToViewPage extends StatefulWidget {
  final ValueNotifier<int> _tappedListener;

  const ToViewPage(this._tappedListener, {super.key});

  @override
  State<ToViewPage> createState() => _ToViewPageState();
}

class _ToViewPageState extends State<ToViewPage> {
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(true);
  final List<MediaCardInfo> _videos = [];

  @override
  void initState() {
    widget._tappedListener.addListener(_onRefresh);
    super.initState();
  }

  @override
  void dispose() {
    widget._tappedListener.removeListener(_onRefresh);
    super.dispose();
  }

  DateTime? _lastRefresh;
  Future<void> _onRefresh() async {
    if (_isLoading.value) return;

    final now = DateTime.now();
    if (_lastRefresh != null &&
        now.difference(_lastRefresh!).inMilliseconds < 500) {
      return;
    }
    _lastRefresh = now;

    _isLoading.value = true;
    _videos.clear();

    final videos = await listToView();

    _videos.addAll(videos);
    _isLoading.value = false;
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
      loader: () async {
        final videos = await listToView();
        _videos.addAll(videos);
        return;
      },
      builder: (context, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: GridView.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: videoCardWidth,
              childAspectRatio: 1.1,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
            ),
            itemCount: _videos.length,
            itemBuilder: (context, index) {
              return VideoCard(
                video: _videos[index],
                onTap: () => _onVideoTapped(_videos[index]),
              );
            },
          ),
        );
      },
    );
  }
}
