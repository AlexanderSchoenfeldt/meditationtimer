import 'package:flutter/material.dart';

import '../theme/palette.dart';

class InlineStepper extends StatelessWidget {
  final String value;
  final String? unit;
  final VoidCallback? onDecrement;
  final VoidCallback? onIncrement;

  const InlineStepper({
    super.key,
    required this.value,
    this.unit,
    required this.onDecrement,
    required this.onIncrement,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _btn(p, Icons.remove, onDecrement),
        const SizedBox(width: 6),
        SizedBox(
          width: 96,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 22,
                  color: p.ink,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
              if (unit != null) ...[
                const SizedBox(width: 4),
                Text(
                  unit!,
                  style: TextStyle(
                    fontSize: 11,
                    color: p.ink3,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 6),
        _btn(p, Icons.add, onIncrement),
      ],
    );
  }

  Widget _btn(Palette p, IconData icon, VoidCallback? onTap) {
    final enabled = onTap != null;
    return SizedBox(
      width: 36,
      height: 36,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          foregroundColor: enabled ? p.ink2 : p.ink3.withValues(alpha: 0.4),
          side: BorderSide(color: enabled ? p.line : p.lineSoft),
          backgroundColor: p.bg,
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
