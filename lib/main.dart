import 'package:flutter/material.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const BiliTVApp());
}

class BiliTVApp extends StatelessWidget {
  const BiliTVApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '哔哩哔哩 TV版',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A1D6),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
