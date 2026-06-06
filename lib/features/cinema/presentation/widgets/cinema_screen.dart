import 'package:flutter/material.dart';

class CinemaScreen extends StatelessWidget {
  const CinemaScreen({super.key});

  @override
Widget build(BuildContext context) {
  return Transform(
    alignment: Alignment.center,
    transform: Matrix4.identity()
      ..setEntry(3, 2, 0.001) // perspective depth (3d space)
      ..rotateX(-0.25), // tilt backward (cinema effect)

    child: Container(
      width: double.infinity,
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(60),

        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),

        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha: 0.3),
            blurRadius: 30,
            spreadRadius: 2,
            offset: const Offset(0, 15),
          ),
        ],
      ),

      child: const Center(
        child: Text(
          "SCREEN",
          style: TextStyle(
            color: Colors.white70,
            letterSpacing: 4,
            fontSize: 12,
          ),
        ),
      ),
    ),
  );
}
}