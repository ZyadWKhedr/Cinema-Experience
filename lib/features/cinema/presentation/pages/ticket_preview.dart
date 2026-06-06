import 'package:flutter/material.dart';
import '../../domain/entities/seat.dart';

class TicketPreview extends StatelessWidget {
  final Seat seat;

  const TicketPreview({super.key, required this.seat});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width - 40,
        height: 140,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 25,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left part (Main ticket details)
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'DISTRICT CINEMA',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Oppenheimer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _buildInfoColumn('DATE', 'Oct 24'),
                        const SizedBox(width: 24),
                        _buildInfoColumn('TIME', '19:30'),
                        const SizedBox(width: 24),
                        _buildInfoColumn('ROW', '${seat.row}'),
                        const SizedBox(width: 24),
                        _buildInfoColumn('SEAT', '${seat.number}'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Dotted separator
            Column(
              children: List.generate(
                14,
                (index) => Expanded(
                  child: Container(
                    width: 2,
                    color: index % 2 == 0 ? Colors.white24 : Colors.transparent,
                  ),
                ),
              ),
            ),
            // Right part (Barcode & Status)
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green, width: 1),
                      ),
                      child: const Text(
                        'CONFIRMED',
                        style: TextStyle(color: Colors.green, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Spacer(),
                    // Fake Barcode
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(12, (index) {
                        final widths = [2.0, 4.0, 1.0, 3.0, 2.0, 5.0, 1.0, 2.0, 4.0, 1.0, 3.0, 2.0];
                        return Container(
                          width: widths[index],
                          height: 40,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          color: Colors.white54,
                        );
                      }),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '84920183',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 8,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white54, fontSize: 9, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}