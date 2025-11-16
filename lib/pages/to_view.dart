import 'dart:async';

import 'package:bilitv/apis/bilibili/toview.dart';
import 'package:bilitv/consts/assets.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/storages/cookie.dart';
import 'package:bilitv/widgets/loading.dart' show buildLoadingStyle1;
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
  int page = 0;
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
    page = 0;
    await _provider.refresh();
  }

  Future<(List<MediaCardInfo>, bool)> _onLoad({
    bool isFetchMore = false,
  }) async {
    if (!loginInfoNotifier.value.isLogin) {
      return ([] as List<MediaCardInfo>, false);
    }

    page++;

    final videos = await listToView(page: page, count: pageVideoCount);
    return (videos, false);
  }

  void _onVideoTapped(_, MediaCardInfo video) {
    Get.to(VideoDetailPageWrap(avid: video.avid));
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
            title: '移除',
            icon: Icons.playlist_remove_rounded,
            action: (media) {
              if (!loginInfoNotifier.value.isLogin) return;

              deleteToView(media.avid);
              pushTooltipInfo(context, '已从稍后再看中移除：${media.title}');

              // 避免服务器主从延迟
              Future.delayed(const Duration(seconds: 1), () {
                _onRefresh();
              });
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
