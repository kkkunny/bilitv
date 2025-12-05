import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:bilitv/consts/color.dart';
import 'package:dpad/dpad.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';

class FocusProgressBar extends StatefulWidget {
  final Player player;

  const FocusProgressBar(this.player, {super.key});

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
              stream: widget.player.stream.position,
              builder: (context, position) {
                return ProgressBar(
                  progress: position.data ?? widget.player.state.position,
                  buffered: widget.player.state.buffer,
                  total: widget.player.state.duration,
                  thumbColor: lightPink.withValues(alpha: 0.8),
                  progressBarColor: lightPink.withValues(alpha: 0.8),
                  bufferedBarColor: lightPink.withValues(alpha: 0.3),
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
                    stream: widget.player.stream.position,
                    builder: (context, position) {
                      return ProgressBar(
                        progress: position.data ?? widget.player.state.position,
                        total: widget.player.state.duration,
                        thumbColor: lightPink,
                        progressBarColor: lightPink,
                        timeLabelLocation: TimeLabelLocation.none,
                      );
                    },
                  );
                }
                return ProgressBar(
                  progress: value,
                  total: widget.player.state.duration,
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
      switch (value.logicalKey) {
        case LogicalKeyboardKey.arrowLeft:
          _currentPosition.value =
              (_currentPosition.value ?? widget.player.state.position) -
              const Duration(seconds: 5);
          break;
        case LogicalKeyboardKey.arrowRight:
          _currentPosition.value =
              (_currentPosition.value ?? widget.player.state.position) +
              const Duration(seconds: 5);
          break;
      }
    } else if (value is KeyUpEvent) {
      switch (value.logicalKey) {
        case LogicalKeyboardKey.arrowDown:
          FocusScope.of(context).nextFocus();
          return KeyEventResult.handled;
        case LogicalKeyboardKey.select:
        case LogicalKeyboardKey.enter:
          if (_currentPosition.value != null &&
              _currentPosition.value != widget.player.state.position) {
            widget.player.seek(_currentPosition.value!);
            _currentPosition.value = null;
            return KeyEventResult.handled;
          }
          break;
      }
    }
    return KeyEventResult.ignored;
  }
}
