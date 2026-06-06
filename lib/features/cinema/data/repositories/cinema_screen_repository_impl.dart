import '../../domain/repositories/cinema_screen_repository.dart';

class CinemaScreenRepositoryImpl implements CinemaScreenRepository {
  @override
  String getVideoUrl() {
    return "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4";
  }
}