import 'package:flutter/material.dart';

class AvatarGlow extends StatelessWidget {
  final bool animate;
  final Color glowColor;
  final Widget child;

  const AvatarGlow({
    super.key,
    required this.animate,
    required this.glowColor,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      decoration: animate
          ? BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  // ✅ FIX: Using .withValues instead of deprecated .withOpacity
                  // ✅ FIX: Accessing 'glowColor' directly (not 'widget.glowColor')
                  color: glowColor.withValues(alpha: 0.5),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
              ],
            )
          : const BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [],
            ),
      child: child,
    );
  }
}