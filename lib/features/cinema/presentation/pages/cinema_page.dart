import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/cinema_provider.dart';

class CinemaPage extends ConsumerWidget {
  const CinemaPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final state = ref.watch(cinemaProvider);

   return Scaffold(
  body: Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          state.selectedSeatId ?? 'No Seat Selected',
        ),

        const SizedBox(height: 20),

        ElevatedButton(
          onPressed: () {
            ref
                .read(cinemaProvider.notifier)
                .selectSeat('A5');
          },
          child: const Text(
            'Select A5',
          ),
        ),
      ],
    ),
  ),
);
  }
}