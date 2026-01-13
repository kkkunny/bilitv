import 'package:flutter/material.dart';

void pushTooltipInfo(
  BuildContext context,
  String text, {
  Duration duration = const Duration(milliseconds: 500),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.black45,
      content: Row(
        children: [
          Icon(Icons.info_outline_rounded, color: Colors.white),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '提示：$text',
                style: TextStyle(color: Colors.white, fontSize: 20),
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
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.yellow.withValues(alpha: 0.8),
      content: Row(
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.black),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '警告：$text',
                style: TextStyle(color: Colors.white, fontSize: 20),
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
  Duration duration = const Duration(milliseconds: 500),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      backgroundColor: Colors.red.withValues(alpha: 0.6),
      content: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: Colors.white),
          Expanded(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                '错误：$text',
                style: TextStyle(color: Colors.white, fontSize: 20),
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
