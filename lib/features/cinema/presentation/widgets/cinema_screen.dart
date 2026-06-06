import 'package:flutter/material.dart';

class CinemaScreen extends StatelessWidget {
  const CinemaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 90,
      margin: const EdgeInsets.symmetric(horizontal: 20),

      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(60), // curve effect
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E293B),
            Color(0xFF0F172A),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),

        // glow effect (important for cinema feel)
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withValues(alpha:0.25),
            blurRadius: 25,
            spreadRadius: 2,
            offset: const Offset(0, 10),
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
    );
  }
}