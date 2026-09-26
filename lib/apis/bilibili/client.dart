import 'package:bilitv/apis/bilibili/error.dart';
import 'package:bilitv/storages/auth.dart' show loadCookie;
import 'package:bilitv/utils/json.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final Dio bilibiliHttpClient = () {
  final client = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 20),
      sendTimeout: const Duration(seconds: 20),
      headers: {
        'Referer': 'https://www.bilibili.com/',
        'User-Agent':
            'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/141.0.0.0 Safari/537.36 Edg/141.0.0.0',
      },
    ),
  );

  // 日志打印
  if (!kReleaseMode) {
    client.interceptors.add(
      LogInterceptor(requestBody: true, responseBody: true, error: true),
    );
  }

  // cookie自动加载
  client.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        final cookies = await loadCookie();
        if (cookies.isNotEmpty) {
          options.headers['Cookie'] = cookies.join('; ');
        }
        return handler.next(options);
      },
    ),
  );

  return client;
}();

Future<dynamic> bilibiliRequest<T>(
  String method,
  String url, {
  Map<String, dynamic>? queries,
  (bool, dynamic) Function(Response<dynamic>)? respHandler,
  String? contentType,
  Map<String, dynamic>? headers,
  Object? body,
}) async {
  final response = await bilibiliHttpClient.request(
    url,
    options: Options(
      method: method.toUpperCase(),
      contentType: contentType,
      headers: headers,
    ),
    queryParameters: queries,
    data: body,
  );
  if (response.statusCode != 200) {
    throw Exception(
      'http error, code=${response.statusCode}, msg=${response.data}',
    );
  }
  if (respHandler != null) {
    final (ok, respData) = respHandler(response);
    if (ok) return respData;
  }
  // 响应必须是 JSON 对象（风控/验证页会返回 HTML 文本）
  final respData = jsonMap(response.data);
  if (respData == null) {
    throw const BilibiliError(-2, '响应格式异常');
  }
  // code 必须存在且为数字（含数字字符串）
  final rawCode = respData['code'];
  final code = rawCode is num
      ? rawCode.toInt()
      : (rawCode is String ? int.tryParse(rawCode.trim()) : null);
  if (code == null) {
    throw const BilibiliError(-2, '响应格式异常');
  }
  if (code != 0) {
    var message = jsonString(respData['message']).trim();
    if (message.isEmpty) message = jsonString(respData['msg']).trim();
    throw BilibiliError(code, message.isNotEmpty ? message : '未知错误');
  }
  return respData['data'];
}
