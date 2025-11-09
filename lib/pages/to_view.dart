import 'package:bilitv/apis/bilibili/toview.dart';
import 'package:bilitv/consts/assets.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/storages/cookie.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/video_grid_view.dart';
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
  final _videos = VideoGridViewProvider();

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

  Future<void> _onInitData() async {
    if (!loginInfoNotifier.value.isLogin) return;

    final videos = await listToView();
    _videos.addAll(videos);
  }

  DateTime? _lastRefresh;
  Future<void> _onRefresh() async {
    if (!loginInfoNotifier.value.isLogin) return;
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

  void _onVideoTapped(_, MediaCardInfo video) {
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
      loader: _onInitData,
      builder: (context, _) {
        if (_videos.isEmpty) {
          return FractionallySizedBox(
            widthFactor: 0.2,
            child: Image.asset(Images.empty, fit: BoxFit.contain),
          );
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: VideoGridView(provider: _videos, onTap: _onVideoTapped),
        );
      },
    );
  }
}
