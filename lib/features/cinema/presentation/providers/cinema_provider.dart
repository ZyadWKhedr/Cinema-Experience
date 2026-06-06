import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/seat.dart';
import 'cinema_state.dart';

final cinemaProvider = NotifierProvider<CinemaController, CinemaState>(
  CinemaController.new,
);

class CinemaController extends Notifier<CinemaState> {
  @override
  CinemaState build() {
    return CinemaState.initial();
  }

  // NEW: generate fake cinema seats
  List<Seat> getSeats() {
    const rows = ['A', 'B', 'C', 'D', 'E'];
    const seatsPerRow = 8;

    return [
      for (final row in rows)
        for (int i = 1; i <= seatsPerRow; i++)
          Seat(
            row: row,
            number: i,
            status: (i == 3 && row == 'B')
                ? SeatStatus.occupied
                : SeatStatus.available,
          ),
    ];
  }

  void selectSeat(Seat seat) {
  if (seat.status == SeatStatus.occupied) return;
  if (state.isConfirmed) return;

  state = state.copyWith(
    selectedSeatId: seat,
  );
}

  Map<String, List<Seat>> getGroupedSeats() {
    final seats = getSeats();

    final Map<String, List<Seat>> grouped = {};

    for (final seat in seats) {
      grouped.putIfAbsent(seat.row, () => []);
      grouped[seat.row]!.add(seat);
    }

    return grouped;
  }

  void confirmSeat() {
    final seat = state.selectedSeatId;

    if (seat == null) return;

    state = state.copyWith(isConfirmed: true, countdown: 3);

    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 3; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));

      state = state.copyWith(countdown: i);
    }

    state = state.copyWith(showThankYou: true, isConfirmed: false);
  }

  void resetFlow() {
  state = CinemaState.initial();
}
}
