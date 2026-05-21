# auksine-bycke

**A Flutter mobile app — built for the road, written in Dart.**

*"Auksinė bičkė"* — sleek, fast, and cross-platform.

---

## What is this?

`auksine-bycke` is a Flutter application targeting iOS and Android (with desktop support baked in). The codebase lives in `src/flutter/` and is primarily written in Dart, with native platform integrations handled via C++/CMake (Android/desktop) and Swift (iOS).

---

## Project Structure

```
auksine-bycke/
├── src/
│   └── flutter/        # All the Flutter app code lives here
├── .gitignore
├── LICENSE             # GPL-3.0
└── README.md
```

---

## Tech Stack

| Language | Role |
|----------|------|
| **Dart** | Core app logic & UI |
| **C++ / CMake** | Native plugin bindings |
| **Swift** | iOS-specific integration |
| **Ruby** | CocoaPods dependency management |

---

## Getting Started

Make sure you have [Flutter](https://flutter.dev/docs/get-started/install) installed, then:

```bash
# Clone the repo
git clone https://github.com/NojusKondrotas/auksine-bycke.git
cd auksine-bycke/src/flutter

# Install dependencies
flutter pub get

# Run the app
flutter run
```

---

## License

Released under the **GPL-3.0** license. See [`LICENSE`](./LICENSE) for details.

---

> Built with 💛 and Flutter.
