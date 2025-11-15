import 'dart:async';

import 'package:bilitv/apis/bilibili/toview.dart';
import 'package:bilitv/consts/assets.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/storages/cookie.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:bilitv/widgets/video_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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

    final videos = await listToView();

    _refreshFromData(videos);
    _isLoading.value = false;
  }

  Future<void> _refreshFromData(List<MediaCardInfo> medias) async {
    _videos.clear();
    _videos.addAll(medias);
  }

  void _onVideoTapped(_, MediaCardInfo video) {
    Get.to(VideoDetailPageWrap(avid: video.avid));
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
          child: VideoGridView(
            provider: _videos,
            onItemTap: _onVideoTapped,
            itemMenuActions: [
              ItemMenuAction(
                title: '移除',
                icon: Icons.playlist_remove_rounded,
                action: (media) {
                  if (!loginInfoNotifier.value.isLogin) return;

                  deleteToView(media.avid);
                  pushTooltipInfo(context, '已从稍后再看中移除：${media.title}');
                  final newVideos = _videos.toList();
                  newVideos.removeWhere((video) => video.avid == media.avid);
                  _refreshFromData(newVideos);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
