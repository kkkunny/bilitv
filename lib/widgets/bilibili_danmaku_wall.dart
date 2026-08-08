import 'dart:async';

import 'package:bilitv/apis/bilibili/media.dart';
import 'package:bilitv/consts/bilibili.dart';
import 'package:bilitv/models/pbs/dm.pb.dart';
import 'package:bilitv/storages/settings.dart';
import 'package:bilitv/widgets/cache_future_builder.dart';
import 'package:canvas_danmaku/canvas_danmaku.dart';
import 'package:flutter/material.dart';

class BilibiliDanmakuWallController {
  late final DanmakuController _controller;
  late final ValueNotifier<bool> enableNotifier;

  BilibiliDanmakuWallController(bool enable)
    : enableNotifier = ValueNotifier(enable);

  void dispose() => enableNotifier.dispose();

  set enabled(bool enable) => enableNotifier.value = enable;

  bool get enabled => enableNotifier.value;

  // 清空，并重新开始推送弹幕
  late Function() _clearFunc;

  void clear() {
    _clearFunc();
  }

  // 等待一会儿再开始载入弹幕，用于步进等场景，避免频繁拉取
  late Function(Duration duration) _waitFunc;

  void wait(Duration duration) {
    _waitFunc(duration);
  }
}

// bilibili弹幕墙
class BilibiliDanmakuWall extends StatefulWidget {
  final BilibiliDanmakuWallController controller;
  final int cid;
  final Stream<Duration> timeline;
  final Stream<bool> playing;

  const BilibiliDanmakuWall({
    super.key,
    required this.controller,
    required this.cid,
    required this.timeline,
    required this.playing,
  });

  @override
  State<BilibiliDanmakuWall> createState() => _BilibiliDanmakuWallState();
}

class _BilibiliDanmakuWallState extends State<BilibiliDanmakuWall> {
  late final int _danmuBlockWeight;
  late final double _danmuFontSize;
  bool _pullDanmaku = false;
  (int, int, DmSegMobileReply)? _danmakuCache; // (cid, 分块index, 弹幕数据)

  StreamSubscription<Duration>? _timelineSubscription;
  StreamSubscription<bool>? _playingSubscription;

  @override
  void initState() {
    super.initState();
    _timelineSubscription = widget.timeline.listen(_onPosition);
    _playingSubscription = widget.playing.listen(_onPlayingChanged);
    widget.controller.enableNotifier.addListener(_onEnableChanged);
    widget.controller._clearFunc = _onClear;
    widget.controller._waitFunc = _onWait;
  }

  @override
  void dispose() {
    _timelineSubscription?.cancel();
    _playingSubscription?.cancel();
    widget.controller.enableNotifier.removeListener(_onEnableChanged);
    widget.controller._clearFunc = () {};
    widget.controller._waitFunc = (_) {};
    super.dispose();
  }

  Future<void> _init() async {
    _danmuBlockWeight =
        await Settings.getInt(Settings.pathDanmuBlockWeightSwitch) ?? 6;
    _danmuFontSize =
        (await Settings.getInt(Settings.pathDanmuFontSize))?.toDouble() ?? 20;
  }

  // 时间变化
  Duration? _lastPushDanmakuTime;

  Future<void> _onPosition(Duration pos) async {
    // 禁用时不处理
    if (!widget.controller.enabled) return;
    // 没到开始拉取时间时不处理
    if (DateTime.now().isBefore(_beginTime)) return;

    // 拉取弹幕
    // 已有缓存不属于当前分P或当前时间分块时重新拉取
    final index =
        (pos.inSeconds / danmakuChunkIntervalDuration.inSeconds).toInt() + 1;
    final needPull = !_pullDanmaku &&
        (_danmakuCache == null ||
            widget.cid != _danmakuCache!.$1 ||
            index != _danmakuCache!.$2);
    if (needPull) _onPullDanmaku(index);

    if (_danmakuCache == null) return;

    // 筛选出这个时间段没有推送的弹幕进行推送
    final lastPushMS = _lastPushDanmakuTime == null
        ? pos.inMilliseconds
        : _lastPushDanmakuTime!.inMilliseconds;
    _lastPushDanmakuTime = pos;
    final needPushDanmakuList = _danmakuCache!.$3.elems.where((e) {
      // 屏蔽权重
      if (e.weight <= _danmuBlockWeight) return false;
      return lastPushMS <= e.progress && e.progress < pos.inMilliseconds;
    }).toList();
    if (needPushDanmakuList.isEmpty) return;
    _onPushDanmaku(needPushDanmakuList);
  }

  // 拉取弹幕
  Future<void> _onPullDanmaku(int index) async {
    _pullDanmaku = true;

    // 请求前捕获cid，分P切换后旧分P的在途请求返回的数据不会被新分P使用
    final cid = widget.cid;
    final danmakuResp = await getDanmaku(cid, index);
    _danmakuCache = (cid, index, danmakuResp);

    _pullDanmaku = false;
  }

  // 推送弹幕

  Future<void> _onPushDanmaku(List<DanmakuElem> danmakuList) async {
    for (var e in danmakuList) {
      final color = Color(0xFF000000 | e.color);

      switch (e.mode) {
        case 4: // 底部弹幕
          widget.controller._controller.addDanmaku(
            DanmakuContentItem(
              e.content,
              color: color,
              type: DanmakuItemType.bottom,
            ),
          );
          break;
        case 5: // 顶部弹幕
          widget.controller._controller.addDanmaku(
            DanmakuContentItem(
              e.content,
              color: color,
              type: DanmakuItemType.top,
            ),
          );
          break;
        // case 6: // 逆向弹幕
        //   final y = _random.nextDouble() / 2;
        //   widget.controller._controller.addDanmaku(
        //     SpecialDanmakuContentItem(
        //       e.content,
        //       color: color,
        //       fontSize: 20,
        //       translateXTween: Tween<double>(begin: -0.5, end: 1),
        //       translateYTween: Tween<double>(begin: y, end: y),
        //       duration: Duration(seconds: 15).inMilliseconds,
        //     ),
        //   );
        //   break;
        default: // 1,2,3 普通弹幕 + 6 逆向弹幕 + 其他
          widget.controller._controller.addDanmaku(
            DanmakuContentItem(e.content, color: color),
          );
      }
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
    return CacheFutureBuilder(
      future: _init,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const SizedBox();
        }
        return DanmakuScreen(
          createdController: (c) => widget.controller._controller = c,
          option: DanmakuOption(fontSize: _danmuFontSize),
        );
      },
    );
  }
}
