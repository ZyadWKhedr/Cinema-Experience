# Cinema Experience 🎬

A premium, highly interactive Flutter application demonstrating a cutting-edge UI/UX for booking cinema tickets. This project showcases advanced custom painting, complex animations, state management, and clean architecture to deliver a "wow" factor directly out of the box.

## ✨ Features

- **3D Perspective IMAX Screen:** A dynamically curved cinema screen built using custom clippers, rendering a real video trailer with a floor reflection.
- **CRT Power Animations:** Authentic retro-style CRT power on/off animations for the screen when interacting with the checkout flow.
- **Dynamic Spotlight:** When a seat is selected, a 3D-calculated spotlight beam emerges precisely from the curved base of the IMAX screen and projects a radial glowing ellipse onto the floor around your chosen seat.
- **Interactive Seating Chart:** Custom-painted, curved seating rows with a real-time availability layout. 
- **Premium Ticket Interface:**
  - A sleek bottom sheet with staggered, fading letter animations detailing the seat info.
  - A futuristic wave-animated "Print Ticket" confirmation button.
  - A premium ticket preview with a barcode and tear-off aesthetic.
- **Fluid Transitions:** Selecting a seat smoothly glides the camera (scroll view) and dynamically dims the room.
- **Clean Architecture:** Well-organized codebase strictly separating Data, Domain, and Presentation layers, integrated using **Riverpod** for robust state management.

## 🏗 Architecture & Tech Stack

This app leverages **Riverpod** for reactive state management and dependency injection, alongside a strict layered architecture:

- **Presentation Layer:** Contains beautifully crafted custom painters (`SpotlightPainter`), clippers (`IMAXScreenClipper`), and interactive widgets (`CinemaScreen`, `SeatBottomSheet`).
- **Domain Layer:** Abstract repositories and Use Cases (e.g., `GetVideoUrlUseCase`) defining the business logic and contracts.
- **Data Layer:** Concrete implementations of repositories fetching data, simulating a scalable back-end integration.

## 🚀 Getting Started

1. Ensure you have Flutter installed (compatible with the latest stable release).
2. Clone this repository.
3. Run `flutter pub get` to install dependencies.
4. Run `flutter run` on an iOS, Android, or Web simulator.

## 💡 Inspirations & Credits

Designed to push the boundaries of what is possible with Flutter's canvas, custom animations, and implicit layout transitions.

---

*Crafted with ❤️ for the Flutter community.*
