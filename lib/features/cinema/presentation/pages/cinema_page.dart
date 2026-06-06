import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cinema_provider.dart';
import '../providers/cinema_state.dart';
import '../widgets/screen/cinema_screen.dart';
import '../widgets/seat/seat_bottom_sheet.dart';
import '../widgets/seat/seat_row.dart';
import '../widgets/painters/spotlight_painter.dart';

class CinemaPage extends ConsumerStatefulWidget {
  const CinemaPage({super.key});

  @override
  ConsumerState<CinemaPage> createState() => _CinemaPageState();
}

class _CinemaPageState extends ConsumerState<CinemaPage> {
  final ScrollController _scrollController = ScrollController();
  double _scrollOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {
        _scrollOffset = _scrollController.offset;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cinemaProvider);
    final controller = ref.read(cinemaProvider.notifier);

    final groupedSeats = controller.getGroupedSeats();
    final rows = groupedSeats.keys.toList()..sort();

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBody: true,
      resizeToAvoidBottomInset: false,

      body: Stack(
        children: [
          // ─────────────────────────────────────────────
          // BACKGROUND + MAIN UI
          // ─────────────────────────────────────────────
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [
                  Color(0xFF16213E),
                  Color(0xFF080B12),
                  Color(0xFF000000),
                ],
                center: Alignment.center,
                radius: 1.4,
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),

                  AnimatedOpacity(
                    opacity: state.isConfirmed ? 0.0 : 1.0,
                    duration: const Duration(milliseconds: 400),
                    child: Column(
                      children: [
                        const Text(
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
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 3,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  CinemaScreen(
                    isCountdownActive: state.isCountdownActive,
                    countdownNumber: state.countdownNumber,
                    showThankYou: state.showThankYou,
                    crtProgress: state.crtProgress,
                  ),

                  const SizedBox(height: 24),

                  Expanded(
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        if (state.selectedSeatId != null)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: SpotlightPainter(
                                selectedSeatId: state.selectedSeatId!,
                                rows: rows,
                                groupedSeats: groupedSeats,
                                scrollOffset: _scrollOffset,
                              ),
                            ),
                          ),
                        SingleChildScrollView(
                          controller: _scrollController,
                          physics: const BouncingScrollPhysics(),
                          child: Column(
                            children: [
                              for (int i = 0; i < rows.length; i++)
                                CinemaSeatRow(
                                  seats: groupedSeats[rows[i]]!,
                                  rowIndex: i,
                                  totalRows: rows.length,
                                ),
                              const SizedBox(height: 250),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─────────────────────────────────────────────
          // OVERLAY SHEET
          // ─────────────────────────────────────────────
          _buildOverlay(state, controller),
        ],
      ),
    );
  }

  Widget _buildOverlay(CinemaState state, CinemaController controller) {
    if (state.selectedSeatId == null) {
      return const SizedBox.shrink();
    }
    if (state.isConfirmed && !state.showTicket) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: SafeArea(
        top: false,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          tween: Tween(begin: 1.0, end: 0.0),
          builder: (context, v, child) {
            return Transform.translate(
              offset: Offset(0, 120 * v),
              child: child,
            );
          },
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: state.showTicket
                ? TicketSheet(seat: state.selectedSeatId!)
                : SeatBottomSheet(
                    seat: state.selectedSeatId!,
                    onConfirm: controller.confirmSeat,
                  ),
          ),
        ),
      ),
    );
  }
}
