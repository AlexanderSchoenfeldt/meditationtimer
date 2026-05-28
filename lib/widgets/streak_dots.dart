import 'package:flutter/material.dart';

import '../data/stats.dart';
import '../theme/palette.dart';

class StreakDots extends StatelessWidget {
  final List<DayMark> days;
  const StreakDots({super.key, required this.days});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (int i = 0; i < days.length; i++) ...[
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: days[i].on ? p.gold : p.line,
            ),
          ),
          if (i < days.length - 1) const SizedBox(width: 12),
        ],
      ],
    );
  }
}
