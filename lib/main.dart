import 'package:bilitv/utils/scroll_behavior.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter_displaymode/flutter_displaymode.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:media_kit/media_kit.dart';

import 'consts/color.dart';
import 'pages/page.dart';
import 'pages/splash.dart';

Future<void> main() async {
  // 初始化播放器
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();

  // 设置所支持的最高刷新频率
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
        focusColor: Colors.blue.shade100,
        hoverColor: Colors.blue.shade100,
        // colorScheme: ColorScheme.fromSeed(
        //   seedColor: const Color(0xFF00A1D6),
        //   brightness: Brightness.light,
        // ),
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
