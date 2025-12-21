import 'package:flutter/material.dart';

class FocusDropdownButton<T> extends StatefulWidget {
  final T? initialValue;
  final List<DropdownMenuItem<T>> allowValues;
  final void Function(T?)? onChanged;
  final Widget? icon;
  final Color? focusColor;
  final Color? dropdownColor;

  const FocusDropdownButton({
    super.key,
    this.initialValue,
    required this.allowValues,
    this.onChanged,
    this.icon,
    this.focusColor,
    this.dropdownColor,
  });

  @override
  State<FocusDropdownButton<T>> createState() => _FocusDropdownButtonState<T>();
}

class _FocusDropdownButtonState<T> extends State<FocusDropdownButton<T>> {
  late final FocusNode focusNode;
  late final ValueNotifier<bool> isFocused;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    isFocused = ValueNotifier(focusNode.hasFocus);
    focusNode.addListener(() {
      isFocused.value = focusNode.hasFocus;
    });
  }

  @override
  void dispose() {
    isFocused.dispose();
    focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: isFocused,
      builder: (context, value, child) {
        if (value && widget.focusColor != null) {
          return Container(
            decoration: BoxDecoration(
              color: widget.focusColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: child,
          );
        } else {
          return Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12)),
            child: child,
          );
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Row(
          children: [
            widget.icon ?? const SizedBox(),
            DropdownButton<T>(
              focusNode: focusNode,
              icon: const SizedBox(),
              underline: const SizedBox(),
              onChanged: widget.onChanged,
              value: widget.initialValue,
              items: widget.allowValues,
              dropdownColor: widget.dropdownColor,
            ),
          ],
        ),
      ),
    );
  }
}
