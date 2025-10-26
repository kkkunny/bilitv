import 'package:bilitv/utils/scroll_behavior.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pages/home_page.dart';

void main() {
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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00A1D6),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'HarmonyOS_Sans_SC',
        ),
        home: const HomePage(),
        debugShowCheckedModeBanner: false,
        scrollBehavior: NoThumbScrollBehavior().copyWith(scrollbars: false),
      ),
    );
  }
}
