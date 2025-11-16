import 'dart:math';

import 'package:bilitv/apis/bilibili/media.dart';
import 'package:bilitv/consts/bilibili.dart';
import 'package:bilitv/models/pbs/dm.pb.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/material.dart';

class BilibiliDanmakuWallController {
  late final DanmakuController _controller;
  final enableNotifier = ValueNotifier(true);

  BilibiliDanmakuWallController();

  void dispose() => enableNotifier.dispose();

  set enabled(bool enable) => enableNotifier.value = enable;

  bool get enabled => enableNotifier.value;

  // 清空，并重新开始推送弹幕
  late final Function() _clearFunc;

  void clear() {
    _clearFunc();
  }

  // 等待一会儿再开始载入弹幕，用于步进等场景，避免频繁拉取
  late final Function(Duration duration) _waitFunc;

  void wait(Duration duration) {
    _waitFunc(duration);
  }
}

// bilibili弹幕墙
class BilibiliDanmakuWall extends StatefulWidget {
  final BilibiliDanmakuWallController controller;
  final int cid;
  final Widget child;
  final Stream<Duration> timeline;
  final Stream<bool> playing;

  const BilibiliDanmakuWall({
    super.key,
    required this.controller,
    required this.cid,
    required this.child,
    required this.timeline,
    required this.playing,
  });

  @override
  State<BilibiliDanmakuWall> createState() => _BilibiliDanmakuWallState();
}

class _BilibiliDanmakuWallState extends State<BilibiliDanmakuWall> {
  bool _pullDanmaku = false;
  (int, DmSegMobileReply)? _danmakuCache;

  @override
  void initState() {
    widget.timeline.listen(_onPosition);
    widget.playing.listen(_onPlayingChanged);
    widget.controller.enableNotifier.addListener(_onEnableChanged);
    widget.controller._clearFunc = _onClear;
    widget.controller._waitFunc = _onWait;
    super.initState();
  }

  // 时间变化
  Duration? _lastPushDanmakuTime;

  void _onPosition(Duration pos) {
    // 禁用时不处理
    if (!widget.controller.enabled) return;
    // 没到开始拉取时间时不处理
    if (DateTime.now().isBefore(_beginTime)) return;

    // 拉取弹幕
    // 已有缓存分块不属于当前时间所在分块时拉取
    final index =
        (pos.inSeconds / danmakuChunkIntervalDuration.inSeconds).toInt() + 1;
    final needPull =
        !_pullDanmaku && (_danmakuCache == null || index != _danmakuCache!.$1);
    if (needPull) _onPullDanmaku(index);

    if (_danmakuCache == null) return;

    // 筛选出这个时间段没有推送的弹幕进行推送
    final lastPushMS = _lastPushDanmakuTime == null
        ? pos.inMilliseconds
        : _lastPushDanmakuTime!.inMilliseconds;
    _lastPushDanmakuTime = pos;
    final needPushDanmakuList = _danmakuCache!.$2.elems.where((e) {
      // 屏蔽权重
      if (e.weight < 5) return false;
      return lastPushMS <= e.progress && e.progress < pos.inMilliseconds;
    }).toList();
    if (needPushDanmakuList.isEmpty) return;
    _onPushDanmaku(needPushDanmakuList);
  }

  // 拉取弹幕
  Future<void> _onPullDanmaku(int index) async {
    _pullDanmaku = true;

    final danmakuResp = await getDanmaku(widget.cid, index);
    _danmakuCache = (index, danmakuResp);

    _pullDanmaku = false;
  }

  // 推送弹幕
  static final _random = Random();

  Future<void> _onPushDanmaku(List<DanmakuElem> danmakuList) async {
    for (var e in danmakuList) {
      final y = _random.nextDouble() / 2;
      widget.controller._controller.addDanmaku(
        SpecialDanmakuContentItem(
          e.content,
          color: Color(0xFF000000 | e.color),
          fontSize: e.fontsize.toDouble(),
          translateXTween: Tween<double>(begin: 1, end: -0.5),
          translateYTween: Tween<double>(begin: y, end: y),
          duration: Duration(seconds: 15).inMilliseconds,
        ),
      );
    }
  }

  // 播放状态变化
  void _onPlayingChanged(bool playing) {
    if (playing) {
      widget.controller._controller.resume();
    } else {
      widget.controller._controller.pause();
    }
  }

  // 禁用状态变化
  void _onEnableChanged() {
    final enable = widget.controller.enableNotifier.value;
    if (!enable) {
      _onClear();
    }
  }

  void _onClear() {
    widget.controller._controller.clear();
    _lastPushDanmakuTime = null;
  }

  DateTime _beginTime = DateTime.now();

  void _onWait(Duration duration) {
    _beginTime = DateTime.now().add(duration);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        DanmakuScreen(
          createdController: (c) => widget.controller._controller = c,
          option: DanmakuOption(),
        ),
      ],
    );
  }
}
