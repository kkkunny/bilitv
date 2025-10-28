import 'dart:io' show Platform, Cookie;

import 'package:dio/dio.dart';

final bilibiliHttpClient = Dio(
  BaseOptions(
    headers: {
      'Referer': 'https://www.bilibili.com/',
      'User-Agent':
          'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0',
      'Cookie': getCookie(),
    },
  ),
);

String getCookie() {
  Map<String, String> envVars = Platform.environment;
  return envVars['BILIBILI_COOKIE'] ?? '';
}

class QR {
  final String key;
  final String url;
  final Duration expire;

  QR({
    required this.key,
    required this.url,
    this.expire = const Duration(minutes: 3),
  });

  factory QR.fromJson(Map<String, dynamic> json) {
    return QR(key: json['qrcode_key'], url: json['url']);
  }
}

Future<QR> createQR() async {
  final response = await bilibiliHttpClient.get(
    'https://passport.bilibili.com/x/passport-login/web/qrcode/generate',
  );
  if (response.statusCode != 200) {
    throw Exception(
      'http error, code=${response.statusCode}, msg=${response.data}',
    );
  }
  final data = response.data as Map<String, dynamic>;
  if (data['code'] != 0) {
    throw Exception(
      'bilibili api error, code=${data['code']}, msg=${data['message']}',
    );
  }

  return QR.fromJson(data['data']);
}

enum QRState { waiting, scanned, confirmed, expired, error }

class QRStatus {
  final QRState state;
  final String? refreshToken;
  late List<Cookie> cookies;

  QRStatus({required this.state, this.refreshToken, this.cookies=const []});

  factory QRStatus.fromJson(Map<String, dynamic> json) {
    switch (json['code']) {
      case 0:
        return QRStatus(
          state: QRState.confirmed,
          refreshToken: json['refresh_token'],
        );
      case 86038:
        return QRStatus(state: QRState.expired);
      case 86090:
        return QRStatus(state: QRState.scanned);
      case 86101:
        return QRStatus(state: QRState.waiting);
      default:
        throw Exception(
          'bilibili api error, code=${json['code']}, msg=${json['message']}',
        );
    }
  }
}

Future<QRStatus> checkQRStatus(String key) async {
  final response = await bilibiliHttpClient.get(
    'https://passport.bilibili.com/x/passport-login/web/qrcode/poll',
    queryParameters: {'qrcode_key': key},
  );
  if (response.statusCode != 200) {
    throw Exception(
      'http error, code=${response.statusCode}, msg=${response.data}',
    );
  }
  final data = response.data as Map<String, dynamic>;
  if (data['code'] != 0) {
    throw Exception(
      'bilibili api error, code=${data['code']}, msg=${data['message']}',
    );
  }

  var qrStatus = QRStatus.fromJson(data['data']);
  if (qrStatus.state == QRState.confirmed) {
    qrStatus.cookies = response.headers['set-cookie']!.map((cookie) {
      return Cookie.fromSetCookieValue(cookie);
    }).toList();
  }
  return qrStatus;
}
