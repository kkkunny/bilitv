import 'dart:async';

import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:bilitv/apis/bilibili/client.dart' show bilibiliHttpClient;
import 'package:bilitv/apis/bilibili/history.dart';
import 'package:bilitv/apis/bilibili/media.dart' show getVideoPlayURL;
import 'package:bilitv/consts/bilibili.dart' show VideoQuality;
import 'package:bilitv/consts/color.dart';
import 'package:bilitv/icons/iconfont.dart';
import 'package:bilitv/models/video.dart' as model;
import 'package:bilitv/storages/cookie.dart';
import 'package:bilitv/storages/settings.dart';
import 'package:bilitv/widgets/bilibili_danmaku_wall.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:toastification/toastification.dart';

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
    if (event is! KeyUpEvent) {
      return KeyEventResult.ignored;
    }

    switch (event.logicalKey) {
      case LogicalKeyboardKey.goBack:
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
  late final player = widget.state.widget.controller.player;
  Timer? _nextTimer; // 播放下一个视频的计时器

  @override
  void initState() {
    player.stream.completed.listen(_onCompleted);
    super.initState();
  }

  void _onDanmakuSwitchTapped() {
    pageState.danmakuCtl.enabled = !pageState.danmakuCtl.enabled;
    Settings.setBool(Settings.pathDanmuSwitch, pageState.danmakuCtl.enabled);
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

  void _onPrevTapped() {
    final index = pageState.widget.video.episodes.indexWhere(
      (e) => e.cid == pageState.currentCid.value,
    );
    if (index == 0) return;

    pageState.currentCid.value = pageState.widget.video.episodes[index - 1].cid;
  }

  void _onPlayOrPauseTapped() {
    player.playOrPause();
  }

  void _onNextTapped() {
    final index = pageState.widget.video.episodes.indexWhere(
      (e) => e.cid == pageState.currentCid.value,
    );
    if (index == pageState.widget.video.episodes.length - 1) return;

    pageState.currentCid.value = pageState.widget.video.episodes[index + 1].cid;
  }

  void _onCompleted(bool completed) {
    if (!completed) {
      if (_nextTimer != null) {
        _nextTimer!.cancel();
        _nextTimer = null;
      }
      return;
    }

    final index = pageState.widget.video.episodes.indexWhere(
      (e) => e.cid == pageState.currentCid.value,
    );
    if (index == pageState.widget.video.episodes.length - 1) return;

    _nextTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_nextTimer != null) {
        _nextTimer!.cancel();
        _nextTimer = null;
      }
      pageState.currentCid.value =
          pageState.widget.video.episodes[index + 1].cid;
    });

    toastification.show(
      context: context,
      closeButtonShowType: CloseButtonShowType.none,
      style: ToastificationStyle.simple,
      alignment: Alignment.centerRight,
      backgroundColor: Colors.white10.withValues(alpha: 0.5),
      borderSide: BorderSide(width: 0),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text('即将播放下一分P'),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.displayListener,
      builder: (context, _, child) {
        return widget.displayListener.value ? child! : Container();
      },
      child: Column(
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
              child: Column(
                children: [
                  StreamBuilder<Duration>(
                    stream: player.stream.position,
                    builder: (context, position) {
                      return ProgressBar(
                        progress: position.data ?? player.state.position,
                        buffered: player.state.buffer,
                        total: player.state.duration,
                        progressBarColor: lightPink,
                        bufferedBarColor: lightPink.withValues(alpha: 0.3),
                        thumbColor: lightPink,
                        timeLabelTextStyle: TextStyle(),
                      );
                    },
                  ),
                  Row(
                    children: [
                      IconButton(
                        focusColor: Colors.grey.withValues(alpha: 0.2),
                        onPressed: _onPrevTapped,
                        icon: Icon(
                          Icons.skip_previous_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      StreamBuilder<bool>(
                        stream: player.stream.playing,
                        builder: (context, playing) => IconButton(
                          autofocus: true,
                          focusColor: Colors.grey.withValues(alpha: 0.2),
                          onPressed: _onPlayOrPauseTapped,
                          icon: Icon(
                            playing.data ?? player.state.playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 44,
                          ),
                        ),
                      ),
                      IconButton(
                        focusColor: Colors.grey.withValues(alpha: 0.2),
                        onPressed: _onNextTapped,
                        icon: Icon(
                          Icons.skip_next_rounded,
                          color: Colors.white,
                          size: 44,
                        ),
                      ),
                      Spacer(),
                      IconButton(
                        focusColor: Colors.grey.withValues(alpha: 0.2),
                        onPressed: _onDanmakuSwitchTapped,
                        icon: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.0),
                          child: ValueListenableBuilder(
                            valueListenable:
                                pageState.danmakuCtl.enableNotifier,
                            builder: (context, isEnabled, _) => Icon(
                              isEnabled
                                  ? IconFont.danmukai
                                  : IconFont.danmuguanbi,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      IconButton(
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
      ),
    );
  }
}

// 视频播放页
class VideoPlayerPage extends StatefulWidget {
  final model.Video video;
  final int cid;

  const VideoPlayerPage({super.key, required this.video, required this.cid});

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final currentCid = ValueNotifier(widget.cid);
  final allowQualities = VideoQuality.values
      .where((e) => !e.needLogin || loginInfoNotifier.value.isLogin)
      .toList();
  late final currentQuality = ValueNotifier(VideoQuality.vq1080P);

  late final controller = VideoController(Player());
  final danmakuCtl = BilibiliDanmakuWallController();

  FocusNode screenFocusNode = FocusNode();
  final ValueNotifier<bool> displayControl = ValueNotifier(false);

  Timer? heartbeatTimer; // 播放心跳timer

  @override
  void initState() {
    currentCid.addListener(_onEpisodeChanged);
    currentQuality.addListener(_onQualityChange);
    controller.player.stream.completed.listen((v) {
      if (v) _onPlayCompleted();
    });
    _loadSettings();
    super.initState();
    _onEpisodeChanged();
  }

  @override
  void dispose() {
    if (heartbeatTimer != null) heartbeatTimer!.cancel();
    currentCid.dispose();
    currentQuality.dispose();
    screenFocusNode.dispose();
    controller.player.dispose();
    danmakuCtl.dispose();
    displayControl.dispose();
    super.dispose();
  }

  void _loadSettings() {
    Settings.getBool(Settings.pathDanmuSwitch).then((v) {
      danmakuCtl.enabled = v ?? true;
    });
  }

  DateTime? _lastBackTime;

  void _onBack(didPop) {
    if (didPop || !mounted || displayControl.value) return;

    final now = DateTime.now();
    if (_lastBackTime != null && now.difference(_lastBackTime!).inSeconds < 2) {
      // 上报播放进度
      if (loginInfoNotifier.value.isLogin) {
        reportPlayProgress(
          widget.video.avid,
          currentCid.value,
          controller.player.state.position,
        );
      }
      return Get.back();
    }
    _lastBackTime = now;

    pushTooltipInfo(
      context,
      '再按一次返回退出播放',
      duration: const Duration(seconds: 2),
    );
  }

  Future<void> _onEpisodeChanged() async {
    // 结束心跳
    if (heartbeatTimer != null) {
      heartbeatTimer!.cancel();
    }
    // 上报播放进度
    if (loginInfoNotifier.value.isLogin &&
        controller.player.state.position.inSeconds > 0) {
      reportPlayProgress(
        widget.video.avid,
        currentCid.value,
        controller.player.state.position,
      );
    }
    reportPlayStart(widget.video.avid, currentCid.value);

    MediaPlayInfo? playInfo;
    // 若已登陆，获取播放进度
    if (loginInfoNotifier.value.isLogin) {
      try {
        playInfo = await getMediaPlayInfo(
          avid: widget.video.avid,
          cid: currentCid.value,
        );
      } catch (_) {}
    }

    final infos = await getVideoPlayURL(
      avid: widget.video.avid,
      cid: currentCid.value,
      quality: currentQuality.value.index,
    );
    await controller.player.open(
      Media(
        infos.first.urls.first,
        httpHeaders: bilibiliHttpClient.options.headers.cast<String, String>(),
        start: playInfo?.lastPlayTime,
      ),
    );

    // 开始心跳
    heartbeatTimer = Timer(Duration(seconds: 15), _onHeartbeat);
  }

  void _onHeartbeat() {
    if (!loginInfoNotifier.value.isLogin) return;
    reportPlayHeartbeat(
      avid: widget.video.avid,
      cid: currentCid.value,
      progress: controller.player.state.position,
    );
  }

  Future<void> _onQualityChange() async {
    final infos = await getVideoPlayURL(
      avid: widget.video.avid,
      cid: currentCid.value,
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

  void _onPlayCompleted() {
    // 上报播放进度
    if (loginInfoNotifier.value.isLogin) {
      reportPlayProgress(
        widget.video.avid,
        currentCid.value,
        controller.player.state.position,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: _onBack,
      child: Scaffold(
        body: KeyboardListener(
          autofocus: true,
          focusNode: screenFocusNode,
          onKeyEvent: _onKeyEvent,
          child: ValueListenableBuilder(
            valueListenable: currentCid,
            builder: (context, cid, child) => BilibiliDanmakuWall(
              controller: danmakuCtl,
              cid: cid,
              timeline: controller.player.stream.position,
              playing: controller.player.stream.playing,
              child: child!,
            ),
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
    if (value is! KeyUpEvent) {
      return;
    }

    if (displayControl.value) {
      switch (value.logicalKey) {
        case LogicalKeyboardKey.goBack:
          // 延迟50ms是为了确保_onBack先被调用，这样_onBack里才能拿到此时的displayControl.value的值而不是这里修改后的
          Future.delayed(Duration(milliseconds: 10)).then((_) {
            displayControl.value = false;
          });
          break;
        case LogicalKeyboardKey.contextMenu:
          displayControl.value = false;
          break;
      }
      return;
    }

    switch (value.logicalKey) {
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
        controller.player.playOrPause();
        break;
      case LogicalKeyboardKey.contextMenu:
        displayControl.value = true;
        break;
      case LogicalKeyboardKey.arrowLeft:
        _onStepForward(false);
        break;
      case LogicalKeyboardKey.arrowRight:
        _onStepForward(true);
        break;
    }
  }

  static const _step = Duration(seconds: 5);
  static const _danmakuWaitDurationOnStep = Duration(seconds: 10);

  void _onStepForward(bool forward) {
    if (forward) {
      if (controller.player.state.duration - controller.player.state.position <
          _step) {
        controller.player.seek(controller.player.state.duration);
      } else {
        controller.player.seek(controller.player.state.position + _step);
      }
    } else {
      if (controller.player.state.position < _step) {
        controller.player.seek(Duration(seconds: 0));
      } else {
        controller.player.seek(controller.player.state.position - _step);
      }
    }
    danmakuCtl.wait(_danmakuWaitDurationOnStep);
    danmakuCtl.clear();
  }
}
