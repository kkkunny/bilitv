import 'package:bilitv/main.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('release 分支：未捕获 Flutter 异常触发全局提示且不向外抛', () {
    var fatal = 0;
    installFlutterErrorHandler(debug: false, onFatal: () => fatal++);

    FlutterError.reportError(
      FlutterErrorDetails(exception: StateError('boom')),
    );

    expect(fatal, 1);
  });

  test('debug 分支：保留框架错误呈现，不触发全局提示', () {
    var fatal = 0;
    installFlutterErrorHandler(debug: true, onFatal: () => fatal++);

    // presentError 在测试环境仅打印，不抛出
    FlutterError.reportError(
      FlutterErrorDetails(exception: StateError('boom')),
    );

    expect(fatal, 0);
  });
}
