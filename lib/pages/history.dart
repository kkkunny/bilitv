import 'dart:async';

import 'package:bilitv/apis/bilibili/history.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/storages/auth.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:bilitv/widgets/video_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../consts/assets.dart';

class HistoryPage extends StatefulWidget {
  final ValueNotifier<int> _tappedListener;

  const HistoryPage(this._tappedListener, {super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryCursor? cursor;
  final pageVideoCount = 20;
  final _provider = VideoGridViewProvider();

  @override
  void initState() {
    widget._tappedListener.addListener(_onRefresh);
    _provider.onLoad = _onLoad;
    super.initState();
  }

  @override
  void dispose() {
    widget._tappedListener.removeListener(_onRefresh);
    super.dispose();
    _provider.dispose();
  }

  Future<void> _onRefresh() async {
    cursor = null;
    await _provider.refresh();
  }

  Future<(List<MediaCardInfo>, bool)> _onLoad({
    bool isFetchMore = false,
  }) async {
    if (!loginInfoNotifier.value.isLogin) {
      return ([] as List<MediaCardInfo>, false);
    }

    final (nextCursor, videos) = await listHistory(
      cursor: cursor,
      count: pageVideoCount,
    );
    if (nextCursor.max != 0) {
      cursor = nextCursor;
    }
    return (videos, videos.length == pageVideoCount);
  }

  Future<void> _refreshFromData(List<MediaCardInfo> medias) async {
    _provider.clear();
    _provider.addAll(medias);
  }

  void _onVideoTapped(_, MediaCardInfo video) {
    Get.to(VideoDetailPageWrap(avid: video.avid, cid: video.cid));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: VideoGridView(
        provider: _provider,
        onItemTap: _onVideoTapped,
        itemMenuActions: [
          ItemMenuAction(
            title: '历史记录',
            icon: Icons.playlist_remove_rounded,
            action: (media) {
              if (!loginInfoNotifier.value.isLogin) return;

              deleteHistory(media.avid);
              pushTooltipInfo(context, '已从历史记录中移除：${media.title}');
              final newVideos = _provider.toList();
              newVideos.removeWhere((video) => video.avid == media.avid);
              _refreshFromData(newVideos);
            },
          ),
        ],
        refreshWidget: buildLoadingStyle1(),
        noItemsWidget: FractionallySizedBox(
          widthFactor: 0.2,
          child: Image.asset(Images.empty, fit: BoxFit.contain),
        ),
      ),
    );
  }
}
