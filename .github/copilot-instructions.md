# GitHub Copilot Instructions

## About this Project

This is a Flutter application for maintenance management. It allows users to manage devices, schedule maintenance, and view reports.

## Architecture

- **Framework:** Flutter
- **Language:** Dart
- **Navigation:** The app uses named routes for navigation. All routes are defined in `lib/main.dart`. When adding a new screen, add the route to the `routes` map in `MaterialApp`.
  ```dart
  // lib/main.dart
  routes: {
    '/': (context) => const SplashScreen(),
    '/login': (context) => const LoginScreen(),
    '/dashboard': (context) => const DashboardScreen(),
    // ... other routes
  },
  ```
- **State Management:** The project currently uses `StatefulWidget` for local, screen-level state management. For more complex state, a formal state management library might be needed.
- **Project Structure:**
  - `lib/main.dart`: App entry point, theme definition, and route configuration.
  - `lib/models/`: Contains data models (e.g., `lib/models/device.dart`).
  - `lib/screens/`: UI for each screen.
  - `lib/widgets/`: Reusable UI components (e.g., `lib/widgets/bottom_nav.dart`).
  - `lib/utils/`: Utility files, like the color palette in `lib/utils/colors.dart`.

## Developer Workflow

### Getting Dependencies

Run `flutter pub get` to install dependencies.

**NOTE:** The codebase currently has inconsistencies with its dependencies. For example, `lib/screens/login_screen.dart` imports `package:cached_network_image/cached_network_image.dart`, but it is not listed as a dependency in `pubspec.yaml`. You may need to add missing dependencies to `pubspec.yaml`.

```yaml
# pubspec.yaml
dependencies:
  flutter:
    sdk: flutter
  # Add missing dependencies here
  # cached_network_image: ^3.3.1
```

### Running the App

You can run the app using the standard `flutter run` command.

### Testing

The project is set up for widget tests. See `test/widget_test.dart`. Run tests using `flutter test`.

## Conventions

- **Styling:** Colors are centralized in `lib/utils/colors.dart`. The main app theme is defined in `lib/main.dart`.
- **File Naming:** Screen files are named with a `_screen.dart` suffix (e.g., `login_screen.dart`).
- **Widgets:** Reusable widgets are placed in the `lib/widgets/` directory.
