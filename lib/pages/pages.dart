import 'package:bilitv/icons/iconfont.dart';
import 'package:bilitv/pages/dynamic.dart';
import 'package:bilitv/pages/history.dart';
import 'package:bilitv/pages/recommend.dart';
import 'package:bilitv/pages/search.dart';
import 'package:bilitv/pages/setting.dart';
import 'package:bilitv/pages/to_view.dart';
import 'package:bilitv/pages/user.dart';
import 'package:bilitv/storages/auth.dart';
import 'package:bilitv/widgets/bilibili_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_lazy_indexed_stack/flutter_lazy_indexed_stack.dart';
import 'package:get/get.dart';

class _PageItem {
  final IconData icon;
  late final Widget child;
  late final bool homePage;

  final onTappedListener = ValueNotifier(0);

  _PageItem({
    required this.icon,
    required Widget Function(ValueNotifier<int>) child,
    this.homePage = false,
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

class _PageState extends State<Page> {
  late final List<_PageItem> _tabs;
  late ValueNotifier<int> _currentPageIndex;
  late List<FocusNode> _pageFocusNodes;

  @override
  void initState() {
    super.initState();
    _tabs = [
      _PageItem(
        icon: Icons.account_circle_rounded,
        child: (listener) => UserEntryPage(listener),
      ),
      _PageItem(icon: Icons.search_rounded, child: (listener) => SearchPage()),
      _PageItem(
        icon: Icons.history_rounded,
        child: (listener) => HistoryPage(listener),
      ),
      _PageItem(
        icon: IconFont.trends,
        child: (listener) => DynamicPage(listener),
      ),
      _PageItem(
        icon: IconFont.playlist,
        child: (listener) => ToViewPage(listener),
      ),
      _PageItem(
        icon: Icons.home_max_rounded,
        child: (listener) => RecommendPage(listener),
        homePage: true,
      ),
    ];
    _pageFocusNodes = _tabs.map((e) => FocusNode()).toList();
    _currentPageIndex = ValueNotifier(_tabs.lastIndexWhere((e) => e.homePage));
  }

  @override
  void dispose() {
    _currentPageIndex.dispose();
    for (var node in _pageFocusNodes) {
      node.dispose();
    }
    for (var tab in _tabs) {
      tab.dispose();
    }
    super.dispose();
  }

  _onTabTapped(_PageItem tab) {
    final index = _tabs.indexOf(tab);
    if (_currentPageIndex.value != index) {
      _currentPageIndex.value = index;
    } else {
      tab.onTappedListener.value = DateTime.now().microsecondsSinceEpoch;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Container(
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
                    padding: EdgeInsets.symmetric(vertical: Get.height / 6),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: _tabs
                          .map(
                            (tab) => IconButton(
                              autofocus:
                                  _tabs.indexOf(tab) == _currentPageIndex.value,
                              onPressed: () => _onTabTapped(tab),
                              icon: ValueListenableBuilder(
                                valueListenable: _currentPageIndex,
                                builder: (context, index, _) => Icon(
                                  tab.icon,
                                  color: _tabs.indexOf(tab) == index
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
                  onPressed: () => Get.to(const SettingPage()),
                  icon: const Icon(Icons.settings, size: 40),
                ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder(
              valueListenable: _currentPageIndex,
              builder: (context, index, _) {
                return LazyIndexedStack(
                  index: index,
                  children: _tabs.map((tab) => tab.child).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
