import 'dart:io';

import 'package:flutter/material.dart' show ValueNotifier;
import 'package:shared_preferences/shared_preferences.dart';

const _cookieKey = 'bilibili_cookie';

// debug: 是否从环境变量中读取cookie
var _loadFromEnv = true;

class LoginInfo {
  final bool isLogin;
  final String? nickname;
  final String? avatar;

  const LoginInfo({required this.isLogin, this.nickname, this.avatar});

  static const notLogin = LoginInfo(isLogin: true);
  static login({required String nickname, required String avatar}) {
    return LoginInfo(isLogin: true, nickname: nickname, avatar: avatar);
  }
}

final loginInfoNotifier = ValueNotifier(LoginInfo.notLogin);

Future<void> saveCookie(String cookie) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_cookieKey, cookie);
}

Future<void> clearCookie() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_cookieKey);
  _loadFromEnv = false;
}

Future<String> loadCookie() async {
  Map<String, String> env = _loadFromEnv ? Platform.environment : {};
  final prefs = await SharedPreferences.getInstance();
  final cookie =
      prefs.getString(_cookieKey) ?? env[_cookieKey.toUpperCase()] ?? '';
  return cookie;
}
