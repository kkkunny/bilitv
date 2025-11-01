import 'package:bilitv/apis/bilibili/client.dart' show bilibiliHttpClient;
import 'package:bilitv/apis/bilibili/media.dart' show getVideoPlayURL;
import 'package:bilitv/consts/bilibili.dart' show VideoQuality;
import 'package:bilitv/models/video.dart';
import 'package:bilitv/storages/cookie.dart';
import 'package:bilitv/utils/format.dart' show videoDurationString;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

// 清晰度选择组件
class _SelectQualityWidget extends StatefulWidget {
  final OverlayEntry overlayEntry;
  final _VideoPlayerPageState pageState;

  const _SelectQualityWidget(this.overlayEntry, this.pageState);

  @override
  State<_SelectQualityWidget> createState() => _SelectQualityWidgetState();
}

class _SelectQualityWidgetState extends State<_SelectQualityWidget> {
  late List<FocusNode> qualityFocusNodes = widget.pageState.allowQualities
      .map((e) => FocusNode())
      .toList();

  @override
  void initState() {
    super.initState();
    final currentQualityIndex = widget.pageState.allowQualities.indexOf(
      widget.pageState.currentQuality.value,
    );
    qualityFocusNodes[currentQualityIndex].requestFocus();
  }

  @override
  void dispose() {
    for (var e in qualityFocusNodes) {
      e.dispose();
    }
    super.dispose();
  }

  void _onSelectQuality(VideoQuality quality) {
    widget.pageState.currentQuality.value = quality;
    widget.overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    int index = 0;
    final selects = widget.pageState.allowQualities
        .map(
          (e) => Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            width: 320,
            child: ElevatedButton(
              autofocus: e == widget.pageState.currentQuality.value,
              focusNode: qualityFocusNodes[index++],
              onPressed: () => _onSelectQuality(e),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white10,
                foregroundColor: Colors.white,
                overlayColor: Colors.blue,
                padding: EdgeInsets.symmetric(vertical: 14),
                textStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              child: Text(e.name),
            ),
          ),
        )
        .toList();

    final children = [
      Text('选择清晰度', style: TextStyle(color: Colors.white70, fontSize: 20)),
      SizedBox(height: 8),
    ];
    children.addAll(selects);

    return Center(
      child: Material(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(24),
          child: FocusScope(
            autofocus: true,
            onKeyEvent: _onKeyEvent,
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
      ),
    );
  }

  KeyEventResult _onKeyEvent(focusNode, event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.goBack:
      case LogicalKeyboardKey.escape:
        widget.overlayEntry.remove();
        return KeyEventResult.handled;
      case LogicalKeyboardKey.arrowUp:
        final focusIndex = qualityFocusNodes.indexWhere((e) => e.hasFocus);
        if (focusIndex > 0) {
          FocusScope.of(
            context,
          ).requestFocus(qualityFocusNodes[focusIndex - 1]);
          return KeyEventResult.handled;
        }
        break;
      case LogicalKeyboardKey.arrowDown:
        final focusIndex = qualityFocusNodes.indexWhere((e) => e.hasFocus);
        if (focusIndex < qualityFocusNodes.length - 1) {
          FocusScope.of(
            context,
          ).requestFocus(qualityFocusNodes[focusIndex + 1]);
          return KeyEventResult.handled;
        }
        break;
    }
    return KeyEventResult.ignored;
  }
}

// 视频控件
class _VideoControlWidget extends StatefulWidget {
  final VideoState state;
  final ValueNotifier<bool> displayListener;

  const _VideoControlWidget(this.state, this.displayListener);

  @override
  State<_VideoControlWidget> createState() => _VideoControlWidgetState();
}

class _VideoControlWidgetState extends State<_VideoControlWidget> {
  late _VideoPlayerPageState pageState = context
      .findAncestorStateOfType<_VideoPlayerPageState>()!;
  FocusNode playButtonFocusNode = FocusNode();
  FocusNode qualityButtonFocusNode = FocusNode();

  @override
  void initState() {
    widget.displayListener.addListener(_onDisplayChanged);
    super.initState();
  }

  @override
  void dispose() {
    playButtonFocusNode.dispose();
    qualityButtonFocusNode.dispose();
    super.dispose();
  }

  void _onDisplayChanged() {
    setState(() {});
  }

