import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

// ─── Geometry constants (1:1 with Swift source) ───────────────────────────────
const double _kTopWidth    = 729.0;  // ScreenTopWidth  (canvas logical width)
const double _kBottomWidth = 540.0;  // ScreenBottomWidth
const double _kPerspective = 1.35;   // _kTopWidth / _kBottomWidth
const double _kTopPad      = 25.0;   // padding inside canvas above screen
const double _kScreenH     = 145.0;  // visual screen content height
const double _kCanvasH     = _kScreenH + _kTopPad; // 170  → Positioned at y=85-170 in Swift
const double _kInsetX      = (_kTopWidth - _kBottomWidth) / 2.0; // 94.5
const double _kCurveDepth  = 50.0;

// Reflection band
const double _kReflH  = 250.0;
const double _kReflTH = _kReflH + _kTopPad; // 275  → Positioned at y=220 in Swift (center)

// ─── Gold gradient colours ────────────────────────────────────────────────────
const _gold1 = Color(0xFFFFD166);
const _gold2 = Color(0xFFF4C430);
const _gold3 = Color(0xFFD4AF37);

// ─── IMAX screen clipper ──────────────────────────────────────────────────────
//
//  Trapezoid with quadratic-bezier curved top & bottom edges.
//  Exactly mirrors Swift's IMAXScreenShape.
//
class _IMAXScreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final w   = s.width;   // _kTopWidth
    final h   = s.height;  // _kCanvasH (170)
    final inX = (w - w / _kPerspective) / 2.0;
    const tp  = _kTopPad;

    final botCtrlY  = h - (h - tp) * (50.0 / 145.0);
    final topCornerY = (h - tp) * (25.0 / 145.0) + tp;
    final topCtrlY  = tp - (h - tp) * (25.0 / 145.0);

    return Path()
      ..moveTo(inX, h)
      ..quadraticBezierTo(w / 2, botCtrlY, w - inX, h)
      ..lineTo(w, topCornerY)
      ..quadraticBezierTo(w / 2, topCtrlY, 0, topCornerY)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}

// ─── Reflection shape clipper ─────────────────────────────────────────────────
class _ReflectionClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final w = s.width;
    final h = s.height;
    const tp    = _kTopPad;
    const inX   = _kInsetX;
    const cd    = _kCurveDepth;

    return Path()
      ..moveTo(inX, cd + tp)
      ..quadraticBezierTo(w / 2, tp, w - inX, cd + tp)
      ..quadraticBezierTo(w - inX * 0.1, h * 0.5, w, h)
      ..lineTo(0, h)
      ..quadraticBezierTo(inX * 0.1, h * 0.5, inX, cd + tp)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}

// ─── Countdown painter ────────────────────────────────────────────────────────
class _CountdownPainter extends CustomPainter {
  final double sweep; // 1.0 → 0.0

  const _CountdownPainter(this.sweep);

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2, cy = size.height / 2;
    final r  = math.min(cx, cy) * 0.85;

    final line = Paint()
      ..color       = Colors.white.withOpacity(0.6)
      ..strokeWidth = 1.5
      ..style       = PaintingStyle.stroke;

    canvas.drawLine(Offset(0, cy),   Offset(size.width, cy),  line);
    canvas.drawLine(Offset(cx, 0),   Offset(cx, size.height), line);
    canvas.drawCircle(Offset(cx, cy), r, line);
    canvas.drawCircle(Offset(cx, cy), r * 0.9,
        line..strokeWidth = 3.0);

    canvas.drawArc(
      Rect.fromCircle(center: Offset(cx, cy), radius: r),
      -math.pi / 2,
      sweep * math.pi * 2,
      true,
      Paint()..color = Colors.white.withOpacity(0.15),
    );
  }

  @override
  bool shouldRepaint(_CountdownPainter o) => o.sweep != sweep;
}

// ─── Countdown widget ─────────────────────────────────────────────────────────
class _Countdown extends StatefulWidget {
  final int number;
  const _Countdown({required this.number});

  @override
  State<_Countdown> createState() => _CountdownState();
}

