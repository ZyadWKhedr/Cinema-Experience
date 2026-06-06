import '../repositories/cinema_screen_repository.dart';

class GetVideoUrlUseCase {
  final CinemaScreenRepository repository;

  GetVideoUrlUseCase(this.repository);

  String execute() {
    return repository.getVideoUrl();
  }
}
