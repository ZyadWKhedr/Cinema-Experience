import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/entities/seat.dart';
import '../../providers/cinema_provider.dart';

// ─── Seat geometry (mirrors Swift constants) ──────────────────────────────────
const double _kSeatW   = 28.0;
const double _kSeatH   = 25.0;
const double _kStepX   = 64.0; // horizontal gap between seat centers
const double _kStepY   = 42.0; // vertical gap between rows

// ─── Gold colours ─────────────────────────────────────────────────────────────
const _gold1 = Color(0xFFFFD166);
const _gold2 = Color(0xFFF4C430);
const _gold3 = Color(0xFFD4AF37);
const _goldGrad = LinearGradient(
  colors: [_gold1, _gold2, _gold3],
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
);

// ─── Seat back shape (mirrors Swift's SeatBackShape) ─────────────────────────
class _SeatBackPainter extends CustomPainter {
  final bool isSelected;
  final bool isOccupied;

  const _SeatBackPainter({required this.isSelected, required this.isOccupied});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Back outline (U-shape, open at top)
    final outlinePath = Path()
      ..moveTo(0, 0)
      ..lineTo(0, h - 6)
      ..quadraticBezierTo(0, h, 6, h)
      ..lineTo(w - 6, h)
      ..quadraticBezierTo(w, h, w, h - 6)
      ..lineTo(w, 0);

    final strokeColor = isOccupied
        ? const Color(0xFF1E293B)
        : isSelected
            ? null // use shader below
            : const Color(0xFF64748B);

    if (isSelected) {
      final rect = Rect.fromLTWH(0, 0, w, h);
      final paint = Paint()
        ..shader   = _goldGrad.createShader(rect)
        ..style    = PaintingStyle.stroke
        ..strokeWidth = 3.5
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(outlinePath, paint);
    } else {
      canvas.drawPath(
        outlinePath,
        Paint()
          ..color       = strokeColor!
          ..style       = PaintingStyle.stroke
          ..strokeWidth = 3.5
          ..strokeCap   = StrokeCap.round,
      );
    }

    // Cushion bar (bottom seat pad)
    const cushionH = 8.0;
    final cushionRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(5, h - 10, w - 10, cushionH),
      const Radius.circular(1.5),
    );

    if (isSelected) {
      final paint = Paint()
        ..shader = _goldGrad.createShader(Rect.fromLTWH(0, 0, w, h));
      canvas.drawRRect(cushionRect, paint);
    } else {
      canvas.drawRRect(
        cushionRect,
        Paint()..color = isOccupied ? const Color(0xFF1E293B) : const Color(0xFF64748B),
      );
    }
  }

  @override
  bool shouldRepaint(_SeatBackPainter o) =>
      o.isSelected != isSelected || o.isOccupied != isOccupied;
}

// ─── Single seat widget ────────────────────────────────────────────────────────
class _SeatView extends StatelessWidget {
  final bool isSelected;
  final bool isOccupied;

  const _SeatView({required this.isSelected, required this.isOccupied});

  @override
  Widget build(BuildContext context) => SizedBox(
    width: _kSeatW, height: _kSeatH,
    child: CustomPaint(
      painter: _SeatBackPainter(
          isSelected: isSelected, isOccupied: isOccupied),
    ),
  );
}

// ─── CinemaSeatRow ────────────────────────────────────────────────────────────
//
//  Mirrors Swift's generatePerfectCinemaSeats layout:
//  • 11 columns per row (9 for first/last rows, corners clipped)
//  • stepX = 64, stepY = 42
//  • Perspective: rows converge toward screen — earlier rows are smaller
//    and shifted upward (matching Swift's y += rowIndex * stepY from a
//    base of 300).
//  • Horizontal centering via offset that matches a trapezoid convergence.
//
class CinemaSeatRow extends ConsumerWidget {
  final List<Seat> seats;
  final int rowIndex;
  final int totalRows;

  const CinemaSeatRow({
    super.key,
    required this.seats,
    required this.rowIndex,
    required this.totalRows,
  });

  @override
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(cinemaProvider);
  final controller = ref.read(cinemaProvider.notifier);

  const double seatSpacing = 32.0;
  const double rowHeight = 42.0;

  final double rowScale = 1.0 - (rowIndex * 0.015);

  return SizedBox(
    height: rowHeight,
    width: double.infinity,
    child: Center(
      child: Transform.scale(
        scale: rowScale,
        alignment: Alignment.center,

        child: Row(
          mainAxisSize: MainAxisSize.min, // 🔥 IMPORTANT FIX
          children: [
            for (int i = 0; i < seats.length; i++) ...[
              
              // aisle gap
              if (i == seats.length ~/ 2)
                const SizedBox(width: seatSpacing),

              GestureDetector(
                onTap: () {
                  if (seats[i].status != SeatStatus.occupied) {
                    controller.selectSeat(seats[i]);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),

                  width: _kSeatW,
                  height: _kSeatH,
                  margin: const EdgeInsets.symmetric(horizontal: 2),

                  child: _SeatView(
                    isSelected: state.selectedSeatId?.id == seats[i].id,
                    isOccupied: seats[i].status == SeatStatus.occupied,
                  ),
                ),
              ),
            ],
          ],
          ),
        ),
      ),
    );
}
}