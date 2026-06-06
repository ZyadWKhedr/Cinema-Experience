import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/cinema_provider.dart';
import '../widgets/cinema_screen.dart';
import '../widgets/seat_row.dart';
import '../widgets/ticket_preview.dart';

class CinemaPage extends ConsumerWidget {
  const CinemaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(cinemaProvider);
    final controller = ref.read(cinemaProvider.notifier);

    final groupedSeats = controller.getGroupedSeats();

    // 🔥 FIX: stable ordering
    final rows = groupedSeats.keys.toList()..sort();

    return Scaffold(
      backgroundColor: const Color(0xFF0B1220),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // 🎬 SCREEN (fixed spacing)
            const CinemaScreen(),

            const SizedBox(height: 30),

            // 🎟 Ticket
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

            // Confirm button
            if (state.selectedSeatId != null)
              ElevatedButton(
                onPressed: state.isConfirmed
                    ? null
                    : () => controller.confirmSeat(),
                child: Text(
                  state.isConfirmed ? "Confirming..." : "Confirm Seat",
                ),
              ),

            if (state.isConfirmed)
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  "Confirming in ${state.countdown}...",
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontSize: 16,
                  ),
                ),
              ),

            const SizedBox(height: 20),

            // 🎬 SEATS AREA (FIXED LAYOUT)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (int rowIndex = 0;
                        rowIndex < rows.length;
                        rowIndex++)
                      CinemaSeatRow(
                        seats:groupedSeats[rows[rowIndex]]!,
                        rowIndex:rowIndex,
                        totalRows:rows.length,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}