class _CountdownState extends State<_Countdown>
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
  void didUpdateWidget(_Countdown old) {
    super.didUpdateWidget(old);
    if (old.number != widget.number) _ac.forward(from: 0);
  }

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext ctx) {
    return AnimatedBuilder(
      animation: _sweep,
      builder: (_, __) => Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(math.pi / 4)
          ..scale(1.0, 0.85, 1.0),
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(
              painter: _CountdownPainter(_sweep.value),
              size: Size.infinite),
          Text('${widget.number}',
              style: const TextStyle(
                  color: Color(0x8CFFFFFF),
                  fontSize: 40,
                  fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}

// ─── Inverse-square reflection gradient ──────────────────────────────────────
final _reflColors = List.generate(51, (i) {
  final f = i / 50;
  final d = 1.0 + f * 2.2;
  final a = (1.0 / (d * d) * 0.65).clamp(0.0, 1.0);
  return Colors.black.withOpacity(1.0 - a);
});
final _reflStops = List.generate(51, (i) => i / 50.0);

// ─── CinemaScreen ─────────────────────────────────────────────────────────────
class CinemaScreen extends StatefulWidget {
  final double crtProgress;
  final bool   isCountdownActive;
  final int    countdownNumber;
  final bool   showThankYou;

  const CinemaScreen({
    super.key,
    this.crtProgress       = 0.0,
    this.isCountdownActive = true,
    this.countdownNumber   = 3,
    this.showThankYou      = false,
  });

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  VideoPlayerController? _vc;
  bool _videoReady = false;

  static const _url = 'https://www.w3schools.com/html/mov_bbb.mp4';

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    _vc = VideoPlayerController.networkUrl(Uri.parse(_url))
      ..initialize().then((_) {
        if (!mounted) return;
        setState(() => _videoReady = true);
        _vc!
          ..setLooping(true)
          ..setVolume(0)
          ..play();
      });
  }

  @override
  void dispose() {
    _vc?.dispose();
    super.dispose();
  }

  // ── CRT physics (exact Swift parity) ─────────────────────────────────────────
  double get _sy {
    final p = widget.crtProgress;
    return 1.0 - math.sin((p / 0.6).clamp(0, 1) * math.pi / 2) * 0.995;
  }

  double get _sx {
    final p = widget.crtProgress;
    if (p < 0.4) return 1.0 + math.sin((p / 0.4) * math.pi) * 0.03;
    return 1.0 - math.sin(((p - 0.4) / 0.6).clamp(0, 1) * math.pi / 2);
  }

  double get _alpha => widget.crtProgress > 0.9
      ? (1.0 - (widget.crtProgress - 0.9) * 10).clamp(0, 1)
      : 1.0;

  double get _flash {
    final p = widget.crtProgress;
    if (p >= 0.3 && p <= 0.9) {
      return math.sin(((p - 0.3) / 0.6) * math.pi) * 0.8;
    }
    return 0.0;
  }

  double get _reflOpacity =>
      (0.85 * (1.0 - widget.crtProgress * 4)).clamp(0, 0.85);

  // ── Video or countdown content ────────────────────────────────────────────────
  Widget _content({bool flip = false}) {
    Widget inner;

    // Show countdown when active; show video when ready AND countdown done
    if (widget.isCountdownActive || !_videoReady) {
      inner = const ColoredBox(
          color: Colors.black, child: SizedBox.expand());
    } else {
      inner = FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width:  _vc!.value.size.width,
          height: _vc!.value.size.height,
          child:  VideoPlayer(_vc!),
        ),
      );
    }

    if (flip) {
      inner = Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(1.05, -1.0, 1.0),
        child: inner,
      );
    }
    return inner;
  }

  // ── Reflection layer ──────────────────────────────────────────────────────────
  Widget _refl() => Opacity(
    opacity: _reflOpacity,
    child: ClipPath(
      clipper: _ReflectionClipper(),
      child: SizedBox(
        width: _kTopWidth, height: _kReflTH,
        child: Stack(fit: StackFit.expand, children: [
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 28, sigmaY: 28),
            child: _content(flip: true),
          ),
          if (widget.isCountdownActive)
            Transform(
              alignment: Alignment.center,
              transform: Matrix4.diagonal3Values(1.0, -1.0, 1.0),
              child: _Countdown(number: widget.countdownNumber),
            ),
          // Inverse-square vertical fade
          IgnorePointer(child: DecoratedBox(
            decoration: BoxDecoration(gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: _reflColors, stops: _reflStops,
            )),
            child: const SizedBox.expand(),
          )),
          // Side-edge fade
          IgnorePointer(child: DecoratedBox(
            decoration: const BoxDecoration(gradient: LinearGradient(
              begin: Alignment.centerLeft, end: Alignment.centerRight,
              colors: [Colors.transparent, Colors.black, Colors.black, Colors.transparent],
              stops: [0.0, 0.08, 0.92, 1.0],
            )),
            child: const SizedBox.expand(),
          )),
        ]),
      ),
    ),
  );

  // ── Main IMAX screen ──────────────────────────────────────────────────────────
  Widget _screen() => Opacity(
    opacity: _alpha,
    child: Transform(
      alignment: Alignment.center,
      transform: Matrix4.diagonal3Values(_sx, _sy, 1.0),
      child: ClipPath(
        clipper: _IMAXScreenClipper(),
        child: SizedBox(
          width: _kTopWidth, height: _kCanvasH,
          child: Stack(fit: StackFit.expand, children: [
            _content(),
            if (widget.isCountdownActive)
              _Countdown(number: widget.countdownNumber),
            // Bottom shade
            IgnorePointer(child: DecoratedBox(
              decoration: const BoxDecoration(gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [Colors.transparent, Color(0x66000000)],
              )),
              child: const SizedBox.expand(),
            )),
            // CRT flash
            if (_flash > 0) IgnorePointer(child: ColoredBox(
              color: Colors.white.withOpacity(_flash),
              child: const SizedBox.expand(),
            )),
            // Thank-you overlay
            if (widget.showThankYou) ...[
              IgnorePointer(child: ColoredBox(
                color: Colors.black.withOpacity(0.7),
                child: const SizedBox.expand(),
              )),
              Center(child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateX(math.pi / 4)
                  ..scale(1.0, 0.85, 1.0),
                child: const Text(
                  'THANK YOU\nENJOY THE SHOW',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0x66FFFFFF), fontSize: 14,
                    fontWeight: FontWeight.w900, letterSpacing: 6, height: 1.6,
                  ),
                ),
              )),
            ],
          ]),
        ),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    final deviceW = MediaQuery.of(context).size.width;
    final scale   = deviceW / _kTopWidth; // matches Swift's computedScale

    const totalH  = _kReflTH + _kCanvasH; // 275 + 170 = 445

    return Center(
      child: SizedBox(
        width:  deviceW,
        height: totalH * scale,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: _kTopWidth, height: totalH,
            child: Stack(clipBehavior: Clip.none, children: [
              Positioned(top: 0,        left: 0, child: _refl()),
              Positioned(top: _kReflTH, left: 0, child: _screen()),
            ]),
          ),
        ),
      ),
    );
  }
}