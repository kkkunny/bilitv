import 'package:flutter/material.dart';

void pushTooltipInfo(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(text), duration: Duration(milliseconds: 500)),
  );
}

void pushTooltipWarning(BuildContext context, String text) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text, style: TextStyle(color: Colors.yellow)),
      duration: Duration(milliseconds: 500),
    ),
  );
}
