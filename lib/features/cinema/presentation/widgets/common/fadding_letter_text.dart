import 'package:flutter/material.dart';

/// Staggered fade-in letter text.
class FadingLetterText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const FadingLetterText({
    super.key,
    required this.text,
    this.style = const TextStyle(
      color: Colors.white,
      fontSize: 17,
      fontWeight: FontWeight.bold,
    ),
  });

  @override
  State<FadingLetterText> createState() => _FadingLetterTextState();
}

class _FadingLetterTextState extends State<FadingLetterText>
    with TickerProviderStateMixin {
  final List<AnimationController> _acs = [];

  @override
  void initState() {
    super.initState();
    _build();
  }

  void _build() {
    for (var i = 0; i < widget.text.length; i++) {
      final ac = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 200),
      );
      _acs.add(ac);
      Future.delayed(Duration(milliseconds: i * 35), () {
        if (mounted) ac.forward();
      });
    }
  }

  @override
  void didUpdateWidget(covariant FadingLetterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.text != widget.text) {
      for (final ac in _acs) {
        ac.dispose();
      }
      _acs.clear();
      _build();
    }
  }

  @override
  void dispose() {
    for (final ac in _acs) {
      ac.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (int i = 0; i < widget.text.length; i++)
          AnimatedBuilder(
            animation: _acs[i],
            builder: (_, __) => Opacity(
              opacity: _acs[i].value,
              child: Text(widget.text[i], style: widget.style),
            ),
          ),
      ],
    );
  }
}