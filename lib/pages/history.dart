import 'dart:async';

import 'package:bilitv/apis/bilibili/history.dart';
import 'package:bilitv/consts/assets.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/storages/auth.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:bilitv/widgets/video_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryPage extends StatefulWidget {
  final ValueNotifier<int> _tappedListener;

  const HistoryPage(this._tappedListener, {super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  HistoryCursor? _cursor;
  final _pageVideoCount = 20;
  late final VideoGridViewProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = VideoGridViewProvider(onLoad: _onLoad);
    widget._tappedListener.addListener(_onRefresh);
  }

  @override
  void dispose() {
    widget._tappedListener.removeListener(_onRefresh);
    _provider.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    _cursor = null;
    await _provider.refresh();
  }

  Future<(List<MediaCardInfo>, bool)> _onLoad({
    bool isFetchMore = false,
  }) async {
    if (!loginInfoNotifier.value.isLogin) {
      return (List<MediaCardInfo>.empty(growable: false), false);
    }

    final (nextCursor, videos) = await listHistory(
      cursor: _cursor,
      count: _pageVideoCount,
    );
    if (nextCursor.max != 0) {
      _cursor = nextCursor;
    }
    return (videos, videos.length == _pageVideoCount);
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
    return VideoGridView(
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
    );
  }
}
