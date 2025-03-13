import 'package:flutter/material.dart';

class GradientCard extends StatelessWidget {
  final Widget child;
  const GradientCard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color.fromARGB(255, 213, 224, 235),
            Color.fromARGB(255, 182, 193, 202),
          ],
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}
