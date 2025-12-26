import 'package:bilitv/consts/color.dart';
import 'package:bilitv/pages/pages.dart';
import 'package:bilitv/pages/splash.dart';
import 'package:bilitv/utils/scroll_behavior.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

Future<void> main() async {
  // 初始化播放器
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // 设置所支持的最高刷新率
  await FlutterDisplayMode.setHighRefreshRate();

  // 开启app
  runApp(const BiliTVApp());
}

class BiliTVApp extends StatelessWidget {
  const BiliTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: '哔哩哔哩TV',
      theme: ThemeData(
        useMaterial3: true,
        canvasColor: lightPink,
        scaffoldBackgroundColor: lightPink,
        applyElevationOverlayColor: true,
        focusColor: Colors.blue.shade100,
        hoverColor: Colors.blue.shade100,
        highlightColor: Colors.blueAccent,
      ),
      initialRoute: '/',
      getPages: [
        GetPage(name: '/', page: () => const SplashPage()),
        GetPage(name: '/home', page: () => const Page()),
      ],
      debugShowCheckedModeBanner: false,
      scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
    );
  }
}
