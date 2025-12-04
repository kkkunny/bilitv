import 'dart:async';

import 'package:bilitv/apis/bilibili/client.dart' show bilibiliHttpClient;
import 'package:bilitv/apis/bilibili/history.dart';
import 'package:bilitv/apis/bilibili/media.dart' show getVideoPlayURL;
import 'package:bilitv/consts/bilibili.dart' show VideoQuality;
import 'package:bilitv/consts/settings.dart';
import 'package:bilitv/icons/iconfont.dart';
import 'package:bilitv/models/video.dart' as model;
import 'package:bilitv/storages/auth.dart';
import 'package:bilitv/storages/settings.dart';
import 'package:bilitv/widgets/bilibili_danmaku_wall.dart';
import 'package:bilitv/widgets/focus_progress_bar.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:toastification/toastification.dart';

const _step = Duration(seconds: 5);
const _danmakuWaitDuration = Duration(seconds: 10);

// 清晰度选择组件
class _SelectQualityWidget extends StatelessWidget {
  final OverlayEntry overlayEntry;
  final _VideoPlayerPageState pageState;

  const _SelectQualityWidget(this.overlayEntry, this.pageState);

  void _onSelectQuality(VideoQuality quality) {
    pageState._currentQuality.value = quality;
    overlayEntry.remove();
  }

  @override
  Widget build(BuildContext context) {
    final selects = pageState._allowQualities
        .map(
          (e) => Container(
            padding: EdgeInsets.symmetric(vertical: 4),
            width: 320,
            child: ElevatedButton(
              autofocus: e == pageState._currentQuality.value,
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
            child: Column(mainAxisSize: MainAxisSize.min, children: children),
          ),
        ),
      ),
    );
  }
}

// 视频控件
class _VideoControlWidget extends StatefulWidget {
  final Player player;

  const _VideoControlWidget(this.player);

  @override
  State<_VideoControlWidget> createState() => _VideoControlWidgetState();
}

class _VideoControlWidgetState extends State<_VideoControlWidget> {
  late _VideoPlayerPageState _pageState;
  Timer? _nextTimer; // 播放下一个视频的计时器

  @override
  void initState() {
    super.initState();
    widget.player.stream.completed.listen(_onCompleted);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _pageState = context.findAncestorStateOfType<_VideoPlayerPageState>()!;
  }

  void _onDanmakuSwitchTapped() {
    _pageState._danmakuCtl.enabled = !_pageState._danmakuCtl.enabled;
    Settings.setBool(Settings.pathDanmuSwitch, _pageState._danmakuCtl.enabled);
  }

  void _onSelectQuality() {
    OverlayState? overlayState = Overlay.of(context);
    late OverlayEntry overlayEntry;
    overlayEntry = OverlayEntry(
      builder: (BuildContext context) {
        return _SelectQualityWidget(overlayEntry, _pageState);
      },
    );
    overlayState.insert(overlayEntry);
  }

  void _onPrevTapped() {
    final index = _pageState.widget.video.episodes.indexWhere(
      (e) => e.cid == _pageState._currentCid.value,
    );
    if (index == 0) return;

    _pageState._currentCid.value =
        _pageState.widget.video.episodes[index - 1].cid;
  }

  void _onPlayOrPauseTapped() {
    widget.player.playOrPause();
  }

  void _onNextTapped() {
    final index = _pageState.widget.video.episodes.indexWhere(
      (e) => e.cid == _pageState._currentCid.value,
    );
    if (index == _pageState.widget.video.episodes.length - 1) return;

    _pageState._currentCid.value =
        _pageState.widget.video.episodes[index + 1].cid;
  }

