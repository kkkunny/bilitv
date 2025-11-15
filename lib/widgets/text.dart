import 'package:flutter/material.dart';

// 固定行数自适应文本
class FixedLineAdaptiveText extends StatelessWidget {
  final String text;
  final int line;

  final double lineHeight;
  final TextStyle? style;
  final TextOverflow? overflow;

  const FixedLineAdaptiveText(
    this.text, {
    required this.line,
    super.key,
    this.lineHeight = 1.2,
    this.style,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        assert(
          constraints.hasBoundedHeight,
          'FixedLineAdaptiveText 需要有界高度，请用 SizedBox/ConstrainedBox 包一下。',
        );

        final double h = constraints.maxHeight;
        final double fs = (h / (line * lineHeight)).clamp(1.0, 1000.0);

        final base = style ?? DefaultTextStyle.of(context).style;
        final resolved = base.copyWith(fontSize: fs, height: lineHeight);

        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(1.0)),
          child: Text(
            text,
            maxLines: line,
            overflow: overflow,
            style: resolved,
            strutStyle: StrutStyle(
              fontFamily: resolved.fontFamily,
              fontSize: fs,
              height: lineHeight,
              leading: 0,
              forceStrutHeight: true,
            ),
          ),
        );
      },
    );
  }
}
