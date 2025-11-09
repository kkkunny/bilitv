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

  static const notLogin = LoginInfo(isLogin: false);
  static login({required String nickname, required String avatar}) {
    return LoginInfo(isLogin: true, nickname: nickname, avatar: avatar);
  }
}

final loginInfoNotifier = ValueNotifier(LoginInfo.notLogin);

Future<void> saveCookie(List<Cookie> cookies) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _cookieKey,
    cookies.map((c) => '${c.name}=${c.value}').join('; '),
  );
}

Future<void> clearCookie() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_cookieKey);
  _loadFromEnv = false;
}

Future<List<Cookie>> loadCookie() async {
  final prefs = await SharedPreferences.getInstance();
  final cookieString = prefs.getString(_cookieKey) ?? '';
  if (cookieString.isEmpty) return [];
  return cookieString
      .split('; ')
      .map((s) => Cookie.fromSetCookieValue(s))
      .toList();
}
