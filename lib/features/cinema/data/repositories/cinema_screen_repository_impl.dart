import '../../domain/repositories/cinema_screen_repository.dart';

class CinemaScreenRepositoryImpl implements CinemaScreenRepository {
  @override
  String getVideoUrl() {
    return "https://www.w3schools.com/html/mov_bbb.mp4";
  }
}