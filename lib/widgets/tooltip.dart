import 'package:bilitv/apis/bilibili/error.dart';
import 'package:bilitv/utils/ui_scale.dart';
import 'package:flutter/material.dart';

void pushTooltipInfo(
  BuildContext context,
  String text, {
  Duration duration = const Duration(milliseconds: 500),
}) {
  final ui = context.ui;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.black45,
        content: Row(
          children: [
            Icon(
              Icons.info_outline_rounded,
              color: Colors.white,
              size: 24 * ui,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10 * ui),
                child: Text(
                  '提示：$text',
                  style: TextStyle(color: Colors.white, fontSize: 20 * ui),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
      ),
    );
}

void pushTooltipWarning(
  BuildContext context,
  String text, {
  Duration duration = const Duration(milliseconds: 500),
}) {
  final ui = context.ui;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.yellow.withValues(alpha: 0.8),
        content: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Colors.black,
              size: 24 * ui,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10 * ui),
                child: Text(
                  '警告：$text',
                  style: TextStyle(color: Colors.white, fontSize: 20 * ui),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        duration: duration,
      ),
    );
}

void pushTooltipError(
  BuildContext context,
  String text, {
  Duration duration = const Duration(seconds: 1),
}) {
  final ui = context.ui;
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: Colors.red.withValues(alpha: 0.6),
        content: Row(
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.white,
              size: 24 * ui,
            ),
            Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 10 * ui),
                child: Text(
                  '错误：$text',
                  style: TextStyle(color: Colors.white, fontSize: 20 * ui),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        // duration: duration,
      ),
    );
}

Future<T> tooltipNetFetch<T>(
  BuildContext context,
  Future<T> Function() fetch,
) async {
  try {
    return await fetch();
  } catch (e) {
    if (!context.mounted) {
      rethrow;
    }
    pushTooltipError(context, e.toString());
    rethrow;
  }
}

// 执行网络请求，成功后提示成功文案，失败时提示错误信息
Future<void> requestWithTooltip(
  BuildContext context, {
  required Future<void> Function() request,
  required String successText,
}) async {
  try {
    await request();
    if (!context.mounted) return;
    pushTooltipInfo(context, successText);
  } on BilibiliError catch (e) {
    if (!context.mounted) return;
    pushTooltipError(context, e.message);
  } catch (e) {
    if (!context.mounted) return;
    pushTooltipError(context, '未知的错误');
  }
}
