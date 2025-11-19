import 'package:bilitv/apis/bilibili/error.dart';
import 'package:bilitv/storages/auth.dart' show loadCookie;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

final Dio bilibiliHttpClient = () {
  final client = Dio(
    BaseOptions(
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
  final respData = response.data as Map<String, dynamic>;
  if (respData['code'] != 0) {
    throw BilibiliError(respData['code'], respData['message']);
  }
  return respData['data'];
}
