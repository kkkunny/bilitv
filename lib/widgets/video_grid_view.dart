import 'package:animated_infinite_scroll_pagination/animated_infinite_scroll_pagination.dart';
import 'package:bilitv/models/video.dart';
import 'package:bilitv/widgets/video_card.dart';
import 'package:flutter/material.dart';

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

  List<MediaCardInfo> toList() => _videos;

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

class VideoGridView extends StatelessWidget {
  final VideoGridViewProvider provider;
  final bool shrinkWrap;
  final void Function(int index, MediaCardInfo item)? onTap;
  final void Function(int index, MediaCardInfo item)? onFocus;

  const VideoGridView({
    super.key,
    required this.provider,
    this.shrinkWrap = false,
    this.onTap,
    this.onFocus,
  });

  Widget itemBuilder(BuildContext context, int index, MediaCardInfo item) {
    return VideoCard(
      video: item,
      onTap: onTap == null ? null : () => onTap!(index, item),
      onFocus: onFocus == null ? null : () => onFocus!(index, item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridDelegate = SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 5,
      childAspectRatio: videoCardAspectRatio,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
    );

    if (shrinkWrap) {
      return GridView.builder(
        shrinkWrap: shrinkWrap,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: gridDelegate,
        itemCount: provider.length,
        itemBuilder: (context, index) =>
            itemBuilder(context, index, provider[index]),
      );
    }

    return AnimatedInfiniteScrollView<MediaCardInfo>(
      controller: provider._ctl,
      options: AnimatedInfinitePaginationOptions(
        gridDelegate: gridDelegate,
        itemBuilder: (context, MediaCardInfo item, int index) =>
            itemBuilder(context, index, item),
      ),
    );
  }
}
