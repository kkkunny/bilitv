import 'package:animated_infinite_scroll_pagination/animated_infinite_scroll_pagination.dart';
import 'package:bilitv/models/video.dart';
import 'package:bilitv/widgets/video_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class _VideoGridViewController
    with AnimatedInfinitePaginationController<MediaCardInfo> {
  final bool Function() onHasMore;
  final Future<void> Function({bool isFetchMore}) onLoad;

  _VideoGridViewController({required this.onHasMore, required this.onLoad});

  @override
  get lastPage => onHasMore();

  @override
  bool areItemsTheSame(MediaCardInfo a, MediaCardInfo b) {
    return a.avid == b.avid;
  }

  @override
  Future<void> fetchData(int page) async => onLoad(isFetchMore: page == 1);
}

class VideoGridViewProvider {
  late final _ctl = _VideoGridViewController(
    onHasMore: _onHasMore,
    onLoad: fetchData,
  );
  final List<MediaCardInfo> _videos = [];
  Future<(List<MediaCardInfo>, bool)> Function({bool isFetchMore})? onLoad;
  late bool _hasMore = onLoad == null;

  VideoGridViewProvider({this.onLoad});

  List<MediaCardInfo> toList() => _videos.map((e) => e).toList();

  operator [](int index) => _videos[index];

  int get length => _videos.length;

  bool get isEmpty => _videos.isEmpty;

  bool get isNotEmpty => _videos.isNotEmpty;

  void addAll(Iterable<MediaCardInfo> iterable) {
    _videos.addAll(iterable);
    _ctl.emitState(PaginationSuccessState(iterable.toList(), cached: false));
    _ctl.setTotal(_videos.length);
  }

  void clear() {
    _videos.clear();
    _ctl.refresh();
  }

  bool _onHasMore() => _hasMore;

  Future<void> fetchData({bool isFetchMore = false}) async {
    if (onLoad == null) return;

    _ctl.emitState(const PaginationLoadingState());

    final (newVideos, hasMore) = await onLoad!(isFetchMore: isFetchMore);
    _hasMore = !hasMore;
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
  });

  @override
  State<VideoGridView<T>> createState() => _VideoGridViewState<T>();
}

class _VideoGridViewState<T> extends State<VideoGridView<T>> {
  int focusIndex = 0;
  final _keyboardListenerFocusNode = FocusNode(canRequestFocus: false);

  @override
  void dispose() {
    super.dispose();
    _keyboardListenerFocusNode.dispose();
  }

  Widget _itemBuilder(BuildContext context, int index, MediaCardInfo item) {
    return VideoCard(
      video: item,
      onTap: () => widget.onItemTap?.call(index, item),
      onFocus: () {
        focusIndex = index;
        widget.onItemFocus?.call(index, item);
      },
    );
  }

  void _onKey(KeyEvent event) {
    if (event is! KeyUpEvent) return;
    switch (event.logicalKey) {
      case LogicalKeyboardKey.contextMenu:
        _onItemMenu(focusIndex, widget.provider[focusIndex]);
        break;
    }
  }

  void _onItemMenu(int _, MediaCardInfo media) {
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
        maxCrossAxisExtent: widget.maxCrossAxisExtent ?? 400,
        childAspectRatio: videoCardAspectRatio,
        mainAxisSpacing: widget.mainAxisSpacing,
        crossAxisSpacing: widget.crossAxisSpacing,
      );
    }

    late Widget gridWidget;
    if (widget.shrinkWrap) {
      gridWidget = GridView.builder(
        scrollDirection: widget.scrollDirection,
        shrinkWrap: widget.shrinkWrap,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: gridDelegate,
        itemCount: widget.provider.length,
        itemBuilder: (context, index) =>
            _itemBuilder(context, index, widget.provider[index]),
      );
    } else {
      gridWidget = AnimatedInfiniteScrollView<MediaCardInfo>(
        controller: widget.provider._ctl,
        options: AnimatedInfinitePaginationOptions(
          scrollDirection: widget.scrollDirection,
          gridDelegate: gridDelegate,
          itemBuilder: (context, MediaCardInfo item, int index) =>
              _itemBuilder(context, index, item),
        ),
      );
    }

    return KeyboardListener(
      focusNode: _keyboardListenerFocusNode,
      onKeyEvent: _onKey,
      child: gridWidget,
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