  void _onCompleted(bool completed) {
    if (!completed) {
      if (_nextTimer != null) {
        _nextTimer!.cancel();
        _nextTimer = null;
      }
      return;
    }

    final index = _pageState.widget.video.episodes.indexWhere(
      (e) => e.cid == _pageState._currentCid.value,
    );
    if (index == _pageState.widget.video.episodes.length - 1) return;

    _nextTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (_nextTimer != null) {
        _nextTimer!.cancel();
        _nextTimer = null;
      }
      _pageState._currentCid.value =
          _pageState.widget.video.episodes[index + 1].cid;
    });

    if (!mounted) {
      return;
    }
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
    return FocusScope(
      autofocus: true,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20, top: 20),
            child: Text(
              _pageState.widget.video.title,
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
            child: Column(
              children: [
                FocusProgressBar(widget.player),
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
                      stream: widget.player.stream.playing,
                      builder: (context, playing) => IconButton(
                        autofocus: true,
                        focusColor: Colors.grey.withValues(alpha: 0.2),
                        onPressed: _onPlayOrPauseTapped,
                        icon: Icon(
                          playing.data ?? widget.player.state.playing
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
                              _pageState._danmakuCtl.enableNotifier,
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
                              _pageState._currentQuality.value.name,
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
        ],
      ),
    );
  }
}

// 视频播放页
class VideoPlayerPage extends StatefulWidget {
  final model.Video video;
  final int cid;

  final bool danmu;
  final bool ha;
  final VideoOutputDrivers vo;
  final HardwareVideoDecoder hwdec;

  const VideoPlayerPage({
    super.key,
    required this.video,
    required this.cid,
    required this.danmu,
    required this.ha,
    required this.vo,
    required this.hwdec,
  });

  @override
  State<VideoPlayerPage> createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  late final ValueNotifier<int> _currentCid;
  final _allowQualities = VideoQuality.values
      .where((e) => !e.needLogin || loginInfoNotifier.value.isLogin)
      .toList();
  late final ValueNotifier<VideoQuality> _currentQuality;

  late final VideoController _controller;
  late final BilibiliDanmakuWallController _danmakuCtl;

  late final FocusNode _screenFocusNode;
  late final ValueNotifier<bool> _displayControl;

  Timer? _heartbeatTimer; // 播放心跳timer

  @override
  void initState() {
    super.initState();
    _currentCid = ValueNotifier(widget.cid);
    _currentCid.addListener(_onEpisodeChanged);
    _currentQuality = ValueNotifier(VideoQuality.vq1080P);
    _currentQuality.addListener(_onQualityChange);
    _controller = VideoController(
      Player(),
      configuration: VideoControllerConfiguration(
        vo: widget.vo.value,
        hwdec: widget.hwdec.value,
        enableHardwareAcceleration: widget.ha,
      ),
    );
    _controller.player.stream.completed.listen((v) {
      if (v) _onPlayCompleted();
    });
    _danmakuCtl = BilibiliDanmakuWallController(widget.danmu);
    _screenFocusNode = FocusNode();
    _displayControl = ValueNotifier(false);
    _onEpisodeChanged();
  }

  @override
  void dispose() {
    if (_heartbeatTimer != null) _heartbeatTimer!.cancel();
    _displayControl.dispose();
    _screenFocusNode.dispose();
    _danmakuCtl.dispose();
    _controller.player.dispose();
    _currentQuality.dispose();
    _currentCid.dispose();
    super.dispose();
  }

  DateTime? _lastBackTime;

