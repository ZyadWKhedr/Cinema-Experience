import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class CinemaScreen extends StatefulWidget {
  const CinemaScreen({super.key});

  @override
  State<CinemaScreen> createState() => _CinemaScreenState();
}

class _CinemaScreenState extends State<CinemaScreen> {
  late VideoPlayerController controller;

  @override
  void initState() {
    super.initState();

    // 🔥 Replace with any local asset or network video
    controller = VideoPlayerController.networkUrl(
      Uri.parse(
        "https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4",
      ),
    )
      ..initialize().then((_) {
        setState(() {});
        controller.setLooping(true);
        controller.play();
      });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  

  @override
  Widget build(BuildContext context) {

    final double radius = 260;
final double centerIndex = (totalRows - 1) / 2;

// angle spread (controls how wide the cinema is)
final double angleStep = 0.35;

// convert row index → angle
final double angle = (rowIndex - centerIndex) * angleStep;

// REAL ARC math
final double dx = radius * sin(angle);
final double dy = radius * (1 - cos(angle));

    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()
        ..setEntry(3, 2, 0.001)
        ..rotateX(-0.22),

      child: Container(
        width: double.infinity,
        height: 120,
        margin: const EdgeInsets.symmetric(horizontal: 20),

        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50),

          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.25),
              blurRadius: 40,
              spreadRadius: 2,
              offset: const Offset(0, 20),
            ),
          ],
        ),

        child: ClipRRect(
          borderRadius: BorderRadius.circular(50),

          child: controller.value.isInitialized
              ? Stack(
                  children: [
                    // 🎥 VIDEO
                    SizedBox.expand(
                      child: FittedBox(
                        fit: BoxFit.cover,
                        child: SizedBox(
                          width: controller.value.size.width,
                          height: controller.value.size.height,
                          child: VideoPlayer(controller),
                        ),
                      ),
                    ),

                    // 🌑 DARK OVERLAY (cinema feel)
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withOpacity(0.4),
                            Colors.black.withOpacity(0.7),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),
                    ),

                    // ✨ SCREEN LABEL
                    const Center(
                      child: Text(
                        "NOW SHOWING",
                        style: TextStyle(
                          color: Colors.white70,
                          letterSpacing: 4,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                )
              : const Center(
                  child: CircularProgressIndicator(),
                ),
        ),
      ),
    );
  }
}