import 'package:flutter/material.dart';

class LoadingWidget<T> extends StatefulWidget {
  final ValueNotifier<bool>? isLoading;
  final Future<T> Function() loader;
  final Widget Function(BuildContext, T) builder;

  const LoadingWidget({
    super.key,
    required this.loader,
    required this.builder,
    this.isLoading,
  });

  @override
  State<LoadingWidget<T>> createState() => _LoadingWidgetState<T>();
}

class _LoadingWidgetState<T> extends State<LoadingWidget<T>> {
  late final ValueNotifier<bool> _isLoading =
      widget.isLoading ?? ValueNotifier(true);
  late T _data;

  @override
  void initState() {
    super.initState();
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
        if (isLoading) return _buildLoading();
        return widget.builder(context, _data);
      },
    );
  }

  Widget _buildLoading() {
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
}

class LoadingPage<T> extends StatelessWidget {
  final Future<T> Function() _loader;
  final Widget Function(BuildContext, T) _builder;

  const LoadingPage({
    super.key,
    required Future<T> Function() loader,
    required Widget Function(BuildContext, T) builder,
  }) : _builder = builder,
       _loader = loader;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LoadingWidget(loader: _loader, builder: _builder),
    );
  }
}
