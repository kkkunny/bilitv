import 'package:bilitv/pages/qr_login_page.dart';
import 'package:bilitv/pages/rcmd_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  final tabs = [Tab(text: '我的'), Tab(text: '推荐')];
  final tabChildren = [Center(child: QRLoginPage()), RecommendPage()];
  late TabController _tabController;
  late List<FocusNode> _tabFocusNodes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    _tabFocusNodes = tabs.map((e) => FocusNode()).toList();
  }

  @override
  void dispose() {
    for (var node in _tabFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TabBar(
        controller: _tabController,
        tabs: List.generate(
          tabs.length,
          (index) => FocusableActionDetector(
            focusNode: _tabFocusNodes[index],
            autofocus: index == 1,
            child: tabs[index],
          ),
        ).toList(),
        onFocusChange: (focus, index) {
          if (!focus) return;
          _tabController.animateTo(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
          );
        },
      ),
      body: TabBarView(controller: _tabController, children: tabChildren),
    );
  }
}
