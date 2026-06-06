import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Subtle idle-pulse button label.
///
/// Instead of every letter constantly bobbing (which felt frantic), this
/// plays a single slow wave across the text once, pauses, then repeats —
/// giving a calm "breathing" feel closer to a real premium button.
class WaveButtonText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const WaveButtonText({
    super.key,
    required this.text,
    this.style = const TextStyle(
      color: Colors.black,
      fontSize: 16,
      fontWeight: FontWeight.w900,
      letterSpacing: 1.5,
    ),
  });

  @override
  State<WaveButtonText> createState() => _WaveButtonTextState();
}

class _WaveButtonTextState extends State<WaveButtonText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    // One full cycle = 1.2 s active + ~1.8 s pause via curve
    duration: const Duration(milliseconds: 3000),
  )..repeat();

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (_, __) {
        // t goes 0→1 in 3 s; we only activate the wave during the first 40%
        // of the cycle, then let it rest — avoids the "always moving" feel.
        final t = _ac.value; // 0.0 → 1.0
        final activeT = (t / 0.4).clamp(0.0, 1.0); // 0→1 over first 40%
        final phase = activeT * math.pi * 2; // one full sine cycle

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.text.length; i++) ...[
              Builder(builder: (_) {
                final charPhase = phase - i * 0.4;
                final sine  = activeT > 0 ? math.sin(charPhase) : 0.0;
                final yOff  = sine * -3.0;
                // Opacity stays close to 1 — just a whisper of shimmer
                final alpha = 0.75 + sine * 0.25;

                return Transform.translate(
                  offset: Offset(0, yOff),
                  child: Opacity(
                    opacity: alpha.clamp(0.0, 1.0),
                    child: Text(widget.text[i], style: widget.style),
                  ),
                );
              }),
            ],
          ],
        );
      },
    );
  }
}