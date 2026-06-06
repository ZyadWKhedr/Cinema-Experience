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

    final seats = controller.getSeats();

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
          child: GridView.builder(
            itemCount: seats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 8,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
            ),
            itemBuilder: (context, index) {
              final seat = seats[index];
              final isSelected = state.selectedSeatId?.id == seat.id;

              return GestureDetector(
                onTap: () => controller.selectSeat(seat),
                child: Container(
                  decoration: BoxDecoration(
                    color: seat.status == SeatStatus.occupied
                        ? Colors.grey
                        : isSelected
                            ? Colors.green
                            : Colors.blueGrey,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(child: Text(seat.id)),
                ),
              );
            },
          ),
        ),
      ],
    ),
  ),
);
  }
}