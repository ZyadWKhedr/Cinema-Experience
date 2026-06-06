import 'package:equatable/equatable.dart';

import '../../domain/entities/seat.dart';

class CinemaState extends Equatable {
  final int countdown;

  final Seat? selectedSeatId;

  final bool isConfirmed;

  final bool showTicket;

  final bool showThankYou;

  const CinemaState({
    required this.countdown,
    required this.selectedSeatId,
    required this.isConfirmed,
    required this.showTicket,
    required this.showThankYou,
  });

  factory CinemaState.initial() {
    return const CinemaState(
      countdown: 3,
      selectedSeatId: null,
      isConfirmed: false,
      showTicket: false,
      showThankYou: false,
    );
  }

  CinemaState copyWith({
    int? countdown,
    Seat? selectedSeatId,
    bool? isConfirmed,
    bool? showTicket,
    bool? showThankYou,
  }) {
    return CinemaState(
      countdown: countdown ?? this.countdown,
      selectedSeatId: selectedSeatId ?? this.selectedSeatId,
      isConfirmed: isConfirmed ?? this.isConfirmed,
      showTicket: showTicket ?? this.showTicket,
      showThankYou: showThankYou ?? this.showThankYou,
    );
  }

  @override
  List<Object?> get props => [
        countdown,
        selectedSeatId,
        isConfirmed,
        showTicket,
        showThankYou,
      ];
}