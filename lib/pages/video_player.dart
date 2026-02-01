import 'dart:async';

import 'package:bilitv/apis/bilibili/client.dart' show bilibiliHttpClient;
import 'package:bilitv/apis/bilibili/history.dart';
import 'package:bilitv/apis/bilibili/media.dart'
    show getVideoPlayURL, GetVideoPlayURLResponse, Quality, DashData;
import 'package:bilitv/consts/settings.dart';
import 'package:bilitv/icons/iconfont.dart';
import 'package:bilitv/models/video.dart' as model;
import 'package:bilitv/storages/auth.dart';
import 'package:bilitv/storages/settings.dart';
import 'package:bilitv/utils/stream.dart';
import 'package:bilitv/widgets/bilibili_danmaku_wall.dart';
import 'package:bilitv/widgets/focus_dropdown_button.dart';
import 'package:bilitv/widgets/focus_progress_bar.dart';
import 'package:bilitv/widgets/loading.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:toastification/toastification.dart';

const _step = Duration(seconds: 5);
const _danmakuWaitDuration = Duration(seconds: 5);

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

  void _onSelectQuality(Quality? sf) {
    if (sf == null) {
      return;
    }
    Settings.setInt(Settings.pathQualitySwitch, sf.id);
    setState(() {
      _pageState._onQualityChange(sf);
    });
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

  void onPositionChanged(Duration pos) {
    widget.player.seek(pos);
    _pageState._danmakuCtl.wait(_danmakuWaitDuration);
    _pageState._danmakuCtl.clear();
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
                FocusProgressBar(
                  stream: widget.player.stream,
                  state: widget.player.state,
                  onPositionChanged: onPositionChanged,
                ),
                Row(
                  children: [
                    IconButton(
                      focusColor: Colors.pinkAccent.withValues(alpha: 0.5),
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
                        focusColor: Colors.pinkAccent.withValues(alpha: 0.5),
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
                      focusColor: Colors.pinkAccent.withValues(alpha: 0.5),
                      onPressed: _onNextTapped,
                      icon: Icon(
                        Icons.skip_next_rounded,
                        color: Colors.white,
                        size: 44,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      focusColor: Colors.pinkAccent.withValues(alpha: 0.5),
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
                    FocusDropdownButton<Quality>(
                      icon: Icon(
                        Icons.high_quality_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                      focusColor: Colors.pinkAccent.withValues(alpha: 0.5),
                      dropdownColor: Colors.pinkAccent.shade100,
                      initialValue: _pageState._currentQuality,
                      allowValues: _pageState._videoPlayURLInfo.supportFormats
                          .map(
                            (e) => DropdownMenuItem<Quality>(
                              value: e,
                              child: Text(
                                e.description,
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: _onSelectQuality,
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
  late GetVideoPlayURLResponse _videoPlayURLInfo;
  late Quality _currentQuality;

  late final VideoController _controller;
  late final BilibiliDanmakuWallController _danmakuCtl;

  late final FocusNode _screenFocusNode;
  late final ValueNotifier<bool> _displayControl;

  Timer? _heartbeatTimer; // 播放心跳timer
  late final StreamController<bool> loading;

  @override
  void initState() {
    super.initState();
    _currentCid = ValueNotifier(widget.cid);
    _currentCid.addListener(_onEpisodeChanged);
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
    _controller.player.stream.error.listen(_onPlayError);
    _danmakuCtl = BilibiliDanmakuWallController(widget.danmu);
    _screenFocusNode = FocusNode();
    _displayControl = ValueNotifier(false);
    loading = StreamController<bool>();
    _onEpisodeChanged();
  }

  @override
  void dispose() {
    if (_heartbeatTimer != null) _heartbeatTimer!.cancel();
    loading.close();
    _displayControl.dispose();
    _screenFocusNode.dispose();
    _danmakuCtl.dispose();
    _controller.player.dispose();
    _currentCid.dispose();
    super.dispose();
  }

  void _onPlayError(String err) {
    if (_audioUrls.isNotEmpty && err.contains(_audioUrls.first)) {
      if (!err.contains('Can not open external file')) {
        return;
      }
      _audioUrls.removeAt(0);
      if (_audioUrls.isEmpty) {
        pushTooltipError(context, "音频加载失败");
      } else {
        _controller.player.setAudioTrack(AudioTrack.uri(_audioUrls.first));
      }
      return;
    }
    pushTooltipError(context, err);
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
        ).ignore();
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
    loading.sink.add(true);
    try {
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
        ).ignore();
      }
      reportPlayStart(widget.video.avid, _currentCid.value).ignore();
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

      _videoPlayURLInfo = await tooltipNetFetch(
        context,
        () => getVideoPlayURL(avid: widget.video.avid, cid: _currentCid.value),
      );

      final qualityID =
          await Settings.getInt(Settings.pathQualitySwitch) ??
          _videoPlayURLInfo.defaultQualityID;
      _currentQuality = _videoPlayURLInfo.supportFormats.firstWhere(
        (e) => e.id == qualityID,
      );
      await _playDashMedia(
        _videoPlayURLInfo.dashData,
        start: playInfo?.lastPlayTime,
      );

      // 开始心跳
      _heartbeatTimer = Timer(Duration(seconds: 15), _onHeartbeat);
      // 恢复弹幕
      _danmakuCtl.enabled = danmakuEnabled;
    } catch (_) {
    } finally {
      loading.sink.add(false);
    }
  }

  void _onHeartbeat() {
    if (!loginInfoNotifier.value.isLogin) return;
    reportPlayHeartbeat(
      avid: widget.video.avid,
      cid: _currentCid.value,
      progress: _controller.player.state.position,
    ).ignore();
  }

  Future<void> _onQualityChange(Quality sf) async {
    if (_currentQuality.id == sf.id) return;
    _currentQuality = sf;

    // 暂停弹幕
    final danmakuEnabled = _danmakuCtl.enabled;
    _danmakuCtl.enabled = false;

    loading.sink.add(true);
    try {
      await _playDashMedia(
        _videoPlayURLInfo.dashData,
        start: _controller.player.state.position,
      );
    } catch (_) {
    } finally {
      loading.sink.add(false);
    }

    // 恢复弹幕
    _danmakuCtl.enabled = danmakuEnabled;
  }

  var _videoUrls = [];
  var _audioUrls = [];

  Future<void> _playDashMedia(DashData media, {Duration? start}) async {
    var video = _videoPlayURLInfo.dashData.video.firstWhere(
      (e) => e.quality == _currentQuality.id,
    );
    var videoUrls = [video.baseUrl];
    videoUrls.addAll(video.backupUrls);
    var audioUrls = _videoPlayURLInfo.dashData.audio.mapMany((e) {
      var urls = [e.baseUrl];
      urls.addAll(e.backupUrls);
      return urls;
    }).toList();

    _videoUrls.clear();
    _audioUrls.clear();
    Future.wait([
      _controller.player.open(
        Media(
          videoUrls.first,
          httpHeaders: bilibiliHttpClient.options.headers
              .cast<String, String>(),
          start: start,
        ),
      ),
      _controller.player.setAudioTrack(AudioTrack.uri(audioUrls.first)),
    ]).ignore();
    _videoUrls = videoUrls;
    _audioUrls = audioUrls;
  }

  void _onPlayCompleted() {
    // 上报播放进度
    if (loginInfoNotifier.value.isLogin) {
      reportPlayProgress(
        widget.video.avid,
        _currentCid.value,
        _controller.player.state.position,
      ).ignore();
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
              StreamBuilder<bool>(
                stream: combineBoolStream(
                  _controller.player.stream.buffering,
                  loading.stream,
                ),
                builder: (context, buffering) => (buffering.data ?? false)
                    ? buildLoadingStyle3()
                    : const SizedBox(),
              ),
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
                  return display
                      ? _VideoControlWidget(_controller.player)
                      : const SizedBox();
                },
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
