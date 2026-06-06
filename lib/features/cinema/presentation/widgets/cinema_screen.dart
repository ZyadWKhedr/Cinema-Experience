import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/constants/cinema_constants.dart';
import 'cinema_clippers.dart';
import 'cinema_countdown.dart';

// ─────────────────────────────────────────────────────────────
// Alpha helper (NO Opacity widget)
// ─────────────────────────────────────────────────────────────
ColorFilter _alphaFilter(double a) {
  return ColorFilter.matrix([
    1, 0, 0, 0, 0,
    0, 1, 0, 0, 0,
    0, 0, 1, 0, 0,
    0, 0, 0, a, 0,
  ]);
}

// ─────────────────────────────────────────────────────────────
// Reflection gradient (kept local, not moved since it's data)
// ─────────────────────────────────────────────────────────────
final _reflColors = List.generate(51, (i) {
  final f = i / 50;
  final d = 1.0 + f * 2.2;
  final a = (1.0 / (d * d) * 0.65).clamp(0.0, 1.0);
  return Colors.black.withValues(alpha: 1.0 - a);
});

final _reflStops = List.generate(51, (i) => i / 50.0);

// ─────────────────────────────────────────────────────────────
// Cinema Screen
// ─────────────────────────────────────────────────────────────
class CinemaScreen extends StatefulWidget {
  final double crtProgress;
  final bool isCountdownActive;
  final int countdownNumber;
  final bool showThankYou;

  const CinemaScreen({
    super.key,
    this.crtProgress = 0.0,
    this.isCountdownActive = true,
    this.countdownNumber = 3,
    this.showThankYou = false,
  });

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  VideoPlayerController? _vc;
  bool _videoReady = false;

  static const _url =
      'https://www.w3schools.com/html/mov_bbb.mp4';

  @override
  void initState() {
    super.initState();
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

  // ─────────────────────────────────────────────────────────────
  // CRT physics (unchanged)
  // ─────────────────────────────────────────────────────────────
  double get _sy {
    final p = widget.crtProgress;
    return 1.0 -
        math.sin((p / 0.6).clamp(0, 1) * math.pi / 2) * 0.995;
  }

  double get _sx {
    final p = widget.crtProgress;
    if (p < 0.4) {
      return 1.0 + math.sin((p / 0.4) * math.pi) * 0.03;
    }
    return 1.0 -
        math.sin(((p - 0.4) / 0.6).clamp(0, 1) *
            math.pi / 2);
  }

  double get _alpha =>
      widget.crtProgress > 0.9
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

  // ─────────────────────────────────────────────────────────────
  Widget _content({bool flip = false}) {
    Widget inner;

    if (widget.isCountdownActive || !_videoReady) {
      inner = const ColoredBox(
        color: Colors.black,
        child: SizedBox.expand(),
      );
    } else {
      inner = FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width: _vc!.value.size.width,
          height: _vc!.value.size.height,
          child: VideoPlayer(_vc!),
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

  // ─────────────────────────────────────────────────────────────
  Widget _refl() {
    return ColorFiltered(
      colorFilter: _alphaFilter(_reflOpacity),
      child: ClipPath(
        clipper: ReflectionClipper(), 
        child: SizedBox(
          width: kTopWidth,
          height: kReflTH,
          child: Stack(
            fit: StackFit.expand,
            children: [
              ImageFiltered(
                imageFilter: ui.ImageFilter.blur(
                  sigmaX: 28,
                  sigmaY: 28,
                ),
                child: _content(flip: true),
              ),
              if (widget.isCountdownActive)
                Transform(
                  alignment: Alignment.center,
                  transform: Matrix4.diagonal3Values(1.0, -1.0, 1.0),
                  child: Countdown(number: widget.countdownNumber),
                ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _reflColors,
                      stops: _reflStops,
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              IgnorePointer(
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                        Colors.transparent,
                      ],
                      stops: [1.0, 1.8, 1.8, 1.0],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  Widget _screen() {
    return ColorFiltered(
      colorFilter: _alphaFilter(_alpha),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.diagonal3Values(_sx, _sy, 1.0),
        child: ClipPath(
          clipper: IMAXScreenClipper(), 
          child: SizedBox(
            width: kTopWidth,
            height: kCanvasH,
            child: Stack(
              fit: StackFit.expand,
              children: [
                _content(),
                if (widget.isCountdownActive)
                  Countdown(number: widget.countdownNumber), // ✅ reused
                if (_flash > 0)
                  IgnorePointer(
                    child: ColoredBox(
                      color: Colors.white.withValues(alpha: _flash),
                      child: const SizedBox.expand(),
                    ),
                  ),
                if (widget.showThankYou)
                  IgnorePointer(
                    child: ColoredBox(
                      color: Colors.black.withValues(alpha: 0.7),
                      child: const SizedBox.expand(),
                    ),
                  ),
                if (widget.showThankYou)
                  Center(
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateX(math.pi / 4)
                        ..scale(1.0, 0.85, 1.0),
                      child: const Text(
                        'THANK YOU\nENJOY THE SHOW',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0x66FFFFFF),
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 6,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final deviceW = MediaQuery.of(context).size.width;
    final scale = deviceW / kTopWidth;

    const totalH = kReflTH + kCanvasH;

    return Center(
      child: SizedBox(
        width: deviceW,
        height: totalH * scale,
        child: Transform.scale(
          scale: scale,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: kTopWidth,
            height: totalH,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(top: 0, left: -155, child: _screen()),
                Positioned(top: 105, left: -155, child: _refl()),
               
              ],
            ),
          ),
        ),
      ),
    );
  }
}