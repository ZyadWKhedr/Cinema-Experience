import 'package:equatable/equatable.dart';

enum SeatStatus {
  available,
  occupied,
}

class Seat extends Equatable {
  final String row;
  final int number;
  final SeatStatus status;

  const Seat({
    required this.row,
    required this.number,
    required this.status,
  });

  String get id => '$row$number';

  @override
  List<Object?> get props => [
        row,
        number,
        status,
      ];
}