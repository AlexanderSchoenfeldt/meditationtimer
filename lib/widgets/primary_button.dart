import 'package:flutter/material.dart';

import '../theme/palette.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool large;
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.large = true,
  });

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: p.gold,
        foregroundColor: p.goldOn,
        disabledBackgroundColor: p.bgSunk,
        disabledForegroundColor: p.ink3,
        elevation: 0,
        shape: const StadiumBorder(),
        padding: EdgeInsets.symmetric(
          horizontal: large ? 56 : 28,
          vertical: large ? 18 : 12,
        ),
        textStyle: TextStyle(
          fontSize: large ? 16 : 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.4,
        ),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}

class GhostButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  const GhostButton({super.key, required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final p = context.palette;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: p.ink2,
        side: BorderSide(color: p.line),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }
}
