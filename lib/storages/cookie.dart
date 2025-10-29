import 'dart:io';

import 'package:shared_preferences/shared_preferences.dart';

const _cookieKey = 'biliili_cookie';

Future<void> saveCookie(String cookie) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_cookieKey, cookie);
}

Future<String> loadCookie() async {
  final prefs = await SharedPreferences.getInstance();
  Map<String, String> envVars = Platform.environment;
  return prefs.getString(_cookieKey) ?? envVars['BILIBILI_COOKIE'] ?? '';
}
