import 'package:bilitv/pages/user_entry.dart';
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
  final tabChildren = [UserEntryPage(), RecommendPage()];
  late TabController _tabController;
  late List<FocusNode> _tabFocusNodes;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(vsync: this, length: tabs.length);
    _tabFocusNodes = tabs.map((e) => FocusNode()).toList();
    // 当 TabController 索引变化时刷新，以便 IndexedStack 切换显示
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      // 使用 IndexedStack 使各 tab 的子 widget 在应用启动时就被构建并保持状态
      body: IndexedStack(
        index: _tabController.index,
        children: tabChildren,
      ),
    );
  }
}
