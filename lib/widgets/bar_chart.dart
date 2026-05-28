import 'package:flutter/material.dart';

import '../theme/palette.dart';

class WeeklyBars extends StatelessWidget {
  final List<int> values; // minutes per bucket, oldest first
  final double height;

  const WeeklyBars({super.key, required this.values, this.height = 140});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    final maxV = values.isEmpty ? 0 : values.reduce((a, b) => a > b ? a : b);
    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (int i = 0; i < values.length; i++) ...[
            Expanded(
              child: _Bar(
                fraction: maxV == 0 ? 0 : values[i] / maxV,
                empty: values[i] == 0,
                color: p.ink,
                emptyColor: p.lineSoft,
              ),
            ),
            if (i < values.length - 1) const SizedBox(width: 6),
          ],
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  final double fraction;
  final bool empty;
  final Color color;
  final Color emptyColor;

  const _Bar({
    required this.fraction,
    required this.empty,
    required this.color,
    required this.emptyColor,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        final h = empty ? 4.0 : (c.maxHeight * fraction).clamp(4.0, c.maxHeight);
        return Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: h,
            decoration: BoxDecoration(
              color: empty ? emptyColor : color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      },
    );
  }
}
