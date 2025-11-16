import 'package:bilitv/icons/iconfont.dart';
import 'package:bilitv/pages/history.dart';
import 'package:bilitv/pages/recommend.dart';
import 'package:bilitv/pages/to_view.dart';
import 'package:bilitv/pages/user.dart';
import 'package:bilitv/storages/cookie.dart';
import 'package:bilitv/widgets/bilibili_image.dart';
import 'package:bilitv/widgets/keep_alive.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class _PageItem {
  final IconData icon;
  late final Widget child;
  final onTappedListener = ValueNotifier(0);

  _PageItem({
    required this.icon,
    required Widget Function(ValueNotifier<int>) child,
  }) {
    this.child = child(onTappedListener);
  }

  void dispose() {
    onTappedListener.dispose();
  }
}

class Page extends StatefulWidget {
  const Page({super.key});

  @override
  State<Page> createState() => _PageState();
}

class _PageState extends State<Page> with SingleTickerProviderStateMixin {
  final _tabs = [
    _PageItem(
      icon: Icons.account_circle_rounded,
      child: (listener) => UserEntryPage(listener),
    ),
    _PageItem(
      icon: Icons.history_rounded,
      child: (listener) => HistoryPage(listener),
    ),
    _PageItem(
      icon: IconFont.playlist,
      child: (listener) => ToViewPage(listener),
    ),
    _PageItem(
      icon: Icons.home_max_rounded,
      child: (listener) => KeepAliveWidget(child: RecommendPage(listener)),
    ),
  ];
  late PageController _pageController;
  late List<FocusNode> _pageFocusNodes;

  @override
  void initState() {
    _pageController = PageController(initialPage: 3);
    _pageFocusNodes = _tabs.map((e) => FocusNode()).toList();
    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    for (var tab in _tabs) {
      tab.dispose();
    }
    for (var node in _pageFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  _onTabTapped(_PageItem tab) {
    final index = _tabs.indexOf(tab);
    if (_pageController.page != index) {
      _pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      return;
    }

    tab.onTappedListener.value = DateTime.now().microsecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          FutureBuilder(
            future: Future.value(true),
            builder: (context, snap) {
              if (!snap.hasData) {
                return Container();
              }

              return Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                width: 80,
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(
                      color: Colors.pink.withValues(alpha: 0.1),
                      width: 1,
                    ),
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ListenableBuilder(
                      listenable: loginInfoNotifier,
                      builder: (context, child) {
                        return BilibiliAvatar(
                          loginInfoNotifier.value.avatar,
                          radius: 30,
                        );
                      },
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: Get.height / 4),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: _tabs
                              .map(
                                (tab) => IconButton(
                                  autofocus:
                                      _tabs.indexOf(tab) ==
                                      _pageController.initialPage,
                                  onPressed: () => _onTabTapped(tab),
                                  icon: ListenableBuilder(
                                    listenable: _pageController,
                                    builder: (context, child) => Icon(
                                      tab.icon,
                                      color:
                                          _pageController.page?.round() ==
                                              _tabs.indexOf(tab)
                                          ? Colors.pinkAccent
                                          : Colors.grey.shade400,
                                      size: 40,
                                    ),
                                  ),
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => pushTooltipInfo(context, '暂不支持该功能！'),
                      icon: Icon(Icons.settings, size: 40),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              scrollDirection: Axis.vertical,
              children: _tabs.map((tab) => tab.child).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
