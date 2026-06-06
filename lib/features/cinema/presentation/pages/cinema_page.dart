import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/seat.dart';
import '../providers/cinema_provider.dart';
import '../widgets/cinema_screen.dart';

class CinemaPage extends ConsumerWidget {
  const CinemaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cinemaProvider);
    final controller = ref.read(cinemaProvider.notifier);

    final groupedSeats = controller.getGroupedSeats();
    final rows = groupedSeats.keys.toList();

    return Scaffold(
  body: Padding(
    padding: const EdgeInsets.all(20),
    child: Column(
      children: [
        
        const SizedBox(height: 60),

        const CinemaScreen(),

        const SizedBox(height: 40),

        Text(
          state.selectedSeatId?.id ?? 'No Seat Selected',
        ),

        const SizedBox(height: 20),

       Expanded(
  child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      for (int rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
        _buildSeatRow(
          context,
          ref,
          groupedSeats[rows[rowIndex]]!,
          rowIndex,
          rows.length,
        ),
        const SizedBox(height: 10),
      ],
    ],
  ),
),
      ],
    ),
  ),
);
  }
}

Widget _buildSeatRow(
  BuildContext context,
  WidgetRef ref,
  List<Seat> seats,
  int rowIndex,
  int totalRows,
) {
  final controller = ref.read(cinemaProvider.notifier);
  final state = ref.watch(cinemaProvider);

  // closer rows = bigger seats
  final double scale = 1 - (rowIndex * 0.08);

  return Transform.translate(
    offset: Offset(rowIndex * 6.0, 0), //  creates curve illusion

    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (final seat in seats) ...[
          GestureDetector(
            onTap: () => controller.selectSeat(seat),

            child: Transform.scale(
              scale: scale, // 👈 depth effect

              child: Container(
                width: 28,
                height: 25,
                margin: const EdgeInsets.symmetric(horizontal: 3),

                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),

                  color: seat.status == SeatStatus.occupied
                      ? Colors.grey
                      : state.selectedSeatId?.id == seat.id
                          ? Colors.green
                          : Colors.blueGrey,
                ),

                child: Center(
                  child: Text(
                    seat.id,
                    style: const TextStyle(
                      fontSize: 10,
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
  );
}