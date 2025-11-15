import 'package:bilitv/apis/bilibili/user.dart' show getMySelfInfo;
import 'package:bilitv/consts/assets.dart';
import 'package:bilitv/storages/cookie.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    await _onAppInit();

    if (!mounted) return;
    Get.offAllNamed('/home');
  }

  static Future<void> _onAppInit() async {
    try {
      await _checkLogin();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Future<void> _checkLogin() async {
    final cookies = await loadCookie();
    if (cookies.isEmpty) {
      return;
    }
    final info = await getMySelfInfo();
    loginInfoNotifier.value = LoginInfo.login(
      mid: info.mid,
      nickname: info.name,
      avatar: info.avatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset(
          Images.splash,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) => const SizedBox(),
        ),
      ),
    );
  }
}
