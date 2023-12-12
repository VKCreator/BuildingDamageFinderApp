import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

class CustomTitleAppBar extends StatelessWidget {
  const CustomTitleAppBar({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        final span = TextSpan(
          text: text,
        );
        final painter = TextPainter(
          text: span,
          maxLines: 1,
          textScaleFactor: MediaQuery.of(context).textScaleFactor,
          textDirection: TextDirection.ltr,
        );
        painter.layout();
        const iconSizeWithPadding = 2 * (24 + 8 * 2);
        final overflow =
            (painter.size.width + iconSizeWithPadding) > constraints.maxWidth;
        return Container(
          // color: overflow ? Colors.red : Colors.green,
          child: overflow
              ? SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: Marquee(
                    text: text,
                    blankSpace: 20.0,
                    velocity: 50.0,
                  ))
              : Text.rich(span),
        );
      },
    );
  }
}
