import 'package:flutter/material.dart';

Widget animatedButton({required Widget button}) {
  return StatefulBuilder(
    builder: (context, setState) {
      double scale = 1.0;

      return MouseRegion(
        onEnter: (_) => setState(() => scale = 1.05),
        onExit: (_) => setState(() => scale = 1.0),
        child: GestureDetector(
          onTapDown: (_) => setState(() => scale = 0.95),
          onTapUp: (_) => setState(() => scale = 1.05),
          onTapCancel: () => setState(() => scale = 1.0),
          child: AnimatedScale(
            scale: scale,
            duration: const Duration(milliseconds: 100),
            curve: Curves.easeInOut,
            child: button,
          ),
        ),
      );
    },
  );
}
