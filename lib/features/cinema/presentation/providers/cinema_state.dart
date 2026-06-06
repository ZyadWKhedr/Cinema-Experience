import 'package:equatable/equatable.dart';
import '../../domain/entities/seat.dart';

class CinemaState extends Equatable {
  // ── Pre-show countdown ────────────────────────────────────────────────────
  final bool isCountdownActive;
  final int  countdownNumber; // 3 → 2 → 1

  // ── Seat selection ────────────────────────────────────────────────────────
  final Seat? selectedSeatId;

  // ── Booking flow ──────────────────────────────────────────────────────────
  final bool  isConfirmed;
  final bool  showTicket;
  final bool  showThankYou;

  /// 0.0 = normal screen · 1.0 = fully CRT-collapsed (after confirmation)
  final double crtProgress;

  /// How far unselected seats have exploded away (0.0 → 1.0)
  final double seatGlideProgress;

  const CinemaState({
    required this.isCountdownActive,
    required this.countdownNumber,
    required this.selectedSeatId,
    required this.isConfirmed,
    required this.showTicket,
    required this.showThankYou,
    required this.crtProgress,
    required this.seatGlideProgress,
  });

  factory CinemaState.initial() => const CinemaState(
    isCountdownActive: true,
    countdownNumber:   3,
    selectedSeatId:    null,
    isConfirmed:       false,
    showTicket:        false,
    showThankYou:      false,
    crtProgress:       0.0,
    seatGlideProgress: 0.0,
  );

  CinemaState copyWith({
    bool?   isCountdownActive,
    int?    countdownNumber,
    // Use a sentinel so we can explicitly pass null to clear the seat
    Object? selectedSeatId = _keep,
    bool?   isConfirmed,
    bool?   showTicket,
    bool?   showThankYou,
    double? crtProgress,
    double? seatGlideProgress,
  }) {
    return CinemaState(
      isCountdownActive: isCountdownActive ?? this.isCountdownActive,
      countdownNumber:   countdownNumber   ?? this.countdownNumber,
      selectedSeatId:    selectedSeatId == _keep
          ? this.selectedSeatId
          : selectedSeatId as Seat?,
      isConfirmed:       isConfirmed       ?? this.isConfirmed,
      showTicket:        showTicket        ?? this.showTicket,
      showThankYou:      showThankYou      ?? this.showThankYou,
      crtProgress:       crtProgress       ?? this.crtProgress,
      seatGlideProgress: seatGlideProgress ?? this.seatGlideProgress,
    );
  }

  @override
  List<Object?> get props => [
    isCountdownActive, countdownNumber,
    selectedSeatId,
    isConfirmed, showTicket, showThankYou,
    crtProgress, seatGlideProgress,
  ];
}

// Sentinel object for the nullable-clear pattern in copyWith
const Object _keep = Object();