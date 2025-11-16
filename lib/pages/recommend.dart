import 'dart:async';

import 'package:bilitv/apis/bilibili/recommend.dart';
import 'package:bilitv/apis/bilibili/toview.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/storages/cookie.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:bilitv/widgets/video_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../consts/assets.dart';

class RecommendPage extends StatefulWidget {
  final ValueNotifier<int> _tappedListener;

  const RecommendPage(this._tappedListener, {super.key});

  @override
  State<RecommendPage> createState() => _RecommendPageState();
}

class _RecommendPageState extends State<RecommendPage> {
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
    page++;

    final videos = await listRecommendVideos(
      page: page,
      count: pageVideoCount,
      removeAvids: _provider.toList().map((e) => e.avid).toList(),
    );
    return (videos, true);
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
            title: '稍后再看',
            icon: Icons.playlist_add_rounded,
            action: (media) {
              if (!loginInfoNotifier.value.isLogin) return;

              addToView(avid: media.avid);
              pushTooltipInfo(context, '已加入稍后再看：${media.title}');
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
