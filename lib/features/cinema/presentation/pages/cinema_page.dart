import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/seat.dart';
import '../providers/cinema_provider.dart';
import '../widgets/cinema_screen.dart';
import '../widgets/ticket_preview.dart';

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

            AnimatedSwitcher(
  duration: const Duration(milliseconds: 300),
  child: state.selectedSeatId == null
      ? const Text(
          "Select a seat",
          key: ValueKey("empty"),
          style: TextStyle(color: Colors.white70),
        )
      : TicketPreview(
          key: ValueKey("ticket"),
          seat: state.selectedSeatId!,
        ),
),

            const SizedBox(height: 20),

            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (
                    int rowIndex = 0;
                    rowIndex < rows.length;
                    rowIndex++
                  ) ...[
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
  final isVipRow = rowIndex == 0;
  // closer rows = bigger seats
  final double scale = 1 - (rowIndex * 0.08);

  return Transform.translate(
  offset: Offset(
    (totalRows / 2 - rowIndex) * 2.5, // centered curve
    0,
  ), //  creates curve illusion

    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < seats.length; i++) ...[
          // 👇 create aisle gap in the middle
          if (i == seats.length ~/ 2) const SizedBox(width: 30),

          GestureDetector(
            onTap: () => controller.selectSeat(seats[i]),

            child: Transform.scale(
  scale: scale,

  child: Animate(
    effects: [
      ScaleEffect(
        begin: const Offset(1, 1),
        end: const Offset(1.15, 1.15),
        duration: 200.ms,
        curve: Curves.easeOut,
      ),
      FadeEffect(duration: 200.ms),
    ],

    target: state.selectedSeatId?.id == seats[i].id ? 1 : 0,

    child: Container(
      width: 28,
      height: 25,
      margin: const EdgeInsets.symmetric(horizontal: 3),

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
                  color: Colors.green.withValues(alpha:0.6),
                  blurRadius: 15,
                  spreadRadius: 2,
                )
              ]
            : [],
      ),

      child: Center(
        child: Text(
          seats[i].id,
          style: const TextStyle(
            fontSize: 10,
            color: Colors.white,
          ),
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
