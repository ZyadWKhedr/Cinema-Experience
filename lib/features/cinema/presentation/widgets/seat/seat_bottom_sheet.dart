import 'package:flutter/material.dart';

import '../../../domain/entities/seat.dart';
import '../common/fadding_letter_text.dart';
import '../../pages/ticket_preview.dart';
import '../common/wave_button_text.dart';

// ─── Seat-selection bottom sheet ─────────────────────────────────────────────
//
//  Mirrors Swift's CinemaSeatBottomSheet: seat label, price, Print Ticket CTA.
//
class SeatBottomSheet extends StatefulWidget {
  final Seat seat;
  final VoidCallback onConfirm;

  const SeatBottomSheet({
    super.key,
    required this.seat,
    required this.onConfirm,
  });

  @override
  State<SeatBottomSheet> createState() => _SeatBottomSheetState();
}

class _SeatBottomSheetState extends State<SeatBottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 400),
  )..forward();

  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOut);

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.25),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOut));

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 30,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Info row ────────────────────────────────────────────────────
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadingLetterText(
                          text: 'Row ${widget.seat.row} – Seat ${widget.seat.number}',
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          '70MM IMAX PREMIER SEATING',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ShaderMask(
                    shaderCallback: (r) => const LinearGradient(
                      colors: [
                        Color(0xFFFFD166),
                        Color(0xFFF4C430),
                        Color(0xFFD4AF37),
                      ],
                    ).createShader(r),
                    child: const Text(
                      r'$15.00',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ]),
          
                const SizedBox(height: 24),
          
                // ── Print Ticket button ─────────────────────────────────────────
                GestureDetector(
                  onTap: widget.onConfirm,
                  child: Container(
                    height: 60,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFFD166),
                          Color(0xFFF4C430),
                          Color(0xFFD4AF37),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFC107).withValues(alpha: 0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: WaveButtonText(text: 'Print Ticket'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Post-confirmation ticket sheet ──────────────────────────────────────────
class TicketSheet extends StatelessWidget {
  final Seat seat;

  const TicketSheet({super.key, required this.seat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: TicketPreview(seat: seat),
    );
  }
}