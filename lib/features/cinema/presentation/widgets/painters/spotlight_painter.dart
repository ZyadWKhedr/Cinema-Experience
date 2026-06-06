import 'package:flutter/material.dart';
import '../../../domain/entities/seat.dart';

class SpotlightPainter extends CustomPainter {
  final Seat selectedSeatId;
  final List<String> rows;
  final Map<String, List<Seat>> groupedSeats;
  final double scrollOffset;

  SpotlightPainter({
    required this.selectedSeatId,
    required this.rows,
    required this.groupedSeats,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int rowIndex = rows.indexOf(selectedSeatId.row);
    if (rowIndex == -1) return;

    final List<Seat> seatsInRow = groupedSeats[selectedSeatId.row]!;
    final int seatIndex = seatsInRow.indexWhere(
      (s) => s.id == selectedSeatId.id,
    );
    if (seatIndex == -1) return;

    final double rowHeight = 42.0;
    final double rowScale = 1.0 - (rowIndex * 0.015);

    double totalWidth = seatsInRow.length * 32.0;
    if (seatsInRow.length > 1) {
      totalWidth += 32.0; // aisle gap
    }

    double seatOffset = 0.0;
    for (int i = 0; i < seatIndex; i++) {
      if (i == seatsInRow.length ~/ 2) {
        seatOffset += 32.0;
      }
      seatOffset += 32.0;
    }
    if (seatIndex == seatsInRow.length ~/ 2) {
      seatOffset += 32.0;
    }

    final double scaledWidth = totalWidth * rowScale;
    final double startX = size.width / 2 - scaledWidth / 2;
    final double seatX = startX + (seatOffset + 16.0) * rowScale;
    final double seatY = rowIndex * rowHeight + 21.0 - scrollOffset;

    if (seatY < 0) return;

    final double startY = -(24.0 + 300.0 * (size.width / 729.0));

    // To make a circular spotlight base on the seat, we draw the beam and an ellipse at the bottom
    final Path path = Path();
    path.moveTo(
      size.width / 2 - 25,
      startY,
    ); // screen bottom left, thinner and higher
    path.lineTo(size.width / 2 + 25, startY); // screen bottom right
    path.lineTo(
      seatX + 20 * rowScale,
      seatY + 12 * rowScale,
    ); // seat bottom right, thinner
    path.lineTo(
      seatX - 20 * rowScale,
      seatY + 12 * rowScale,
    ); // seat bottom left
    path.close();

    // Draw the main beam
    final Paint beamPaint = Paint()
      ..shader =
          LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.15),
              const Color(0xFFF4C430).withValues(alpha: 0.3),
              const Color(0xFFF4C430).withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromPoints(
              Offset(size.width / 2, startY),
              Offset(seatX, seatY),
            ),
          )
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, beamPaint);

    // Draw the circle/ellipse spotlight strictly on the seat
    final double ellipseWidth = 40.0 * rowScale;
    final double ellipseHeight = 16.0 * rowScale;
    final Rect ellipseRect = Rect.fromCenter(
      center: Offset(seatX, seatY + 8 * rowScale), 
      width: ellipseWidth, 
      height: ellipseHeight
    );

    final Paint ellipsePaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFF4C430).withValues(alpha: 0.6),
          const Color(0xFFF4C430).withValues(alpha: 0.0),
        ],
      ).createShader(ellipseRect)
      ..style = PaintingStyle.fill;

    canvas.drawOval(ellipseRect, ellipsePaint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.selectedSeatId != selectedSeatId ||
        oldDelegate.scrollOffset != scrollOffset;
  }
}
