import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/seat.dart';
import 'cinema_state.dart';

final cinemaProvider =
    NotifierProvider<CinemaController, CinemaState>(
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

    state = state.copyWith(
      selectedSeatId: seat,
    );
  }
}