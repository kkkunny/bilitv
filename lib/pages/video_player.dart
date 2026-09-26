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
import 'package:bilitv/utils/ui_scale.dart';
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
  final ValueNotifier<bool> displayControl;

  const _VideoControlWidget(this.player, this.displayControl);

  @override
  State<_VideoControlWidget> createState() => _VideoControlWidgetState();
}

class _VideoControlWidgetState extends State<_VideoControlWidget> {
  late _VideoPlayerPageState _pageState;
  final _playFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.displayControl.addListener(_onDisplayControlChanged);
  }

  @override
  void dispose() {
    widget.displayControl.removeListener(_onDisplayControlChanged);
    _playFocusNode.dispose();
    super.dispose();
  }

  void _onDisplayControlChanged() {
    if (!widget.displayControl.value) {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.displayControl.value) {
        return;
      }
      _playFocusNode.requestFocus();
    });
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

  Future<void> _onSelectQuality(Quality? sf) async {
    if (sf == null) {
      return;
    }
    Settings.setInt(Settings.pathQualitySwitch, sf.id);
    await _pageState._onQualityChange(sf);
    if (!mounted) {
      return;
    }
    // 画质切换成功后刷新下拉框显示值
    setState(() {});
  }

  void _onPrevTapped() {
    final index = _pageState.widget.video.episodes.indexWhere(
      (e) => e.cid == _pageState._currentCid.value,
    );
    if (index <= 0) return;

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
    if (index < 0 || index == _pageState.widget.video.episodes.length - 1) {
      return;
    }

    _pageState._currentCid.value =
        _pageState.widget.video.episodes[index + 1].cid;
  }

  void onPositionChanged(Duration pos) {
    widget.player.seek(pos);
    _pageState._cancelAutoNext();
    _pageState._danmakuCtl.wait(_danmakuWaitDuration);
    _pageState._danmakuCtl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final ui = context.ui;
    return FocusScope(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: 20 * ui,
              right: 20 * ui,
              top: 20 * ui,
            ),
            child: Text(
              _pageState.widget.video.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 26 * ui,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            color: Colors.black.withValues(alpha: 0.5),
            padding: EdgeInsets.only(
              left: 20 * ui,
              right: 20 * ui,
              bottom: 20 * ui,
            ),
            child: Column(
              children: [
                FocusProgressBar(
                  player: widget.player,
                  onPositionChanged: onPositionChanged,
                ),
                Row(
                  children: [
                    ValueListenableBuilder<int>(
                      valueListenable: _pageState._currentCid,
                      builder: (context, cid, child) {
                        final index = _pageState.widget.video.episodes
                            .indexWhere((e) => e.cid == cid);
                        final isFirst = index <= 0;
                        return Opacity(
                          opacity: isFirst ? 0.4 : 1,
                          child: IconButton(
                            focusColor: Colors.pinkAccent.withValues(
                              alpha: 0.5,
                            ),
                            padding: EdgeInsets.all(8 * ui),
                            onPressed: isFirst ? null : _onPrevTapped,
                            icon: Icon(
                              Icons.skip_previous_rounded,
                              color: Colors.white,
                              size: 44 * ui,
                            ),
                          ),
                        );
                      },
                    ),
                    StreamBuilder<bool>(
                      stream: widget.player.stream.playing,
                      builder: (context, playing) => IconButton(
                        focusNode: _playFocusNode,
                        focusColor: Colors.pinkAccent.withValues(alpha: 0.5),
                        padding: EdgeInsets.all(8 * ui),
                        onPressed: _onPlayOrPauseTapped,
                        icon: Icon(
                          playing.data ?? widget.player.state.playing
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 44 * ui,
                        ),
                      ),
                    ),
                    ValueListenableBuilder<int>(
                      valueListenable: _pageState._currentCid,
                      builder: (context, cid, child) {
                        final episodes = _pageState.widget.video.episodes;
                        final index = episodes.indexWhere((e) => e.cid == cid);
                        final isLast =
                            index < 0 || index == episodes.length - 1;
                        return Opacity(
                          opacity: isLast ? 0.4 : 1,
                          child: IconButton(
                            focusColor: Colors.pinkAccent.withValues(
                              alpha: 0.5,
                            ),
                            padding: EdgeInsets.all(8 * ui),
                            onPressed: isLast ? null : _onNextTapped,
                            icon: Icon(
                              Icons.skip_next_rounded,
                              color: Colors.white,
                              size: 44 * ui,
                            ),
                          ),
                        );
                      },
                    ),
                    const Spacer(),
                    IconButton(
                      focusColor: Colors.pinkAccent.withValues(alpha: 0.5),
                      padding: EdgeInsets.all(8 * ui),
                      onPressed: _onDanmakuSwitchTapped,
                      icon: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 5 * ui),
                        child: ValueListenableBuilder(
                          valueListenable:
                              _pageState._danmakuCtl.enableNotifier,
                          builder: (context, isEnabled, _) => Icon(
                            isEnabled
                                ? IconFont.danmukai
                                : IconFont.danmuguanbi,
                            color: Colors.white,
                            size: 24 * ui,
                          ),
                        ),
                      ),
                    ),
                    ValueListenableBuilder<bool>(
                      valueListenable: _pageState._videoReady,
                      builder: (context, ready, child) => Opacity(
                        opacity: ready ? 1 : 0.5,
                        child: FocusDropdownButton<Quality>(
                          icon: Icon(
                            Icons.high_quality_outlined,
                            color: Colors.white,
                            size: 28 * ui,
                          ),
                          focusColor: Colors.pinkAccent.withValues(alpha: 0.5),
                          dropdownColor: Colors.pinkAccent.shade100,
                          initialValue: ready
                              ? _pageState._currentQuality
                              : null,
                          allowValues: ready
                              ? _pageState._videoPlayURLInfo.supportFormats
                                    .map(
                                      (e) => DropdownMenuItem<Quality>(
                                        value: e,
                                        child: Text(
                                          e.description,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 20 * ui,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList()
                              : const [],
                          onChanged: ready ? _onSelectQuality : null,
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
  late GetVideoPlayURLResponse _videoPlayURLInfo;
  late Quality _currentQuality;
  late int _playingCid; // 当前实际播放的分P，用于进度上报，避免与_currentCid错配

  late final VideoController _controller;
  late final BilibiliDanmakuWallController _danmakuCtl;

  late final FocusNode _screenFocusNode;
  late final ValueNotifier<bool> _displayControl;

  Timer? _heartbeatTimer; // 播放心跳timer
  Timer? _autoNextTimer; // 播完自动切下一分P的计时器
  late final StreamController<bool> loading;

  // memoize合并流，避免rebuild时StreamBuilder对单订阅loading流重新订阅
  late final Stream<bool> _bufferingOrLoading = combineBoolStream(
    _controller.player.stream.buffering,
    loading.stream,
  );
  StreamSubscription<bool>? _completedSub;
  StreamSubscription<String>? _errorSub;
  final _videoReady = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    _currentCid = ValueNotifier(widget.cid);
    _currentCid.addListener(_onEpisodeChanged);
    _playingCid = widget.cid;
    _controller = VideoController(
      Player(),
      configuration: VideoControllerConfiguration(
        vo: widget.vo.value,
        hwdec: widget.hwdec.value,
        enableHardwareAcceleration: widget.ha,
      ),
    );
    _completedSub = _controller.player.stream.completed.listen((v) {
      if (v) _onPlayCompleted();
    });
    _errorSub = _controller.player.stream.error.listen(_onPlayError);
    _danmakuCtl = BilibiliDanmakuWallController(widget.danmu);
    _screenFocusNode = FocusNode();
    _displayControl = ValueNotifier(false);
    _displayControl.addListener(_onDisplayControlChanged);
    loading = StreamController<bool>();
    _onEpisodeChanged();
  }

  @override
  void dispose() {
    if (_heartbeatTimer != null) _heartbeatTimer!.cancel();
    _cancelAutoNext();
    _completedSub?.cancel();
    _errorSub?.cancel();
    if (!loading.isClosed) loading.close();
    _displayControl.removeListener(_onDisplayControlChanged);
    _displayControl.dispose();
    _videoReady.dispose();
    _screenFocusNode.dispose();
    _danmakuCtl.dispose();
    _controller.player.dispose();
    _currentCid.dispose();
    super.dispose();
  }

  void _onDisplayControlChanged() {
    if (_displayControl.value) {
      return;
    }
    _screenFocusNode.requestFocus();
  }

  void _onPlayError(String err) {
    if (!mounted) return;
    // 视频源失败：仅在"无法打开"类错误时轮换到下一个备份地址，其他错误直接提示
    if (_videoUrls.isNotEmpty && err.contains(_videoUrls.first)) {
      if (!err.contains('Can not open external file')) {
        pushTooltipError(context, '视频加载失败');
        return;
      }
      _videoUrls.removeAt(0);
      if (_videoUrls.isEmpty) {
        pushTooltipError(context, '视频加载失败');
        return;
      }
      _restartPlayback().ignore();
      return;
    }
    // 音频源失败：轮换到下一个备份地址
    if (_audioUrls.isNotEmpty && err.contains(_audioUrls.first)) {
      if (!err.contains('Can not open external file')) {
        pushTooltipError(context, "音频加载失败");
        return;
      }
      _audioUrls.removeAt(0);
      if (_audioUrls.isEmpty) {
        pushTooltipError(context, "音频加载失败");
        return;
      }
      _controller.player
          .setAudioTrack(AudioTrack.uri(_audioUrls.first))
          .ignore();
      return;
    }
    pushTooltipError(context, err);
  }

  // 切换视频备份地址后重新打开媒体，保留播放进度、弹幕时间轴与音轨
  Future<void> _restartPlayback() async {
    if (_videoUrls.isEmpty) return;
    final start = _controller.player.state.position;
    // 重置弹幕时间轴，避免重开后按旧时间轴推送导致长时间无弹幕
    _danmakuCtl.clear();
    try {
      await _controller.player.open(
        Media(
          _videoUrls.first,
          httpHeaders: bilibiliHttpClient.options.headers
              .cast<String, String>(),
          start: start,
        ),
      );
      if (_audioUrls.isNotEmpty) {
        await _controller.player.setAudioTrack(
          AudioTrack.uri(_audioUrls.first),
        );
      }
    } catch (_) {
      // 打开失败会通过错误流再次触发轮换
    }
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
          _playingCid,
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
    // 快照本次请求的分P，若处理过程中用户又切了分P则丢弃本次结果
    final cid = _currentCid.value;
    // 新分P就绪前禁止画质等操作，避免用到旧分P的播放信息
    _videoReady.value = false;
    // 结束心跳
    _heartbeatTimer?.cancel();
    // 取消待执行的自动下一分P
    _cancelAutoNext();
    // 上报上一分P的播放进度（使用实际播放中的cid，避免切P后cid与位置错配）
    if (loginInfoNotifier.value.isLogin &&
        _controller.player.state.position.inSeconds > 0) {
      reportPlayProgress(
        widget.video.avid,
        _playingCid,
        _controller.player.state.position,
      ).ignore();
    }
    reportPlayStart(widget.video.avid, cid).ignore();
    // 暂停弹幕
    final danmakuEnabled = _danmakuCtl.enabled;
    _danmakuCtl.enabled = false;

    var success = false;
    if (!loading.isClosed) loading.sink.add(true);
    try {
      MediaPlayInfo? playInfo;
      // 若已登陆，获取播放进度
      if (loginInfoNotifier.value.isLogin) {
        try {
          final lastPlayInfo = await getMediaPlayInfo(
            avid: widget.video.avid,
            cid: cid,
          );
          if (cid == lastPlayInfo.lastPlayCid) {
            playInfo = lastPlayInfo;
          }
        } catch (_) {}
        if (!mounted || cid != _currentCid.value) return;
      }

      final info = await getVideoPlayURL(avid: widget.video.avid, cid: cid);
      if (!mounted || cid != _currentCid.value) return;
      if (info.supportFormats.isEmpty) {
        throw Exception('该视频暂无可播放清晰度');
      }

      final qualityID =
          await Settings.getInt(Settings.pathQualitySwitch) ??
          info.defaultQualityID;
      // 用户设置的画质不可用时依次回退到默认画质、第一个可用画质
      final quality = info.supportFormats.firstWhere(
        (e) => e.id == qualityID,
        orElse: () => info.supportFormats.firstWhere(
          (e) => e.id == info.defaultQualityID,
          orElse: () => info.supportFormats.first,
        ),
      );
      // 打开媒体前再校验一次分P未变，避免并发切P时旧请求最后执行覆盖新请求
      if (!mounted || cid != _currentCid.value) return;

      await _playDashMedia(
        info.dashData,
        quality,
        start: playInfo?.lastPlayTime,
      );
      if (!mounted || cid != _currentCid.value) return;

      // 播放成功后才提交状态，失败时保持旧画质/旧播放信息不变
      _videoPlayURLInfo = info;
      _currentQuality = quality;
      _videoReady.value = true;
      success = true;
      // 开始周期心跳（每15秒上报一次，切P/退出时取消）
      _heartbeatTimer = Timer.periodic(
        const Duration(seconds: 15),
        (_) => _onHeartbeat(),
      );
    } catch (e) {
      if (mounted) pushTooltipError(context, e.toString());
    } finally {
      if (!loading.isClosed) loading.sink.add(false);
      // 仅当前分P的请求仍有效时恢复弹幕，避免旧请求覆盖新请求的状态
      if (mounted && cid == _currentCid.value) {
        _danmakuCtl.enabled = danmakuEnabled;
        if (success) _playingCid = cid;
      }
    }
  }

  void _onHeartbeat() {
    if (!loginInfoNotifier.value.isLogin) return;
    reportPlayHeartbeat(
      avid: widget.video.avid,
      cid: _playingCid,
      progress: _controller.player.state.position,
    ).ignore();
  }

  Future<void> _onQualityChange(Quality sf) async {
    if (!mounted || _currentQuality.id == sf.id) return;
    // 快照当前分P，切画质期间若用户切换了分P则不恢复弹幕，避免覆盖新分P的状态
    final cid = _currentCid.value;

    // 暂停弹幕
    final danmakuEnabled = _danmakuCtl.enabled;
    _danmakuCtl.enabled = false;

    if (!loading.isClosed) loading.sink.add(true);
    try {
      await _playDashMedia(
        _videoPlayURLInfo.dashData,
        sf,
        start: _controller.player.state.position,
      );
      // 切画质期间用户切换了分P时丢弃结果，避免画质与分P错配
      if (!mounted || cid != _currentCid.value) return;
      // 播放成功后才提交画质
      _currentQuality = sf;
    } catch (e) {
      if (mounted) pushTooltipError(context, e.toString());
    } finally {
      if (!loading.isClosed) loading.sink.add(false);
      if (mounted && cid == _currentCid.value) {
        // 恢复弹幕
        _danmakuCtl.enabled = danmakuEnabled;
      }
    }
  }

  List<String> _videoUrls = [];
  List<String> _audioUrls = [];

  Future<void> _playDashMedia(
    DashData media,
    Quality quality, {
    Duration? start,
  }) async {
    var video = media.video.firstWhere(
      (e) => e.quality == quality.id,
      orElse: () => throw Exception('该画质无可用视频流'),
    );
    var videoUrls = [
      video.baseUrl,
      ...video.backupUrls,
    ].where((u) => u.isNotEmpty).toList();
    if (videoUrls.isEmpty) {
      throw Exception('该画质无可用视频流');
    }
    var audioUrls = media.audio
        .expand((e) => [e.baseUrl, ...e.backupUrls])
        .where((u) => u.isNotEmpty)
        .toList();

    // 先记录全部候选地址，供_onPlayError在首个地址失败时轮换备份地址
    _videoUrls = videoUrls;
    _audioUrls = audioUrls;

    // 先打开视频流，成功后再设置DASH音轨，两者完成前不提交播放成功状态
    await _controller.player.open(
      Media(
        videoUrls.first,
        httpHeaders: bilibiliHttpClient.options.headers.cast<String, String>(),
        start: start,
      ),
    );
    if (audioUrls.isNotEmpty) {
      await _controller.player.setAudioTrack(AudioTrack.uri(audioUrls.first));
    }
  }

  void _cancelAutoNext() {
    _autoNextTimer?.cancel();
    _autoNextTimer = null;
  }

  void _onPlayCompleted() {
    // 上报播放进度
    if (loginInfoNotifier.value.isLogin) {
      reportPlayProgress(
        widget.video.avid,
        _playingCid,
        _controller.player.state.position,
      ).ignore();
    }

    final index = widget.video.episodes.indexWhere((e) => e.cid == _playingCid);
    if (index < 0 || index == widget.video.episodes.length - 1) return;
    if (!mounted) return;

    // 3秒后自动切到下一分P，用户seek或手动切P会取消该计时器
    _autoNextTimer = Timer(const Duration(seconds: 3), () {
      _autoNextTimer = null;
      if (!mounted ||
          _currentCid.value != widget.video.episodes[index].cid ||
          _playingCid != widget.video.episodes[index].cid) {
        return;
      }
      _currentCid.value = widget.video.episodes[index + 1].cid;
    });
    final ui = context.ui;
    toastification.show(
      context: context,
      closeButton: const ToastCloseButton(showType: CloseButtonShowType.none),
      style: ToastificationStyle.simple,
      alignment: Alignment.centerRight,
      backgroundColor: Colors.white10.withValues(alpha: 0.5),
      borderSide: BorderSide(width: 0),
      padding: EdgeInsets.symmetric(horizontal: 16 * ui, vertical: 4 * ui),
      title: Text('即将播放下一分P', style: TextStyle(fontSize: 20 * ui)),
      autoCloseDuration: const Duration(seconds: 3),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) => _onBack(didPop),
      child: Scaffold(
        body: KeyboardListener(
          autofocus: true,
          focusNode: _screenFocusNode,
          onKeyEvent: _onKeyEvent,
          child: Stack(
            children: [
              Video(controller: _controller, controls: NoVideoControls),
              StreamBuilder<bool>(
                stream: _bufferingOrLoading,
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
                builder: (context, display, child) => ExcludeFocus(
                  excluding: !display,
                  child: Offstage(offstage: !display, child: child!),
                ),
                child: _VideoControlWidget(_controller.player, _displayControl),
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
          // 延迟一帧后再隐藏控制层：确保PopScope的_onBack先被调用，
          // 这样_onBack里才能拿到此时的displayControl.value（true），
          // 从而仅关闭控制层而不是退出播放页
          Future.delayed(const Duration(milliseconds: 10)).then((_) {
            if (!mounted) return;
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
        // 仅当没有控件持有焦点时才由页面接管播放/暂停，
        // 避免与控件自身的激活（ActivateIntent）重复触发
        if (FocusManager.instance.primaryFocus != _screenFocusNode) {
          break;
        }
        _controller.player.playOrPause();
        break;
      case LogicalKeyboardKey.contextMenu:
        _displayControl.value = true;
        break;
    }
  }

  void _onStepForward(bool forward) {
    _cancelAutoNext();
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
