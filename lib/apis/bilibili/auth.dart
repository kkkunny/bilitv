import 'dart:convert' show utf8;
import 'dart:io' show Cookie;

import 'package:crypto/crypto.dart' as crypto;
import 'package:dio/dio.dart';
import 'dart:collection' show SplayTreeMap;
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:basic_utils/basic_utils.dart';
import 'package:convert/convert.dart' as convert;
import 'package:pointycastle/export.dart';

import 'client.dart';

// 二维码
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

// 创建二维码
Future<QR> createQR() async {
  final data = await bilibiliRequest(
    'GET',
    'https://passport.bilibili.com/x/passport-login/web/qrcode/generate',
  );
  return QR.fromJson(data);
}

// 二维码状态
enum QRState {
  waiting, // 等待扫码
  scanned, // 已扫码，等待确认
  confirmed, // 已确认，成功登陆
  expired, // 已过期
  error, // 错误
}

// 二维码状态查询结果
class QRStatus {
  final QRState state;
  final String? refreshToken;
  late List<Cookie> cookies;

  QRStatus({required this.state, this.refreshToken, this.cookies = const []});

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

// 检查二维码状态
Future<QRStatus> checkQRStatus(String key) async {
  Headers? respHeaders;
  final data = await bilibiliRequest(
    'GET',
    'https://passport.bilibili.com/x/passport-login/web/qrcode/poll',
    queryParameters: {'qrcode_key': key},
    respHandler: (response) {
      respHeaders = response.headers;
    },
  );
  var qrStatus = QRStatus.fromJson(data);
  if (qrStatus.state == QRState.confirmed) {
    qrStatus.cookies = respHeaders!['set-cookie']!.map((cookie) {
      return Cookie.fromSetCookieValue(cookie);
    }).toList();
    final (buvid3, buvid4) = await getBuvids();
    qrStatus.cookies.addAll([
      Cookie('buvid3', buvid3),
      Cookie('buvid4', buvid4),
    ]);
  }
  return qrStatus;
}

// 获取 buvid3 / buvid4
Future<(String, String)> getBuvids() async {
  final data = await bilibiliRequest(
    'GET',
    'https://api.bilibili.com/x/frontend/finger/spi',
  );
  return (data['b_3'].toString(), data['b_4'].toString());
}

class CookieStatus {
  final bool refresh;
  final int timestamp;
  CookieStatus({required this.refresh, required this.timestamp});
  factory CookieStatus.fromJson(Map<String, dynamic> json) {
    return CookieStatus(refresh: json['refresh'], timestamp: json['timestamp']);
  }
}

const _publicKeyPEM = """
-----BEGIN PUBLIC KEY-----
MIGfMA0GCSqGSIb3DQEBAQUAA4GNADCBiQKBgQDLgd2OAkcGVtoE3ThUREbio0Eg
Uc/prcajMKXvkCKFCWhJYJcLkcM2DKKcSeFpD/j6Boy538YXnR6VhcuUJOhH2x71
nzPjfdTcqMz7djHum0qSZA0AyCBDABUqCrfNgCiJ00Ra7GmRj+YCK1NJEuewlb40
JNrRuoEUXpabUzGB8QIDAQAB
-----END PUBLIC KEY-----
""";

// 生成CorrespondPath
String _generateCorrespondPath(int ts) {
  final RSAPublicKey pubKey = CryptoUtils.rsaPublicKeyFromPem(_publicKeyPEM);
  final oaep = OAEPEncoding.withSHA256(RSAEngine());
  oaep.init(
    true,
    ParametersWithRandom(
      PublicKeyParameter<RSAPublicKey>(pubKey),
      _secureRandom(),
    ),
  );
  final msgBytes = Uint8List.fromList(utf8.encode('refresh_$ts'));
  final cipherBytes = oaep.process(msgBytes);
  return convert.hex.encode(cipherBytes);
}

// 提供加密所需的安全随机源
SecureRandom _secureRandom() {
  final rnd = Random.secure();
  final seed = Uint8List(32);
  for (var i = 0; i < seed.length; i++) {
    seed[i] = rnd.nextInt(256);
  }
  final fortuna = FortunaRandom();
  fortuna.seed(KeyParameter(seed));
  return fortuna;
}

// // APP 签名
// Map<String, dynamic> appSign(
//   Map<String, dynamic> params,
//   String appKey,
//   String appSec,
// ) {
//   params = Map.from(params);
//   params['appkey'] = appKey;
//   final sortParams = SplayTreeMap<String, dynamic>.from(
//     params,
//     (key1, key2) => key1.compareTo(key2),
//   );
//   final query = Uri.encodeFull(
//     sortParams.keys
//         .map((String key) {
//           return '$key=${sortParams[key]}';
//         })
//         .join('&'),
//   );
//   final sign = crypto.md5.convert(utf8.encode(query + appSec)).toString();
//   params['sign'] = sign;
//   return params;
// }
