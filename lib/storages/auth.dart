import 'dart:io';

import 'package:flutter/material.dart' show ValueNotifier;
import 'package:shared_preferences/shared_preferences.dart';

const _cookieKey = 'bilibili_cookie';
const _refreshTokenKey = 'bilibili_refresh_token';

class LoginInfo {
  final bool isLogin;
  final int? mid;
  final String? nickname;
  final String? avatar;

  const LoginInfo({
    required this.isLogin,
    this.mid,
    this.nickname,
    this.avatar,
  });

  static const notLogin = LoginInfo(isLogin: false);

  static login({
    required int mid,
    required String nickname,
    required String avatar,
  }) {
    return LoginInfo(
      isLogin: true,
      mid: mid,
      nickname: nickname,
      avatar: avatar,
    );
  }
}

final loginInfoNotifier = ValueNotifier(LoginInfo.notLogin);

Future<void> saveCookie(
  List<Cookie> cookies, {
  String refreshToken = '',
}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(
    _cookieKey,
    cookies.map((c) => '${c.name}=${c.value}').join('; '),
  );
  if (refreshToken.isNotEmpty) {
    await prefs.setString(_refreshTokenKey, refreshToken);
  }
}

Future<void> clearCookie({bool withRefreshToken = true}) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.remove(_cookieKey);
  if (withRefreshToken) await prefs.remove(_refreshTokenKey);
}

Future<List<Cookie>> loadCookie() async {
  final prefs = await SharedPreferences.getInstance();
  final cookieString = prefs.getString(_cookieKey) ?? '';
  if (cookieString.isEmpty) return [];
  final cookies = <Cookie>[];
  for (final part in cookieString.split('; ')) {
    if (part.trim().isEmpty) continue;
    try {
      cookies.add(Cookie.fromSetCookieValue(part));
    } catch (_) {
      // 单条Cookie损坏时跳过，避免影响其它Cookie与整个请求
    }
  }
  return cookies;
}

Future<String?> loadRefreshToken() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_refreshTokenKey);
}
