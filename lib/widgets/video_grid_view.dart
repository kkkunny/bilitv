import 'package:animated_infinite_scroll_pagination/animated_infinite_scroll_pagination.dart';
import 'package:bilitv/models/video.dart';
import 'package:bilitv/widgets/video_card.dart';
import 'package:flutter/material.dart';

class VideoGridViewProvider
    with AnimatedInfinitePaginationController<MediaCardInfo> {
  final List<MediaCardInfo> _videos = [];
  Future<(List<MediaCardInfo>, bool)> Function({bool isFetchMore})? onLoad;
  late bool _hasMore = onLoad == null;

  VideoGridViewProvider({this.onLoad});

  List<MediaCardInfo> toList() => _videos;

  operator [](int index) => _videos[index];

  get length => _videos.length;
  get isEmpty => _videos.isEmpty;
  get isNotEmpty => _videos.isNotEmpty;

  void addAll(Iterable<MediaCardInfo> iterable) {
    _videos.addAll(iterable);
    emitState(PaginationSuccessState(iterable.toList(), cached: false));
    setTotal(_videos.length);
  }

  void clear() {
    _videos.clear();
    items.postValue([]);
    setTotal(0);
  }

  @override
  get lastPage => _hasMore;

  @override
  bool areItemsTheSame(MediaCardInfo a, MediaCardInfo b) {
    return a.avid == b.avid;
  }

  @override
  Future<void> fetchData(int page) async {
    if (onLoad == null) return;

    emitState(const PaginationLoadingState());

    final (newVideos, hasMore) = await onLoad!(isFetchMore: page == 1);
    _hasMore = !hasMore;
    addAll(newVideos);
  }
}

class VideoGridView extends StatelessWidget {
  final VideoGridViewProvider provider;
  final bool shrinkWrap;
  final void Function(MediaCardInfo)? onTap;
  final void Function()? onScrollEnd;

  const VideoGridView({
    super.key,
    required this.provider,
    this.shrinkWrap = false,
    this.onTap,
    this.onScrollEnd,
  });

  Widget itemBuilder(BuildContext context, MediaCardInfo item) {
    return VideoCard(
      video: item,
      onTap: onTap == null ? null : () => onTap!(item),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gridDelegate = const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: videoCardWidth,
      childAspectRatio: 1.1,
      mainAxisSpacing: 20,
      crossAxisSpacing: 20,
    );

    if (shrinkWrap) {
      return GridView.builder(
        shrinkWrap: shrinkWrap,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: gridDelegate,
        itemCount: provider.length,
        itemBuilder: (context, index) => itemBuilder(context, provider[index]),
      );
    }

    return AnimatedInfiniteScrollView<MediaCardInfo>(
      controller: provider,
      options: AnimatedInfinitePaginationOptions(
        gridDelegate: gridDelegate,
        itemBuilder: (context, MediaCardInfo item, _) =>
            itemBuilder(context, item),
      ),
    );
  }
}
