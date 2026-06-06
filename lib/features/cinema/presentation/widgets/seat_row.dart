import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/seat.dart';
import '../providers/cinema_provider.dart';

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
    final controller = ref.read(cinemaProvider.notifier);
    final state = ref.watch(cinemaProvider);

    // 🎯 ARC CONFIG
    const double radius = 280;
    const double angleStep = 0.35;

    final double centerIndex = (totalRows - 1) / 2;
    final double angle = (rowIndex - centerIndex) * angleStep;

    // 🎬 TRUE CIRCLE PROJECTION
    final double dx = radius * sin(angle);
    final double dy = radius * (1 - cos(angle));

    // 🎯 depth-based scaling (farther rows = smaller)
    final double scale = 1.0 - (angle.abs() * 0.25);

    final bool isVipRow = rowIndex == 0;

    return Transform.translate(
      offset: Offset(dx, dy),
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.001)
          ..rotateX(-angle * 0.7),

        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < seats.length; i++) ...[
                
                // 🎟 aisle gap (cinema center walkway)
                if (i == seats.length ~/ 2)
                  const SizedBox(width: 32),

                GestureDetector(
                  onTap: () => controller.selectSeat(seats[i]),

                  child: Transform.scale(
                    scale: scale,

                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),

                      width: 26,
                      height: 26,

                      margin: const EdgeInsets.symmetric(horizontal: 2),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),

                        color: seats[i].status == SeatStatus.occupied
                            ? Colors.grey.shade700
                            : state.selectedSeatId?.id == seats[i].id
                                ? Colors.greenAccent
                                : isVipRow
                                    ? Colors.orangeAccent
                                    : Colors.blueGrey.shade600,

                        boxShadow: state.selectedSeatId?.id == seats[i].id
                            ? [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.6),
                                  blurRadius: 14,
                                  spreadRadius: 2,
                                )
                              ]
                            : [],
                      ),

                      child: Center(
                        child: Text(
                          seats[i].id,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
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