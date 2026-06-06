import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../painters/cinema_painters.dart';

class Countdown extends StatefulWidget {
  final int number;

  const Countdown({super.key, required this.number});

  @override
  State<Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<Countdown>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac =
      AnimationController(vsync: this, duration: const Duration(seconds: 1));

  late final Animation<double> _sweep =
      Tween(begin: 1.0, end: 0.0).animate(_ac);

  @override
  void initState() {
    super.initState();
    _ac.forward();
  }

  @override
  void didUpdateWidget(covariant Countdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.number != widget.number) {
      _ac.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _sweep,
      builder: (_, __) {
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateX(math.pi / 4)
            ..scale(1.0, 0.85, 1.0),
          child: Stack(
            alignment: Alignment.center,
            children: [
              CustomPaint(
                painter: CountdownPainter(_sweep.value),
                size: Size.infinite,
              ),
              Text(
                '${widget.number}',
                style: const TextStyle(
                  color: Color(0x8CFFFFFF),
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                ),
              )
            ],
          ),
        );
      },
    );
  }
}