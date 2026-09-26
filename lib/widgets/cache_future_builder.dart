import 'package:flutter/material.dart';

class CacheFutureBuilder<T> extends StatefulWidget {
  const CacheFutureBuilder({
    super.key,
    required this.future,
    this.initialData,
    required this.builder,
  });

  final Future<T> Function() future;
  final AsyncWidgetBuilder<T> builder;
  final T? initialData;

  @override
  State<CacheFutureBuilder<T>> createState() => _CacheFutureBuilder();
}

class _CacheFutureBuilder<T> extends State<CacheFutureBuilder<T>> {
  late final Future<T> _future;

  @override
  void initState() {
    super.initState();
    _future = widget.future();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: widget.builder,
      initialData: widget.initialData,
    );
  }
}
