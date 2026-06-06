import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/cinema_screen_repository_impl.dart';
import '../../domain/repositories/cinema_screen_repository.dart';

final cinemaScreenRepoProvider =
    Provider<CinemaScreenRepository>((ref) {
  return CinemaScreenRepositoryImpl();
});