  void _onSelectQuality() {
    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _SelectQualityWidget(overlayEntry, pageState);
      },
    );
    overlayState.insert(overlayEntry);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.displayListener.value) {
      return Container();
    }

    final player = widget.state.widget.controller.player;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20),
          child: Text(
            pageState.widget.video.title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(
          color: Colors.black.withValues(alpha: 0.5),
          padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
          child: FocusScope(
            autofocus: true,
            onKeyEvent: _onKeyEvent,
            child: Column(
              children: [
                StreamBuilder<Duration>(
                  stream: player.stream.position,
                  builder: (context, snap) {
                    final position = snap.data ?? player.state.position;
                    final duration = player.state.duration;
                    final percent = duration.inMilliseconds > 0
                        ? position.inMilliseconds / duration.inMilliseconds
                        : 0.0;
                    return Column(
                      children: [
                        LinearProgressIndicator(
                          value: percent,
                          backgroundColor: Colors.grey.shade200.withValues(
                            alpha: 0.5,
                          ),
                          valueColor: AlwaysStoppedAnimation(Colors.blue),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              videoDurationString(position),
                              style: const TextStyle(color: Colors.white70),
                            ),
                            Text(
                              videoDurationString(duration),
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    StreamBuilder<bool>(
                      stream: player.stream.playing,
                      builder: (context, playing) => IconButton(
                        autofocus: true,
                        focusNode: playButtonFocusNode,
                        focusColor: Colors.grey.withValues(alpha: 0.2),
                        onPressed: () => player.playOrPause(),
                        icon: Icon(
                          playing.data == false
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                    ),
                    IconButton(
                      focusNode: qualityButtonFocusNode,
                      focusColor: Colors.grey.withValues(alpha: 0.2),
                      onPressed: _onSelectQuality,
                      icon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5.0),
                        child: Row(
                          children: [
                            Icon(
                              Icons.high_quality_rounded,
                              color: Colors.white,
                            ),
                            SizedBox(width: 5),
                            Text(
                              pageState.currentQuality.value.name,
                              style: TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  KeyEventResult _onKeyEvent(focusNode, event) {
    if (event is KeyUpEvent) {
      return KeyEventResult.handled;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.goBack:
      case LogicalKeyboardKey.escape:
        pageState.displayControl.value = false;
        break;
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
        if (playButtonFocusNode.hasFocus) {
          final player = widget.state.widget.controller.player;
          player.playOrPause();
        } else if (qualityButtonFocusNode.hasFocus) {
          _onSelectQuality();
        }
        break;
      case LogicalKeyboardKey.arrowLeft:
        if (qualityButtonFocusNode.hasFocus) {
          playButtonFocusNode.requestFocus();
        }
        break;
      case LogicalKeyboardKey.arrowRight:
        if (playButtonFocusNode.hasFocus) {
          qualityButtonFocusNode.requestFocus();
        }
        break;
    }
    return KeyEventResult.handled;
  }
}

// 视频播放页
class VideoPlayerPage extends StatefulWidget {
  final VideoInfo video;

  const VideoPlayerPage({super.key, required this.video});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final allowQualities = VideoQuality.values
      .where((e) => !e.needLogin || loginNotifier.value)
      .toList();
  late ValueNotifier<VideoQuality> currentQuality = ValueNotifier<VideoQuality>(
    allowQualities.last,
  );

  late final controller = VideoController(Player());

  FocusNode screenFocusNode = FocusNode();
  final ValueNotifier<bool> displayControl = ValueNotifier(false);

  @override
  void initState() {
    currentQuality.addListener(_onQualityChange);
    super.initState();
    _onQualityChange();
  }

  @override
  void dispose() {
    currentQuality.dispose();
    screenFocusNode.dispose();
    controller.player.dispose();
    displayControl.dispose();
    super.dispose();
  }

  _onQualityChange() async {
    final infos = await getVideoPlayURL(
      avid: widget.video.avid,
      cid: widget.video.cid,
      quality: currentQuality.value.index,
    );
    await controller.player.open(
      Media(
        infos.first.urls.first,
        httpHeaders: bilibiliHttpClient.options.headers.cast<String, String>(),
        start: controller.player.state.position,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          child: KeyboardListener(
            autofocus: true,
            focusNode: screenFocusNode,
            onKeyEvent: _onKeyEvent,
            child: Video(
              controller: controller,
              controls: (VideoState state) =>
                  _VideoControlWidget(state, displayControl),
            ),
          ),
        ),
      ),
    );
  }

  void _onKeyEvent(KeyEvent value) {
    if (value.runtimeType == KeyUpEvent) {
      return;
    }

    final step = Duration(seconds: 5);
    switch (value.logicalKey) {
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
        controller.player.playOrPause();
        break;
      case LogicalKeyboardKey.contextMenu:
      case LogicalKeyboardKey.superKey:
        displayControl.value = true;
        break;
      case LogicalKeyboardKey.goBack:
      case LogicalKeyboardKey.escape:
        if (displayControl.value) {
          displayControl.value = false;
        } else {
          Navigator.of(context).pop();
        }
        break;
      case LogicalKeyboardKey.arrowLeft:
        if (controller.player.state.position < step) {
          controller.player.seek(Duration(seconds: 0));
        } else {
          controller.player.seek(controller.player.state.position - step);
        }
        break;
      case LogicalKeyboardKey.arrowRight:
        if (controller.player.state.duration -
                controller.player.state.position <
            step) {
          controller.player.seek(controller.player.state.duration);
        } else {
          controller.player.seek(controller.player.state.position + step);
        }
        break;
    }
  }
}