  void _onBack(didPop) {
    if (didPop || !mounted || _displayControl.value) return;

    final now = DateTime.now();
    if (_lastBackTime != null && now.difference(_lastBackTime!).inSeconds < 2) {
      // 上报播放进度
      if (loginInfoNotifier.value.isLogin) {
        reportPlayProgress(
          widget.video.avid,
          _currentCid.value,
          _controller.player.state.position,
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
    if (_heartbeatTimer != null) {
      _heartbeatTimer!.cancel();
    }
    // 上报播放进度
    if (loginInfoNotifier.value.isLogin &&
        _controller.player.state.position.inSeconds > 0) {
      reportPlayProgress(
        widget.video.avid,
        _currentCid.value,
        _controller.player.state.position,
      );
    }
    reportPlayStart(widget.video.avid, _currentCid.value);
    // 暂停弹幕
    final danmakuEnabled = _danmakuCtl.enabled;
    _danmakuCtl.enabled = false;

    MediaPlayInfo? playInfo;
    // 若已登陆，获取播放进度
    if (loginInfoNotifier.value.isLogin) {
      try {
        final lastPlayInfo = await getMediaPlayInfo(
          avid: widget.video.avid,
          cid: _currentCid.value,
        );
        if (_currentCid.value == lastPlayInfo.lastPlayCid) {
          playInfo = lastPlayInfo;
        }
      } catch (_) {}
    }

    final infos = await getVideoPlayURL(
      avid: widget.video.avid,
      cid: _currentCid.value,
      quality: _currentQuality.value.index,
    );
    await _controller.player.open(
      Media(
        infos.first.urls.first,
        httpHeaders: bilibiliHttpClient.options.headers.cast<String, String>(),
        start: playInfo?.lastPlayTime,
      ),
    );

    // 开始心跳
    _heartbeatTimer = Timer(Duration(seconds: 15), _onHeartbeat);
    // 恢复弹幕
    _danmakuCtl.enabled = danmakuEnabled;
  }

  void _onHeartbeat() {
    if (!loginInfoNotifier.value.isLogin) return;
    reportPlayHeartbeat(
      avid: widget.video.avid,
      cid: _currentCid.value,
      progress: _controller.player.state.position,
    );
  }

  Future<void> _onQualityChange() async {
    // 暂停弹幕
    final danmakuEnabled = _danmakuCtl.enabled;
    _danmakuCtl.enabled = false;

    final infos = await getVideoPlayURL(
      avid: widget.video.avid,
      cid: _currentCid.value,
      quality: _currentQuality.value.index,
    );
    await _controller.player.open(
      Media(
        infos.first.urls.first,
        httpHeaders: bilibiliHttpClient.options.headers.cast<String, String>(),
        start: _controller.player.state.position,
      ),
    );

    // 恢复弹幕
    _danmakuCtl.enabled = danmakuEnabled;
  }

  void _onPlayCompleted() {
    // 上报播放进度
    if (loginInfoNotifier.value.isLogin) {
      reportPlayProgress(
        widget.video.avid,
        _currentCid.value,
        _controller.player.state.position,
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
          focusNode: _screenFocusNode,
          onKeyEvent: _onKeyEvent,
          child: Stack(
            children: [
              Video(controller: _controller, controls: NoVideoControls),
              ValueListenableBuilder(
                valueListenable: _currentCid,
                builder: (context, cid, child) => BilibiliDanmakuWall(
                  controller: _danmakuCtl,
                  cid: cid,
                  timeline: _controller.player.stream.position,
                  playing: _controller.player.stream.playing,
                ),
              ),
              ValueListenableBuilder(
                valueListenable: _displayControl,
                builder: (context, display, child) {
                  return display ? child! : Container();
                },
                child: _VideoControlWidget(_controller.player),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onKeyEvent(KeyEvent value) {
    if (!_displayControl.value) {
      if (value is KeyDownEvent || value is KeyRepeatEvent) {
        switch (value.logicalKey) {
          case LogicalKeyboardKey.arrowLeft:
            _onStepForward(false);
            break;
          case LogicalKeyboardKey.arrowRight:
            _onStepForward(true);
            break;
        }
      }
    }

    if (value is! KeyUpEvent) {
      return;
    }

    if (_displayControl.value) {
      switch (value.logicalKey) {
        case LogicalKeyboardKey.goBack:
          // 延迟50ms是为了确保_onBack先被调用，这样_onBack里才能拿到此时的displayControl.value的值而不是这里修改后的
          Future.delayed(Duration(milliseconds: 10)).then((_) {
            _displayControl.value = false;
          });
          break;
        case LogicalKeyboardKey.contextMenu:
          _displayControl.value = false;
          break;
      }
      return;
    }

    switch (value.logicalKey) {
      case LogicalKeyboardKey.select:
      case LogicalKeyboardKey.enter:
        _controller.player.playOrPause();
        break;
      case LogicalKeyboardKey.contextMenu:
        _displayControl.value = true;
        break;
    }
  }

  void _onStepForward(bool forward) {
    if (forward) {
      if (_controller.player.state.duration -
              _controller.player.state.position <
          _step) {
        _controller.player.seek(_controller.player.state.duration);
      } else {
        _controller.player.seek(_controller.player.state.position + _step);
      }
    } else {
      if (_controller.player.state.position < _step) {
        _controller.player.seek(Duration(seconds: 0));
      } else {
        _controller.player.seek(_controller.player.state.position - _step);
      }
    }
    _danmakuCtl.wait(_danmakuWaitDuration);
    _danmakuCtl.clear();
  }
}
