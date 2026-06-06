import 'package:flutter/material.dart';

class CinemaScreen extends StatelessWidget {
  const CinemaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.22),

      child: Container(
        width: double.infinity,
        height: 95,
        margin: const EdgeInsets.symmetric(horizontal: 20),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),

          gradient: const LinearGradient(
            colors: [
              Color(0xFF263043),
              Color(0xFF0F172A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withValues(alpha: 0.25),
              blurRadius: 35,
              spreadRadius: 2,
              offset: const Offset(0, 18),
            ),
          ],
        ),

        child: const Center(
          child: Text(
            "SCREEN",
            style: TextStyle(
              color: Colors.white70,
              letterSpacing: 5,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}