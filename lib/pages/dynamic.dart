import 'dart:async';

import 'package:bilitv/apis/bilibili/dynamic.dart';
import 'package:bilitv/apis/bilibili/toview.dart';
import 'package:bilitv/apis/bilibili/user.dart' show UserInfo;
import 'package:bilitv/consts/assets.dart';
import 'package:bilitv/models/video.dart' show MediaCardInfo;
import 'package:bilitv/pages/video_detail.dart';
import 'package:bilitv/storages/auth.dart';
import 'package:bilitv/widgets/bilibili_image.dart';
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

final _dynamicAvatarMockUp = UserInfo(mid: -1, name: '全部动态', avatar: '');

class _DynamicPageState extends State<DynamicPage> {
  int _offset = 0;
  int? _selectedMid;
  final List<UserInfo> _ups = [];
  late final VideoGridViewProvider _provider;
  final _upListScrollCtl = ScrollController();

  @override
  void initState() {
    super.initState();
    _provider = VideoGridViewProvider(onLoad: _onLoad);
    widget._tappedListener.addListener(_onRefresh);
    _fetchUpList();
  }

  @override
  void dispose() {
    widget._tappedListener.removeListener(_onRefresh);
    _provider.dispose();
    _upListScrollCtl.dispose();
    super.dispose();
  }

  Future<void> _fetchUpList() async {
    final portal = await getDynamicPortal();
    if (!mounted) return;
    setState(() {
      _ups.clear();
      _ups.add(_dynamicAvatarMockUp);
      _ups.addAll(portal.ups);
    });
  }

  Future<void> _onRefresh() async {
    _selectedMid = null;
    _upListScrollCtl.animateTo(
      0,
      duration: Duration(milliseconds: 250),
      curve: Curves.linear,
    );
    await Future.wait([
      _fetchUpList(),
      _refreshVideos(),
    ]);
  }

  Future<(List<MediaCardInfo>, bool)> _onLoad({
    bool isFetchMore = false,
  }) async {
    if (!loginInfoNotifier.value.isLogin) {
      return (List<MediaCardInfo>.empty(growable: false), false);
    }

    final resp = await listDynamic(offset: _offset, mid: _selectedMid);
    _offset = resp.offset;
    return (resp.medias, resp.hasMore);
  }

  void _onUpSelected(int? mid) {
    if (_selectedMid == mid) {
      // 刷新视频
      _refreshVideos();
      return;
    }
    // 更换up主并刷新
    setState(() {
      if (mid == null) {
        _selectedMid = null;
      } else {
        _selectedMid = mid;
      }
    });
    _refreshVideos();
  }

  Future<void> _refreshVideos() async {
    _offset = 0;
    await _provider.refresh();
  }

  void _onVideoTapped(_, MediaCardInfo video) {
    Get.to(() => VideoDetailPageWrap(avid: video.avid));
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildUpSidebar(),
        const VerticalDivider(width: 1),
        Expanded(child: _buildVideoGrid()),
      ],
    );
  }

  Widget _buildUpSidebar() {
    return Container(
      width: 90,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(
          right: BorderSide(
            color: Colors.pink.withValues(alpha: 0.1),
            width: 1,
          ),
        ),
      ),
      child: _buildUpListView(),
    );
  }

  Widget _buildUpListView() {
    if (_ups.isEmpty) {
      return const Center(child: SizedBox());
    }
    return ListView.builder(
      controller: _upListScrollCtl,
      itemCount: _ups.length,
      itemBuilder: (context, index) {
        final up = _ups[index];
        final avatar = up.mid <= 0
            ? CircleAvatar(radius: 22, child: Image.asset(Images.dynamicAvatar))
            : BilibiliAvatar(up.avatar, radius: 22);
        return _SidebarAvatarItem(
          selected:
              (up.mid <= 0 && _selectedMid == null) || _selectedMid == up.mid,
          onTap: () => _onUpSelected(up.mid),
          label: up.name,
          child: avatar,
        );
      },
    );
  }

  Widget _buildVideoGrid() {
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

class _SidebarAvatarItem extends StatelessWidget {
  final Widget child;
  final String label;
  final bool selected;
  final bool autofocus;
  final VoidCallback onTap;

  const _SidebarAvatarItem({
    required this.label,
    required this.selected,
    required this.onTap,
    this.autofocus = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Material(
        color: selected
            ? Colors.pink.withValues(alpha: 0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          autofocus: autofocus,
          borderRadius: BorderRadius.circular(10),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                child,
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10,
                    color: selected ? Colors.pinkAccent : Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
