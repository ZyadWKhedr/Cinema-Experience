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

    final isVipRow = rowIndex == 0;

    // 🔥 controlled scaling (no UI break)
    final double scale = 1.0 - (rowIndex * 0.03);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),

      child: Transform.translate(
        offset: Offset(
          (totalRows / 2 - rowIndex) * 6,
          0,
        ),

        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < seats.length; i++) ...[
                
                // aisle gap
                if (i == seats.length ~/ 2)
                  const SizedBox(width: 28),
          
                GestureDetector(
                  onTap: () => controller.selectSeat(seats[i]),
          
                  child: Transform.scale(
                    scale: scale,
          
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
          
                      width: 46,
                      height: 42,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
          
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
          
                        color: seats[i].status == SeatStatus.occupied
                            ? Colors.grey
                            : state.selectedSeatId?.id == seats[i].id
                                ? Colors.green
                                : isVipRow
                                    ? Colors.orangeAccent
                                    : Colors.blueGrey,
          
                        boxShadow: state.selectedSeatId?.id == seats[i].id
                            ? [
                                BoxShadow(
                                  color: Colors.green.withValues(alpha:0.5),
                                  blurRadius: 10,
                                  spreadRadius: 1,
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