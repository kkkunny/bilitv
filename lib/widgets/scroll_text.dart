import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ScrollText extends StatefulWidget {
  final String text;
  final TextStyle? style;

  const ScrollText(this.text, {super.key, this.style});

  @override
  State<ScrollText> createState() => _ScrollTextState();
}

class _ScrollTextState extends State<ScrollText> {
  late final ScrollController _scrollCtl;

  @override
  void initState() {
    super.initState();
    _scrollCtl = ScrollController();
  }

  @override
  void dispose() {
    _scrollCtl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      onKeyEvent: _onKeyEvent,
      child: Scrollbar(
        child: SingleChildScrollView(
          controller: _scrollCtl,
          child: Text(widget.text, style: widget.style),
        ),
      ),
    );
  }

  var _scrolling = false;

  KeyEventResult _onKeyEvent(FocusNode node, KeyEvent event) {
    if (_scrolling) return KeyEventResult.ignored;

    if (event is KeyDownEvent || event is KeyRepeatEvent) {
      switch (event.logicalKey) {
        case LogicalKeyboardKey.arrowUp:
          _scrolling = true;
          _scrollCtl
              .animateTo(
                _scrollCtl.offset - 200,
                duration: const Duration(milliseconds: 250),
                curve: Curves.linear,
              )
              .then((_) => _scrolling = false);
          return KeyEventResult.handled;
        case LogicalKeyboardKey.arrowDown:
          _scrolling = true;
          _scrollCtl
              .animateTo(
                _scrollCtl.offset + 200,
                duration: const Duration(milliseconds: 250),
                curve: Curves.linear,
              )
              .then((_) => _scrolling = false);
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
