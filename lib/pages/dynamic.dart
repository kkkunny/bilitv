import 'dart:async';

import 'package:bilitv/apis/bilibili/dynamic.dart';
import 'package:bilitv/apis/bilibili/toview.dart';
import 'package:bilitv/consts/assets.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/storages/auth.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:bilitv/widgets/video_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class DynamicPage extends StatefulWidget {
  final ValueNotifier<int> _tappedListener;

  const DynamicPage(this._tappedListener, {super.key});

  @override
  State<DynamicPage> createState() => _DynamicPageState();
}

class _DynamicPageState extends State<DynamicPage> {
  int _offset = 0;
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
    _offset = 0;
    await _provider.refresh();
  }

  Future<(List<MediaCardInfo>, bool)> _onLoad({
    bool isFetchMore = false,
  }) async {
    if (!loginInfoNotifier.value.isLogin) {
      return (List<MediaCardInfo>.empty(growable: false), false);
    }

    final resp = await listDynamic(_offset);
    _offset = resp.offset;
    return (resp.medias, resp.hasMore);
  }

  void _onVideoTapped(_, MediaCardInfo video) {
    Get.to(VideoDetailPageWrap(avid: video.avid));
  }

  @override
  Widget build(BuildContext context) {
    return VideoGridView(
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
    );
  }
}
