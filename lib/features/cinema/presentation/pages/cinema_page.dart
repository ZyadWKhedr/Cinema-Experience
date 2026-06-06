import 'package:flutter/material.dart';
import '../../domain/entities/seat.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cinema_provider.dart';
import '../providers/cinema_state.dart';
import '../widgets/cinema_screen.dart';
import '../widgets/seat_bottom_sheet.dart';
import '../widgets/seat_row.dart';

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

class SpotlightPainter extends CustomPainter {
  final Seat selectedSeatId;
  final List<String> rows;
  final Map<String, List<Seat>> groupedSeats;
  final double scrollOffset;

  SpotlightPainter({
    required this.selectedSeatId,
    required this.rows,
    required this.groupedSeats,
    required this.scrollOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final int rowIndex = rows.indexOf(selectedSeatId.row);
    if (rowIndex == -1) return;

    final List<Seat> seatsInRow = groupedSeats[selectedSeatId.row]!;
    final int seatIndex = seatsInRow.indexWhere(
      (s) => s.id == selectedSeatId.id,
    );
    if (seatIndex == -1) return;

    final double rowHeight = 42.0;
    final double rowScale = 1.0 - (rowIndex * 0.015);

    double totalWidth = seatsInRow.length * 32.0;
    if (seatsInRow.length > 1) {
      totalWidth += 32.0; // aisle gap
    }

    double seatOffset = 0.0;
    for (int i = 0; i < seatIndex; i++) {
      if (i == seatsInRow.length ~/ 2) {
        seatOffset += 32.0;
      }
      seatOffset += 32.0;
    }
    if (seatIndex == seatsInRow.length ~/ 2) {
      seatOffset += 32.0;
    }

    final double scaledWidth = totalWidth * rowScale;
    final double startX = size.width / 2 - scaledWidth / 2;
    final double seatX = startX + (seatOffset + 16.0) * rowScale;
    final double seatY = rowIndex * rowHeight + 21.0 - scrollOffset;

    if (seatY < 0) return;

    final double startY = -(24.0 + 300.0 * (size.width / 729.0));

    final Path path = Path();
    path.moveTo(
      size.width / 2 - 25,
      startY,
    ); // screen bottom left, thinner and higher
    path.lineTo(size.width / 2 + 25, startY); // screen bottom right
    path.lineTo(
      seatX + 16 * rowScale,
      seatY + 12 * rowScale,
    ); // seat bottom right, thinner
    path.lineTo(
      seatX - 16 * rowScale,
      seatY + 12 * rowScale,
    ); // seat bottom left
    path.close();

    final Paint paint = Paint()
      ..shader =
          LinearGradient(
            colors: [
              Colors.white.withValues(alpha: 0.15),
              const Color(0xFFF4C430).withValues(alpha: 0.3),
              const Color(0xFFF4C430).withValues(alpha: 0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(
            Rect.fromPoints(
              Offset(size.width / 2, startY),
              Offset(seatX, seatY),
            ),
          )
      ..style = PaintingStyle.fill;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant SpotlightPainter oldDelegate) {
    return oldDelegate.selectedSeatId != selectedSeatId ||
        oldDelegate.scrollOffset != scrollOffset;
  }
}
