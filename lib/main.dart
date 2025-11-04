import 'package:bilitv/utils/scroll_behavior.dart';
import 'package:flutter/material.dart' hide Page;
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'consts/color.dart';
import 'pages/page.dart';
import 'pages/splash.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  runApp(const BiliTVApp());
}

class BiliTVApp extends StatelessWidget {
  const BiliTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: MaterialApp(
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
        routes: {
          '/': (ctx) => const SplashPage(),
          '/home': (ctx) => const Page(),
        },
        debugShowCheckedModeBanner: false,
        scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
      ),
    );
  }
}
