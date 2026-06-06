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

  void selectSeat(Seat seat) {
    state = state.copyWith(
      selectedSeatId: seat,
    );
  }
}