import 'dart:math' as math;
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
    final state      = ref.watch(cinemaProvider);
    final controller = ref.read(cinemaProvider.notifier);

    final groupedSeats = controller.getGroupedSeats();
    final rows         = groupedSeats.keys.toList()..sort();

    return Scaffold(
      // ── Room background (matches Swift's RoomBackgroundBrush) ────────────────
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            colors: [Color(0xFF16213E), Color(0xFF080B12), Color(0xFF000000)],
            center: Alignment.center,
            radius: 1.4,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),

              // ── Title (matches Swift's "District / BOOK YOUR TICKETS NOW") ──
              AnimatedOpacity(
                opacity: state.isConfirmed ? 0.0 : 1.0,
                duration: const Duration(milliseconds: 400),
                child: Column(children: [
                  Text(
                    'District',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 8,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'BOOK YOUR TICKETS NOW',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 3,
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 12),

              // ── Cinema screen — centered, scales to device width ─────────────
              CinemaScreen(
                isCountdownActive: state.isCountdownActive,
                countdownNumber:   state.countdownNumber,
                showThankYou:      state.showThankYou,
                crtProgress:       state.crtProgress,
              ),

              const SizedBox(height: 24),

              // ── Seating grid ─────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      for (int i = 0; i < rows.length; i++)
                        CinemaSeatRow(
                          seats:     groupedSeats[rows[i]]!,
                          rowIndex:  i,
                          totalRows: rows.length,
                        ),
                      const SizedBox(height: 120), // room for bottom sheet
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // ── Bottom sheet: seat info + confirm button ───────────────────────────
      bottomSheet: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, anim) => SlideTransition(
          position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
              .animate(CurvedAnimation(parent: anim, curve: Curves.easeOut)),
          child: child,
        ),
        child: state.selectedSeatId != null && !state.isConfirmed
            ? _BottomSheet(
                key: ValueKey(state.selectedSeatId?.id),
                seat:       state.selectedSeatId!,
                onConfirm:  () => controller.confirmSeat(),
              )
            : state.isConfirmed
                ? _TicketSheet(seat: state.selectedSeatId!)
                : const SizedBox.shrink(),
      ),
    );
  }
}

// ─── Bottom Sheet: Seat selection info + Print Ticket button ──────────────────
//
//  Mirrors Swift's CinemaSeatBottomSheet.
//
class _BottomSheet extends StatefulWidget {
  final dynamic seat; // your Seat entity
  final VoidCallback onConfirm;

  const _BottomSheet({super.key, required this.seat, required this.onConfirm});

  @override
  State<_BottomSheet> createState() => _BottomSheetState();
}

class _BottomSheetState extends State<_BottomSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 400))
    ..forward();
  late final Animation<double> _fade =
      CurvedAnimation(parent: _ac, curve: Curves.easeOut);
  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.3), end: Offset.zero,
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
        child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color:        const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color:      Colors.black.withOpacity(0.55),
                blurRadius: 30,
              )
            ],
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Info row
            Row(children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Row + seat label with staggered fade-in letters
                  _FadingLetterText(text: 'Row ${widget.seat.row} – Seat ${widget.seat.number ?? widget.seat.id}'),
                  const SizedBox(height: 4),
                  const Text(
                    '70MM IMAX PREMIER SEATING',
                    style: TextStyle(
                      color: Color(0xFF94A3B8), fontSize: 11,
                      fontWeight: FontWeight.bold, letterSpacing: 1,
                    ),
                  ),
                ]),
              ),
              ShaderMask(
                shaderCallback: (r) => const LinearGradient(
                  colors: [Color(0xFFFFD166), Color(0xFFF4C430), Color(0xFFD4AF37)],
                ).createShader(r),
                child: const Text(
                  r'$15.00',
                  style: TextStyle(
                    color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ]),

            const SizedBox(height: 24),

            // Print Ticket button
            GestureDetector(
              onTap: widget.onConfirm,
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFD166), Color(0xFFF4C430), Color(0xFFD4AF37)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFFC107).withOpacity(0.35),
                      blurRadius: 8, offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: const Center(
                  child: _WaveButtonText(text: 'Print Ticket'),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ─── Ticket bottom sheet (after confirmation) ──────────────────────────────────
class _TicketSheet extends StatelessWidget {
  final dynamic seat;
  const _TicketSheet({required this.seat});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      child: TicketPreview(seat: seat.id),
    );
  }
}

// ─── Staggered fade-in letter text (mirrors Swift's InitialFadingLetterText) ──
class _FadingLetterText extends StatefulWidget {
  final String text;
  const _FadingLetterText({required this.text});

  @override
  State<_FadingLetterText> createState() => _FadingLetterTextState();
}

class _FadingLetterTextState extends State<_FadingLetterText>
    with TickerProviderStateMixin {
  final List<AnimationController> _acs = [];

  @override
  void initState() {
    super.initState();
    _buildAnimations();
  }

  void _buildAnimations() {
    for (var i = 0; i < widget.text.length; i++) {
      final ac = AnimationController(
          vsync: this, duration: const Duration(milliseconds: 200));
      _acs.add(ac);
      Future.delayed(Duration(milliseconds: (i * 35).toInt()), () {
        if (mounted) ac.forward();
      });
    }
  }

  @override
  void dispose() {
    for (final ac in _acs) {
      ac.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        for (int i = 0; i < widget.text.length; i++)
          AnimatedBuilder(
            animation: _acs[i],
            builder: (_, __) => Opacity(
              opacity: _acs[i].value,
              child: Text(
                widget.text[i],
                style: const TextStyle(
                  color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

// ─── Wave button text (mirrors Swift's PlayfulButtonText) ─────────────────────
class _WaveButtonText extends StatefulWidget {
  final String text;
  const _WaveButtonText({required this.text});

  @override
  State<_WaveButtonText> createState() => _WaveButtonTextState();
}

class _WaveButtonTextState extends State<_WaveButtonText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ac = AnimationController(
    vsync: this, duration: const Duration(seconds: 1),
  )..repeat();

  @override
  void dispose() {
    _ac.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ac,
      builder: (_, __) {
        final phase = _ac.value * math.pi * 2 * 4; // speed=4 matches Swift
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < widget.text.length; i++)
              Transform.translate(
                offset: Offset(0, math.sin(phase + i * 0.35) * -2.0),
                child: Opacity(
                  opacity: 0.3 + ((math.sin(phase + i * 0.35) + 1) / 2) * 0.7,
                  child: Text(
                    widget.text[i],
                    style: const TextStyle(
                      color: Colors.black, fontSize: 16, fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}