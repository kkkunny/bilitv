import 'dart:math';

import 'package:animated_infinite_scroll_pagination/animated_infinite_scroll_pagination.dart'
    hide AnimatedInfiniteScrollView;
import 'package:bilitv/models/video.dart';
import 'package:bilitv/widgets/animated_infinite_scrollview.dart';
import 'package:bilitv/widgets/video_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class _VideoGridViewController
    with AnimatedInfinitePaginationController<MediaCardInfo> {
  final bool Function() hasMore;
  final Future<void> Function({bool isFetchMore}) onLoad;

  _VideoGridViewController({required this.hasMore, required this.onLoad});

  @override
  get lastPage => !hasMore();

  @override
  bool areItemsTheSame(MediaCardInfo a, MediaCardInfo b) {
    return a.avid == b.avid;
  }

  @override
  Future<void> fetchData(int page) async => onLoad(isFetchMore: page == 1);

  void clear() {
    page = 1;
    total = 0;
    emptyList.postValue(false);
    items.postValue(const []);
  }
}

class VideoGridViewProvider {
  late final _ctl = _VideoGridViewController(
    hasMore: () => hasMore,
    onLoad: fetchData,
  );
  final List<MediaCardInfo> initVideos;
  Future<(List<MediaCardInfo>, bool)> Function({bool isFetchMore})? onLoad;
  late bool _hasMore = onLoad == null;
  final _refreshing = ValueNotifier(false);
  late final ScrollController _scrollCtl = ScrollController();

  VideoGridViewProvider({this.initVideos = const [], this.onLoad});

  void dispose() {
    _refreshing.dispose();
    _scrollCtl.dispose();
  }

  List<MediaCardInfo> toList() => _ctl.items.value.map((e) => e.item).toList();

  operator [](int index) => _ctl.items.value[index].item;

  int get length => _ctl.total;

  bool get isEmpty => _ctl.total == 0;

  bool get isNotEmpty => _ctl.total != 0;

  set hasMore(v) => _hasMore = v;

  bool get hasMore => _hasMore;

  void addAll(Iterable<MediaCardInfo> iterable) {
    _ctl.emitState(PaginationSuccessState(iterable.toList()));
    _ctl.setTotal(_ctl.items.value.length);
  }

  void clear() => _ctl.clear();

