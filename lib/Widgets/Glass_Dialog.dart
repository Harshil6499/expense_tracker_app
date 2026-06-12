import 'dart:ui';
import 'package:flutter/material.dart';

class GlassDialog extends StatelessWidget {
  final Widget child;
  final double width;

  const GlassDialog({
    super.key,
    required this.child,
    this.width = 320,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Material(
        color: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(
              sigmaX: 15,
              sigmaY: 15,
            ),
            child: Container(
              width: width,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}