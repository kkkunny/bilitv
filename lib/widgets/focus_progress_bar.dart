import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:bilitv/consts/color.dart';
import 'package:bilitv/utils/comparable.dart';
import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';

class FocusProgressBar extends StatefulWidget {
  final PlayerStream stream;
  final PlayerState state;
  final void Function(Duration)? onPositionChanged;

  const FocusProgressBar({
    super.key,
    required this.stream,
    required this.state,
    this.onPositionChanged,
  });

  @override
  State<StatefulWidget> createState() => _FocusProgressBarState();
}

class _FocusProgressBarState extends State<FocusProgressBar> {
  late final FocusScopeNode _focusScopeNode;
  late final ValueNotifier<Duration?> _currentPosition = ValueNotifier(null);

  @override
  void initState() {
    super.initState();
    _focusScopeNode = FocusScopeNode();
  }

  @override
  void dispose() {
    _focusScopeNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FocusScope(
      node: _focusScopeNode,
      onFocusChange: _onFocusChanged,
      onKeyEvent: _onKeyEvent,
      child: DpadFocusable(
        builder: FocusEffects.glow(glowColor: Colors.blue),
        child: Stack(
          children: [
            // 该bar用于在用户拖动进度时显示视频当前进度
            StreamBuilder<Duration>(
              stream: widget.stream.position,
              builder: (context, position) {
                return ProgressBar(
                  progress: position.data ?? widget.state.position,
                  buffered: widget.state.buffer,
                  total: widget.state.duration,
                  thumbColor: Colors.transparent,
                  progressBarColor: lightPink.withValues(alpha: 0.4),
                  bufferedBarColor: lightPink.withValues(alpha: 0.2),
                  timeLabelTextStyle: TextStyle(),
                );
              },
            ),
            // 该bar用于用户拖动进度
            ValueListenableBuilder(
              valueListenable: _currentPosition,
              builder: (context, value, _) {
                if (value == null) {
                  return StreamBuilder<Duration>(
                    stream: widget.stream.position,
                    builder: (context, position) {
                      return ProgressBar(
                        progress: position.data ?? widget.state.position,
                        total: widget.state.duration,
                        thumbColor: lightPink,
                        progressBarColor: lightPink,
                        timeLabelLocation: TimeLabelLocation.none,
                      );
                    },
                  );
                }
                return ProgressBar(
                  progress: value,
                  total: widget.state.duration,
                  thumbColor: lightPink,
                  progressBarColor: lightPink,
                  timeLabelLocation: TimeLabelLocation.none,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _onFocusChanged(bool focus) {
    _currentPosition.value = null;
  }

  KeyEventResult _onKeyEvent(FocusNode _, KeyEvent value) {
    if (value is KeyDownEvent || value is KeyRepeatEvent) {
      final gep = widget.state.duration ~/ 100;
      switch (value.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          final target =
              (_currentPosition.value ?? widget.state.position) - gep;
          _currentPosition.value = target.clamp(
            Duration.zero,
            widget.state.duration,
          );
          break;
        case LogicalKeyboardKey.arrowRight:
          final target =
              (_currentPosition.value ?? widget.state.position) + gep;
          _currentPosition.value = target.clamp(
            Duration.zero,
            widget.state.duration,
          );
          break;
      }
    } else if (value is KeyUpEvent) {
      switch (value.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          FocusScope.of(context).nextFocus();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          if (_currentPosition.value == null ||
              _currentPosition.value == widget.state.position) {
            break;
          }
          widget.onPositionChanged?.call(_currentPosition.value!);
          _currentPosition.value = null;
          return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }
}