  Future<void> refresh({saveInitData = true}) async {
    try {
      if (_refreshing.value) return;

      if (_scrollCtl.hasClients && _scrollCtl.offset != 0) {
        await _scrollCtl.animateTo(
          0,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
      _refreshing.value = true;
      clear();
      if (saveInitData && initVideos.isNotEmpty) addAll(initVideos);
      await fetchData(isFetchMore: false);
      _refreshing.value = false;
    } catch (_) {}
  }

  Future<void> fetchData({bool isFetchMore = false}) async {
    if (onLoad == null) return;

    _ctl.emitState(const PaginationLoadingState());

    final (newVideos, hasMore) = await onLoad!(isFetchMore: isFetchMore);
    _hasMore = hasMore;
    addAll(newVideos);
  }
}

class VideoGridView<T> extends StatefulWidget {
  final VideoGridViewProvider provider;
  final Axis scrollDirection;
  final bool shrinkWrap;
  final void Function(int index, MediaCardInfo item)? onItemTap;
  final void Function(int index, MediaCardInfo item)? onItemFocus;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final int? crossAxisCount; // 与maxCrossAxisExtent互斥
  final double? maxCrossAxisExtent; // 与crossAxisCount互斥
  final List<ItemMenuAction> itemMenuActions;
  final Widget? refreshWidget; // 刷新时展示的组件
  final Widget? noItemsWidget; // items为空时展示的组件

  const VideoGridView({
    super.key,
    required this.provider,
    this.scrollDirection = Axis.vertical,
    this.shrinkWrap = false,
    this.onItemTap,
    this.onItemFocus,
    this.mainAxisSpacing = 20.0,
    this.crossAxisSpacing = 20.0,
    this.crossAxisCount,
    this.maxCrossAxisExtent,
    this.itemMenuActions = const [],
    this.refreshWidget,
    this.noItemsWidget,
  });

  @override
  State<VideoGridView<T>> createState() => _VideoGridViewState<T>();
}

const _defaultMaxCrossAxisExtent = 400.0;

class _VideoGridViewState<T> extends State<VideoGridView<T>> {
  int _focusIndex = 0;
  late final FocusNode _keyboardListenerFocusNode;

  @override
  void initState() {
    super.initState();
    _keyboardListenerFocusNode = FocusNode(canRequestFocus: false);
    widget.provider.refresh();
  }

  @override
  void dispose() {
    _keyboardListenerFocusNode.dispose();
    super.dispose();
  }

  bool _isFetchingMore = false;
  DateTime? _lastRefresh;

  void _onItemFocus(int index, MediaCardInfo item) {
    _focusIndex = index;
    widget.onItemFocus?.call(index, item);

    // 焦点在最后一行时拉取更多数据
    if (!widget.provider.hasMore) return;
    late int crossAxisCount;
    if (widget.crossAxisCount != null) {
      crossAxisCount = widget.crossAxisCount!;
    } else {
      final crossAxisSize = widget.scrollDirection == Axis.horizontal
          ? Get.height
          : Get.width;
      crossAxisCount = max(
        crossAxisSize /
            ((widget.maxCrossAxisExtent ?? _defaultMaxCrossAxisExtent) +
                widget.crossAxisSpacing),
        1.0,
      ).toInt();
    }
    final isLastRowOrLine =
        (index / crossAxisCount).toInt() ==
        ((max(widget.provider.length - 1, 0)) / crossAxisCount).toInt();
    if (!isLastRowOrLine) return;

    final now = DateTime.now();
    if (_lastRefresh != null &&
        now.difference(_lastRefresh!).inMilliseconds < 500) {
      return;
    }

    if (_isFetchingMore) return;
    _lastRefresh = now;
    _isFetchingMore = true;
    widget.provider.fetchData(isFetchMore: true).then((_) {
      _isFetchingMore = false;
    });
  }

  Widget _itemBuilder(BuildContext context, int index, MediaCardInfo item) {
    return VideoCard(
      video: item,
      onTap: () => widget.onItemTap?.call(index, item),
      onFocus: () => _onItemFocus(index, item),
    );
  }

  void _onKey(KeyEvent event) {
    if (event is! KeyUpEvent) return;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.contextMenu:
        _onItemMenu(_focusIndex, widget.provider[_focusIndex]);
        break;
    }
  }

  void _onItemMenu(int _, MediaCardInfo media) {
    if (widget.itemMenuActions.isEmpty) return;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black26,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (bottomCtx) {
        final actions = widget.itemMenuActions
            .asMap()
            .map(
              (index, item) => MapEntry(
                index,
                MaterialButton(
                  autofocus: index == 0,
                  onPressed: () {
                    Get.back();
                    item.action(media);
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(item.icon, size: 40),
                      Text(item.title, style: const TextStyle(fontSize: 20)),
                    ],
                  ),
                ),
              ),
            )
            .values
            .toList();
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(bottomCtx).canvasColor,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: actions,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    late SliverGridDelegate gridDelegate;
    if (widget.crossAxisCount != null) {
      gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.crossAxisCount!,
        childAspectRatio: 1 / videoCardAspectRatio,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
      );
    } else {
      gridDelegate = SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent:
            widget.maxCrossAxisExtent ?? _defaultMaxCrossAxisExtent,
        childAspectRatio: videoCardAspectRatio,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
      );
    }

    return KeyboardListener(
      focusNode: _keyboardListenerFocusNode,
      onKeyEvent: _onKey,
      child: ValueListenableBuilder(
        valueListenable: widget.provider._refreshing,
        builder: (context, loading, child) {
          return (loading && widget.refreshWidget != null)
              ? widget.refreshWidget!
              : child!;
        },
        child: AnimatedInfiniteScrollView<MediaCardInfo>(
          controller: widget.provider._ctl,
          scrollController: widget.provider._scrollCtl,
          options: AnimatedInfinitePaginationOptions(
            scrollDirection: widget.scrollDirection,
            gridDelegate: gridDelegate,
            itemBuilder: (context, MediaCardInfo item, int index) =>
                _itemBuilder(context, index, item),
            primary: widget.shrinkWrap,
            noItemsWidget: widget.noItemsWidget,
            padding: EdgeInsets.symmetric(
              horizontal: widget.scrollDirection == Axis.horizontal
                  ? widget.mainAxisSpacing
                  : widget.crossAxisSpacing,
              vertical: widget.scrollDirection == Axis.vertical
                  ? widget.mainAxisSpacing
                  : widget.crossAxisSpacing,
            ),
          ),
        ),
      ),
    );
  }
}

class ItemMenuAction {
  final String title;
  final IconData icon;
  final Function(MediaCardInfo media) action;

  ItemMenuAction({
    required this.title,
    required this.icon,
    required this.action,
  });
}
