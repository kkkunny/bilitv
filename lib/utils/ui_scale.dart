import 'dart:math' as math;

import 'package:flutter/widgets.dart';

// 全局UI缩放。
//
// 设计基准为 1920x1080（1080p），因子取 `min(宽/1920, 高/1080)`：
// - 16:9 设备上与 `高/1080` 等价，720p/4K 等比缩放到同一观感；
// - 非 16:9 设备由短板限制，避免固定尺寸元素横向溢出。
//
// 所有视觉尺寸（字号、图标、间距、圆角、描边等）都必须乘 `ui`；
// 宽高比、Flex 权重、行列数、文本行数等布局参数不得乘 `ui`。
class UiScale extends InheritedWidget {
  static const double designWidth = 1920;
  static const double designHeight = 1080;

  final double factor;

  const UiScale({super.key, required this.factor, required super.child});

  // 根据窗口尺寸计算缩放因子
  static double factorFor(Size size) {
    return math.min(size.width / designWidth, size.height / designHeight);
  }

  // 描边/分割线：保证低分辨率下不小于1逻辑像素
  static double border(double width, double ui) {
    return math.max(1, width * ui);
  }

  static double of(BuildContext context) {
    final scale = context.dependOnInheritedWidgetOfExactType<UiScale>();
    assert(scale != null, 'UiScale 未挂载，请在 MaterialApp.builder 中包裹');
    return scale?.factor ?? 1;
  }

  @override
  bool updateShouldNotify(UiScale oldWidget) => factor != oldWidget.factor;
}

extension UiScaleX on BuildContext {
  double get ui => UiScale.of(this);

  // 描边/分割线尺寸，带最小1逻辑像素保护
  double border(double width) => UiScale.border(width, ui);
}

// 在 MaterialApp.builder 中挂载全局缩放。
//
// 同时把系统字体缩放固定为 1.0：TV 端 dpad 布局需要确定性，
// 字号只由 ui 阶梯控制，避免系统放大导致卡片/按钮溢出。
class UiScaleScope extends StatelessWidget {
  final Widget child;

  const UiScaleScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return UiScale(
      factor: UiScale.factorFor(MediaQuery.sizeOf(context)),
      child: MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
        child: child,
      ),
    );
  }
}
