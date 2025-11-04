import 'package:bilitv/pages/to_view.dart';
import 'package:bilitv/pages/user_entry.dart';
import 'package:bilitv/pages/recommend.dart';
import 'package:flutter/material.dart';
import 'package:bilitv/widgets/keep_alive.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final _tabs = const [Tab(text: '我的'), Tab(text: '稍后再看'), Tab(text: '推荐')];
  final _tabTappedListeners = [
    ValueNotifier(0),
    ValueNotifier(0),
    ValueNotifier(0),
  ];
  late final List<Widget> _tabChildren = [
    KeepAliveWidget(child: UserEntryPage(_tabTappedListeners[0])),
    KeepAliveWidget(child: ToViewPage(_tabTappedListeners[1])),
    KeepAliveWidget(child: RecommendPage(_tabTappedListeners[2])),
  ];
  late TabController _tabController;
  late List<FocusNode> _tabFocusNodes;

  @override
  void initState() {
    _tabController = TabController(vsync: this, length: _tabs.length);
    _tabFocusNodes = _tabs.map((e) => FocusNode()).toList();
    super.initState();
  }

  @override
  void dispose() {
    _tabController.dispose();
    for (var listener in _tabTappedListeners) {
      listener.dispose();
    }
    for (var node in _tabFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  _onTabFocusChanged(focus, index) {
    if (!focus) return;
    _tabController.animateTo(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  _onTabTapped(index) {
    _tabTappedListeners[index].value = DateTime.now().microsecondsSinceEpoch;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: List.generate(
          _tabs.length,
          (index) => FocusableActionDetector(
            focusNode: _tabFocusNodes[index],
            autofocus: index == 2,
            child: _tabs[index],
          ),
        ).toList(),
        onFocusChange: _onTabFocusChanged,
        onTap: _onTabTapped,
      ),
      body: TabBarView(controller: _tabController, children: _tabChildren),
    );
  }
}
