import 'dart:async';

import 'package:bilitv/consts/color.dart';
import 'package:bilitv/pages/pages.dart';
import 'package:bilitv/pages/splash.dart';
import 'package:bilitv/utils/scroll_behavior.dart';
import 'package:bilitv/utils/ui_scale.dart';
import 'package:bilitv/widgets/tooltip.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:logger/logger.dart';
import 'package:media_kit/media_kit.dart';

final _logger = Logger();

// 全局导航 key：供无 BuildContext 的全局错误提示定位 Overlay
final navigatorKey = GlobalKey<NavigatorState>();

// 安装 Flutter 未捕获异常兜底：记录日志，debug 保留红屏，release 提示用户
void installFlutterErrorHandler({
  required void Function() onFatal,
  bool debug = kDebugMode,
}) {
  FlutterError.onError = (details) {
    _logger.e(
      '未捕获的Flutter异常',
      error: details.exception,
      stackTrace: details.stack,
    );
    if (debug) {
      FlutterError.presentError(details);
    } else {
      onFatal();
    }
  };
}

Future<void> main() async {
  runZonedGuarded(
    () async {
      // 初始化播放器
      WidgetsFlutterBinding.ensureInitialized();
      MediaKit.ensureInitialized();

      installFlutterErrorHandler(onFatal: _showGlobalFatal);

      // 设置所支持的最高刷新率
      await FlutterDisplayMode.setHighRefreshRate();

      // 开启app
      runApp(const BiliTVApp());
    },
    (error, stack) {
      _logger.e('未捕获的异步异常', error: error, stackTrace: stack);
      if (!kDebugMode) _showGlobalFatal();
    },
  );
}

void _showGlobalFatal() {
  final context = navigatorKey.currentContext;
  if (context == null || !context.mounted) return;
  pushTooltipFatal(context, '发生未知错误');
}

class BiliTVApp extends StatelessWidget {
  const BiliTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '哔哩哔哩TV',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        useMaterial3: true,
        canvasColor: lightPink,
        scaffoldBackgroundColor: lightPink,
        applyElevationOverlayColor: true,
        focusColor: biliPink.withValues(alpha: 0.15),
        hoverColor: biliPink.withValues(alpha: 0.15),
        highlightColor: biliPink,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashPage()),
        GetPage(name: '/home', page: () => const Page()),
      ],
      debugShowCheckedModeBanner: false,
      scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
      builder: (context, child) =>
          UiScaleScope(child: child ?? const SizedBox()),
    );
  }
}
