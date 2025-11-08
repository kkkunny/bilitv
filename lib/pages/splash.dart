import 'package:bilitv/apis/bilibili/user.dart' show getMySelfInfo;
import 'package:bilitv/consts/bilibili.dart' show defaultSplashImage;
import 'package:bilitv/storages/cookie.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

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
    Navigator.of(context).pushReplacementNamed('/home');
  }

  static Future<void> _onAppInit() async {
    try {
      await _checkLogin();
    } catch (_) {}

    await Future.delayed(const Duration(milliseconds: 500));
  }

  static Future<void> _checkLogin() async {
    final cookie = await loadCookie();
    if (cookie.isEmpty) {
      return;
    }
    final info = await getMySelfInfo();
    loginInfoNotifier.value = LoginInfo.login(
      nickname: info.name,
      avatar: info.avatar,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CachedNetworkImage(
          imageUrl: defaultSplashImage,
          fit: BoxFit.contain,
          placeholder: (_, _) => const SizedBox(),
          errorWidget: (_, _, _) => const SizedBox(),
        ),
      ),
    );
  }
}
