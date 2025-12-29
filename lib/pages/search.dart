import 'dart:async';

import 'package:bilitv/apis/bilibili/search.dart';
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

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String _searchKeyword = "";
  int _page = 0;
  late final VideoGridViewProvider _provider;

  @override
  void initState() {
    super.initState();
    _provider = VideoGridViewProvider(onLoad: _onLoad);
  }

  @override
  void dispose() {
    _provider.dispose();
    super.dispose();
  }

  Future<(List<MediaCardInfo>, bool)> _onLoad({
    bool isFetchMore = false,
  }) async {
    if (!loginInfoNotifier.value.isLogin || !isFetchMore) {
      return (List<MediaCardInfo>.empty(growable: false), false);
    }

    _page++;

    final videos = await searchVideos(_searchKeyword, page: _page);
    return (videos, true);
  }

  void _onVideoTapped(_, MediaCardInfo video) {
    Get.to(VideoDetailPageWrap(avid: video.avid, cid: video.cid));
  }

  Future<void> _onSearch(String input) async {
    if (!loginInfoNotifier.value.isLogin) {
      return;
    }

    _searchKeyword = input;
    final (videos, _) = await _onLoad(isFetchMore: true);
    _provider.clear();
    _provider.addAll(videos);
    _provider.hasMore = true;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: MediaQuery.of(context).size.width / 3,
          height: 40,
          margin: const EdgeInsets.only(top: 14),
          child: TextField(
            decoration: InputDecoration(
              icon: Icon(Icons.search_rounded, size: 34),
              hintText: '请输入搜索内容',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
              ),
            ),
            onSubmitted: (text) async {
              if (text.isEmpty) {
                return;
              }
              _onSearch(text);
            },
          ),
        ),
        Expanded(
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
        ),
      ],
    );
  }
}
