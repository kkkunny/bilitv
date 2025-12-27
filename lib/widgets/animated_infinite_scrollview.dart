import 'dart:async';

import 'package:animated_infinite_scroll_pagination/animated_infinite_scroll_pagination.dart';
import 'package:flutter/material.dart';
import 'package:flutterx_live_data/flutterx_live_data.dart';

class AnimatedInfiniteScrollView<T> extends StatefulWidget {
  /// instance from class that extends [AnimatedInfinitePaginationController]
  final AnimatedInfinitePaginationController<T> controller;

  /// configuration of animated infinite scrollView
  final AnimatedInfinitePaginationOptions<T> options;

  final ScrollController? scrollController;

  const AnimatedInfiniteScrollView({
    required this.controller,
    this.scrollController,
    required this.options,
    super.key,
  });

  @override
  State<AnimatedInfiniteScrollView<T>> createState() =>
      AnimatedInfiniteScrollViewState<T>();
}

class AnimatedInfiniteScrollViewState<T>
    extends State<AnimatedInfiniteScrollView<T>>
    with ObserverMixin {
  late final ScrollController scrollController;
  late final refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    scrollController = widget.scrollController ?? ScrollController();
    doRegister();
    scrollController.addListener(observeScrollOffset);
  }

  /// handle swipe refresh event
  Future<void> onRefresh() async {
    final controller = widget.controller;
    if (controller.paginationState.value.state != PaginationStateEnum.loading) {
      refreshIndicatorKey.currentState?.show();
      controller.refresh();
      await controller.fetchNewChunk();
    }
  }

  /// listen on infinite scroll
  Future<void> observeScrollOffset() async {
    final currentOffset = scrollController.offset;
    final maxOffset = scrollController.position.maxScrollExtent;

    if (currentOffset == maxOffset) {
      final controller = widget.controller;
      final page = controller.page;
      final total = controller.total;
      final paginationState = controller.paginationState.value;

      if (!(page > 1 && total == 0) &&
          paginationState.state != PaginationStateEnum.loading &&
          paginationState.state != PaginationStateEnum.error) {
        // request new chunk of data
        await controller.fetchNewChunk();
      }
    }
  }

  @override
  FutureOr<void> registerObservers() {
    widget.controller.paginationState.observe(this, observePaginationState);
  }

  void observePaginationState(PaginationState<T> paginationState) {
    final controller = widget.controller;
    if (paginationState.state == PaginationStateEnum.loading ||
        paginationState.state == PaginationStateEnum.error) {
      final items = controller.items.value;
      // jump to bottom of scrollView
      if (scrollController.hasClients &&
          items.isNotEmpty &&
          !controller.refreshing) {
        Future.delayed(
          const Duration(milliseconds: 100),
          () => scrollBy(offset: widget.options.scrollOffset),
        );
      }
    } else if (scrollController.hasClients &&
        paginationState is PaginationSuccessState &&
        controller.lastPage) {
      Future.delayed(const Duration(milliseconds: 200), scrollBy);
    }
  }

  Future<void> scrollBottom() async {
    await scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  Future<void> scrollBy({double offset = 100}) async {
    try {
      await scrollController.animateTo(
        scrollController.offset + offset,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
      );
    } catch (error) {
      debugPrint(error.toString());
    }
  }

  @override
  void dispose() {
    doUnregister();
    scrollController.removeListener(observeScrollOffset);
    if (widget.scrollController == null) {
      scrollController.dispose();
    }
    super.dispose();
  }

  Widget get animatedInfiniteScrollView {
    final options = widget.options;
    final topWidgets = widget.options.topWidgets;
    final scrollView = CustomScrollView(
      controller: scrollController,
      scrollDirection: options.scrollDirection,
      scrollBehavior: options.scrollBehavior,
      clipBehavior: options.clipBehavior,
      cacheExtent: options.cacheExtent,
      reverse: options.reverse,
      physics: options.physics,
      primary: options.primary,
      slivers: [
        /// top widget
        if (topWidgets != null)
          ...topWidgets
              .map(
                (topWidget) => topWidget.isSliver
                    ? topWidget.child
                    : SliverToBoxAdapter(child: topWidget.child),
              )
              .toList(),

        /// custom sliver child
        if (options.itemBuilder == null && options.customSliverChild != null)
          LiveDataBuilder(
            data: widget.controller.items,
            builder: (context, items) =>
                options.customSliverChild!(context, items),
          ),

        /// gridView
        if (options.itemBuilder != null && options.gridDelegate != null)
          SliverPadding(
            padding: options.padding,
            sliver: AnimatedInfiniteGridView(
              controller: widget.controller,
              options: widget.options,
            ),
          ),

        /// listView
        if (options.itemBuilder != null && options.gridDelegate == null)
          SliverPadding(
            padding: options.padding,
            sliver: AnimatedInfiniteListView(
              controller: widget.controller,
              options: widget.options,
            ),
          ),

        /// footer
        SliverToBoxAdapter(
          child: AnimatedInfinitePaginationFooterWidget(
            controller: widget.controller,
            options: widget.options,
          ),
        ),
      ],
    );

    return Stack(
      children: [
        /// fill viewPort
        options.scrollbar == true
            ? Scrollbar(controller: scrollController, child: scrollView)
            : scrollView,

        /// center state widget
        Positioned.fill(
          child: AnimatedInfiniteCenterWidget(
            controller: widget.controller,
            options: widget.options,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return widget.options.refreshIndicator
        ? RefreshIndicator(
            onRefresh: onRefresh,
            key: refreshIndicatorKey,
            child: animatedInfiniteScrollView,
          )
        : animatedInfiniteScrollView;
  }
}
