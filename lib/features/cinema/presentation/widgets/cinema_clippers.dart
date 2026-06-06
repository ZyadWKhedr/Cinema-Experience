import 'package:flutter/material.dart';
import '../../../../core/constants/cinema_constants.dart';

class IMAXScreenClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final w = s.width;
    final h = s.height;
    final inX = (w - w / kPerspective) / 2.0;

    final botCtrlY = h - (h - kTopPad) * (50.0 / 145.0);
    final topCornerY = (h - kTopPad) * (25.0 / 145.0) + kTopPad;
    final topCtrlY = kTopPad - (h - kTopPad) * (25.0 / 145.0);

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

class ReflectionClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size s) {
    final w = s.width;
    final h = s.height;

    return Path()
      ..moveTo(kInsetX, kCurveDepth + kTopPad)
      ..quadraticBezierTo(w / 2, kTopPad, w - kInsetX, kCurveDepth + kTopPad)
      ..quadraticBezierTo(w * 0.9, h * 0.5, w, h)
      ..lineTo(0, h)
      ..quadraticBezierTo(kInsetX * 0.1, h * 0.5, kInsetX, kCurveDepth + kTopPad)
      ..close();
  }

  @override
  bool shouldReclip(_) => false;
}