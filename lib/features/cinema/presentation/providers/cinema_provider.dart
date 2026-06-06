import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/seat.dart';
import 'cinema_state.dart';

final cinemaProvider = NotifierProvider<CinemaController, CinemaState>(
  CinemaController.new,
);

class CinemaController extends Notifier<CinemaState> {
  @override
  CinemaState build() {
    // Kick off the pre-show countdown as soon as the provider is created.
    // We schedule it post-frame so `state` is fully initialised first.
    Future.microtask(_startPreShowCountdown);
    return CinemaState.initial();
  }

  // ── Seat data ─────────────────────────────────────────────────────────────

  List<Seat> getSeats() {
    const rows        = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I'];
    const seatsPerRow = 11;

    return [
      for (final row in rows)
        for (int i = 1; i <= seatsPerRow; i++)
          Seat(
            row:    row,
            number: i,
            status: _isOccupied(row, i)
                ? SeatStatus.occupied
                : SeatStatus.available,
          ),
    ];
  }

  /// ~15 % random-looking occupied seats, stable across calls.
  bool _isOccupied(String row, int number) {
    const occupied = {
      'A3', 'B7', 'C2', 'C9', 'D5', 'E1', 'E11',
      'F4', 'F8', 'G3', 'H6', 'I2', 'I9',
    };
    return occupied.contains('$row$number');
  }

  Map<String, List<Seat>> getGroupedSeats() {
    final grouped = <String, List<Seat>>{};
    for (final seat in getSeats()) {
      grouped.putIfAbsent(seat.row, () => []).add(seat);
    }
    return grouped;
  }

  // ── Selection ─────────────────────────────────────────────────────────────

  void selectSeat(Seat seat) {
    if (seat.status == SeatStatus.occupied) return;
    if (state.isConfirmed) return;

    // Tap same seat → deselect
    final next = state.selectedSeatId?.id == seat.id ? null : seat;
    state = state.copyWith(selectedSeatId: next);
  }

  // ── Pre-show 3-2-1 countdown (mirrors Swift's startCountdownFlow) ─────────

  Future<void> _startPreShowCountdown() async {
    state = state.copyWith(isCountdownActive: true, countdownNumber: 3);

    for (int n = 3; n >= 1; n--) {
      state = state.copyWith(countdownNumber: n);
      await Future.delayed(const Duration(seconds: 1));
    }

    state = state.copyWith(isCountdownActive: false);
  }

  // ── Checkout flow (mirrors Swift's startCheckoutFlow) ────────────────────
  //
  //  Timeline (seconds from tap):
  //   0.0  → isConfirmed=true, showThankYou=true
  //   1.2  → crtProgress animates 0→1 over 0.75 s
  //         seatGlideProgress animates 0→1 over 0.8 s
  //   2.2  → showTicket=true
  //
  Future<void> confirmSeat() async {
    if (state.selectedSeatId == null) return;

    // Step 1: Confirm + show thank-you overlay
    state = state.copyWith(isConfirmed: true, showThankYou: true);

    await Future.delayed(const Duration(milliseconds: 1200));

    // Step 2: Animate CRT collapse + seat explosion in small increments
    //         (real apps would use AnimationController; we simulate with ticks)
    const steps     = 30;
    const crtMs     = 750;
    const glideMs   = 800;
    const tickMs    = 16; // ~60 fps

    for (int i = 1; i <= steps; i++) {
      await Future.delayed(const Duration(milliseconds: tickMs));
      final t = i / steps;
      // CRT: 0→1 over crtMs
      final crtT   = (i * tickMs / crtMs).clamp(0.0, 1.0);
      // Glide: 0→1 over glideMs (spring feel via ease-in-out-cubic)
      final rawG   = (i * tickMs / glideMs).clamp(0.0, 1.0);
      final glideT = _easeInOutCubic(rawG);
      state = state.copyWith(crtProgress: crtT, seatGlideProgress: glideT);
    }

    await Future.delayed(const Duration(milliseconds: 200));

    // Step 3: Show ticket
    state = state.copyWith(showTicket: true);
  }

  // ── Reset (mirrors Swift's resetBooking) ──────────────────────────────────

  Future<void> resetFlow() async {
    state = state.copyWith(showTicket: false);

    await Future.delayed(const Duration(milliseconds: 300));

    state = CinemaState.initial().copyWith(
      // Keep countdown already done so we go straight to video
      isCountdownActive: false,
    );

    // Re-run pre-show countdown for a fresh booking
    _startPreShowCountdown();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  double _easeInOutCubic(double t) {
    if (t < 0.5) return 4 * t * t * t;
    final u = -2 * t + 2;
    return 1 - u * u * u / 2;
  }
}