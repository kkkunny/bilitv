import 'package:flutter/material.dart';

Widget buildLoadingStyle1() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/loading/loading1.gif"),
        const SizedBox(height: 16),
        const Text(
          '加载中...',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    ),
  );
}

Widget buildLoadingStyle3() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset("assets/images/loading/loading3.gif"),
        const SizedBox(height: 16),
        const Text(
          '加载中...',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      ],
    ),
  );
}

class LoadingWidget<T> extends StatefulWidget {
  final ValueNotifier<bool>? isLoading;
  final Future<T> Function() loader;
  final Widget Function(BuildContext, T) builder;
  final Widget loadingWidget;

  const LoadingWidget({
    super.key,
    required this.loader,
    required this.builder,
    required this.loadingWidget,
    this.isLoading,
  });

  @override
  State<LoadingWidget<T>> createState() => _LoadingWidgetState<T>();
}

class _LoadingWidgetState<T> extends State<LoadingWidget<T>> {
  late final ValueNotifier<bool> _isLoading;
  late T _data;

  @override
  void initState() {
    super.initState();
    _isLoading = widget.isLoading ?? ValueNotifier(true);
    widget.loader().then((data) {
      _data = data;
      _isLoading.value = false;
    });
  }

  @override
  void dispose() {
    if (widget.isLoading == null) _isLoading.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _isLoading,
      builder: (context, isLoading, _) {
        if (isLoading) return widget.loadingWidget;
        return widget.builder(context, _data);
      },
    );
  }
}
