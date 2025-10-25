import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../data/mock_data.dart';
import '../models/video_model.dart';
import '../widgets/video_card.dart';
import '../widgets/category_tab.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ScrollController _categoryScrollController = ScrollController();
  final ScrollController _videoScrollController = ScrollController();
  final FocusNode _categoryFocusNode = FocusNode();
  final List<FocusNode> _videoFocusNodes = [];

  int _selectedCategoryIndex = 0;
  List<VideoModel> _videos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _setupKeyboardNavigation();
  }

  @override
  void dispose() {
    _categoryScrollController.dispose();
    _videoScrollController.dispose();
    _categoryFocusNode.dispose();
    for (var node in _videoFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _loadVideos() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _videos = MockData.getVideoList();
        _isLoading = false;
        _videoFocusNodes.clear();
        _videoFocusNodes.addAll(
          List.generate(_videos.length, (_) => FocusNode()),
        );
      });
    });
  }

  void _setupKeyboardNavigation() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).autofocus(_categoryFocusNode);
    });
  }

  void _onCategorySelected(int index) {
    setState(() {
      _selectedCategoryIndex = index;
    });
    _loadVideos();
  }

  void _onVideoTapped(VideoModel video) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('点击了视频: ${video.title}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: RawKeyboardListener(
        focusNode: FocusNode(),
        onKey: _handleKeyEvent,
        child: Column(
          children: [_buildAppBar(), _buildCategoryTabs(), _buildVideoGrid()],
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Container(
      height: 70,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey[50]!],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pink[400]!, Colors.pink[600]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.pink.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(Icons.tv, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '哔哩哔哩 TV版',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00A1D6),
                  letterSpacing: 0.5,
                ),
              ),
              Text(
                '精彩视频，尽在掌握',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.grey[300]!),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.search, color: Colors.grey[600], size: 18),
                const SizedBox(width: 8),
                Text(
                  '搜索视频',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryTabs() {
    final categories = MockData.getCategories();

    return Container(
      height: 60,
      color: Colors.white,
      child: ListView.builder(
        controller: _categoryScrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return CategoryTab(
            title: categories[index],
            isSelected: index == _selectedCategoryIndex,
            onTap: () => _onCategorySelected(index),
          );
        },
      ),
    );
  }

  Widget _buildVideoGrid() {
    if (_isLoading) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.pink[500]!),
              ),
              const SizedBox(height: 16),
              Text(
                '加载中...',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        child: GridView.builder(
          controller: _videoScrollController,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            childAspectRatio: 300 / 280,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: _videos.length,
          itemBuilder: (context, index) {
            return FocusableWidget(
              focusNode: _videoFocusNodes[index],
              onFocusChanged: (hasFocus) {
                setState(() {});
              },
              child: VideoCard(
                video: _videos[index],
                onTap: () => _onVideoTapped(_videos[index]),
                isFocused: _videoFocusNodes[index].hasFocus,
              ),
            );
          },
        ),
      ),
    );
  }

  KeyEventResult _handleKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight ||
          event.logicalKey == LogicalKeyboardKey.arrowLeft ||
          event.logicalKey == LogicalKeyboardKey.arrowUp ||
          event.logicalKey == LogicalKeyboardKey.arrowDown) {
        return _handleArrowKey(event.logicalKey);
      }
    }
    return KeyEventResult.ignored;
  }

  KeyEventResult _handleArrowKey(LogicalKeyboardKey key) {
    final currentFocus = FocusScope.of(context).focusedChild;

    if (currentFocus != null) {
      final focusIndex = _videoFocusNodes.indexOf(currentFocus);

      switch (key) {
        case LogicalKeyboardKey.arrowRight:
          if (focusIndex < _videoFocusNodes.length - 1) {
            _videoFocusNodes[focusIndex + 1].requestFocus();
            _ensureItemVisible(focusIndex + 1);
            return KeyEventResult.handled;
          }
          break;
        case LogicalKeyboardKey.arrowLeft:
          if (focusIndex > 0) {
            _videoFocusNodes[focusIndex - 1].requestFocus();
            _ensureItemVisible(focusIndex - 1);
            return KeyEventResult.handled;
          }
          break;
        case LogicalKeyboardKey.arrowDown:
          if (focusIndex + 4 < _videoFocusNodes.length) {
            _videoFocusNodes[focusIndex + 4].requestFocus();
            _ensureItemVisible(focusIndex + 4);
            return KeyEventResult.handled;
          }
          break;
        case LogicalKeyboardKey.arrowUp:
          if (focusIndex - 4 >= 0) {
            _videoFocusNodes[focusIndex - 4].requestFocus();
            _ensureItemVisible(focusIndex - 4);
            return KeyEventResult.handled;
          } else {
            _categoryFocusNode.requestFocus();
            return KeyEventResult.handled;
          }
          break;
      }
    } else if (currentFocus == _categoryFocusNode) {
      switch (key) {
        case LogicalKeyboardKey.arrowDown:
          if (_videoFocusNodes.isNotEmpty) {
            _videoFocusNodes.first.requestFocus();
            return KeyEventResult.handled;
          }
          break;
      }
    }

    return KeyEventResult.ignored;
  }

  void _ensureItemVisible(int index) {
    final itemHeight = 280 + 16;
    final itemWidth = 300 + 16;
    final itemsPerRow = 4;

    final row = index ~/ itemsPerRow;
    final scrollOffset = row * itemHeight;

    if (_videoScrollController.hasClients) {
      final maxScrollExtent = _videoScrollController.position.maxScrollExtent;
      final viewportHeight = _videoScrollController.position.viewportDimension;

      if (scrollOffset >
          _videoScrollController.offset + viewportHeight - itemHeight * 2) {
        _videoScrollController.animateTo(
          scrollOffset - viewportHeight + itemHeight * 2,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else if (scrollOffset < _videoScrollController.offset + itemHeight) {
        var offset = (scrollOffset - itemHeight).clamp(0.0, maxScrollExtent);
        _videoScrollController.animateTo(
          offset.toDouble(),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }
}

class FocusableWidget extends StatefulWidget {
  final Widget child;
  final FocusNode focusNode;
  final Function(bool) onFocusChanged;

  const FocusableWidget({
    super.key,
    required this.child,
    required this.focusNode,
    required this.onFocusChanged,
  });

  @override
  State<FocusableWidget> createState() => _FocusableWidgetState();
}

class _FocusableWidgetState extends State<FocusableWidget> {
  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    widget.focusNode.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    widget.onFocusChanged(widget.focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(focusNode: widget.focusNode, child: widget.child);
  }
}
