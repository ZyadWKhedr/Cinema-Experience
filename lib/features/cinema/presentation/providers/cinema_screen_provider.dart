import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/cinema_screen_repository_impl.dart';
import '../../domain/repositories/cinema_screen_repository.dart';
import '../../domain/usecases/get_video_url_use_case.dart';

final cinemaScreenRepoProvider = Provider<CinemaScreenRepository>((ref) {
  return CinemaScreenRepositoryImpl();
});

final getVideoUrlUseCaseProvider = Provider<GetVideoUrlUseCase>((ref) {
  final repository = ref.watch(cinemaScreenRepoProvider);
  return GetVideoUrlUseCase(repository);
});

final videoUrlProvider = Provider<String>((ref) {
  return ref.watch(getVideoUrlUseCaseProvider).execute();
});