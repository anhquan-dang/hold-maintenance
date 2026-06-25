# Hold Maintenance - Flutter App Setup Guide

## 🚀 Quick Start

### Prerequisites

- Flutter SDK 3.9.2+
- Dart SDK 3.9.2+
- An Android/iOS emulator or physical device

### Installation Steps

1. **Clone and navigate to project:**

```bash
cd "c:\Users\Windows 11\Documents\New folder\hold_maintenance"
```

2. **Get dependencies:**

```bash
flutter pub get
```

3. **Run the app:**

```bash
flutter run
```

Or for specific device:

```bash
flutter run -d chrome          # Web
flutter run -d emulator-5554   # Android
```

### Available Test Accounts

The app uses mock data with these sample accounts:

| Email             | Password    | Role              | Department       |
| ----------------- | ----------- | ----------------- | ---------------- |
| van.a@example.com | password123 | Device Manager    | Phòng kinh doanh |
| thi.b@example.com | password123 | Device Manager    | Phòng sản xuất   |
| van.c@example.com | password123 | Device Manager    | Phòng kỹ thuật   |
| van.d@example.com | password123 | Maintenance Staff | Bộ phận bảo trì  |
| thi.e@example.com | password123 | Maintenance Staff | Bộ phận bảo trì  |
| van.f@example.com | password123 | Director          | Ban lãnh đạo     |

**Note:** Currently, any email with password "password123" will log in successfully (mock auth).

## 📁 Project Structure

```
lib/
├── main.dart                     # App entry point with routes
├── domain/                       # Business logic layer
│   ├── models/                   # Data models
│   │   ├── device.dart
│   │   ├── maintenance_request.dart
│   │   ├── notification.dart
│   │   └── user.dart
│   └── repositories/             # Abstract repository interfaces
│       ├── device_repository.dart
│       ├── maintenance_repository.dart
│       ├── notification_repository.dart
│       └── user_repository.dart
├── data/                         # Data layer (repositories + data sources)
│   └── repositories/             # Fake implementations
│       ├── fake_device_repository.dart
│       ├── fake_maintenance_repository.dart
│       ├── fake_notification_repository.dart
│       └── fake_user_repository.dart
├── presentation/                 # UI layer
│   ├── providers/                # Riverpod state management
│   │   ├── device_provider.dart
│   │   ├── maintenance_provider.dart
│   │   ├── notification_provider.dart
│   │   └── user_provider.dart
│   └── widgets/                  # Reusable UI components
│       ├── device_card.dart
│       ├── empty_state.dart
│       ├── error_state.dart
│       ├── loading_state.dart
│       ├── maintenance_card.dart
│       ├── notification_item.dart
│       ├── statistic_card.dart
│       └── status_badge.dart
├── screens/                      # Full page screens
│   ├── add_device_screen.dart
│   ├── dashboard_screen.dart
│   ├── device_detail_screen.dart
│   ├── device_list_screen.dart
│   ├── login_screen.dart
│   ├── maintenance_report_screen.dart
│   ├── maintenance_schedule_screen.dart
│   ├── notifications_screen.dart
│   ├── profile_screen.dart
│   └── splash_screen.dart
├── utils/
│   └── colors.dart               # Color palette & theme
├── models/                       # (Legacy - kept for reference)
├── widgets/                      # (Legacy - BottomNav)
└── pubspec.yaml                  # Dependencies

test/
└── widget_test.dart
```

## 🎯 App Features

### Screens & Navigation

1. **Splash Screen** - App initialization (2.5s delay)
2. **Login Screen** - Email/password authentication
3. **Dashboard** - Statistics overview with charts
4. **Device List** - Browse all devices with search & filter
5. **Add Device** - Create new device with form validation
6. **Device Detail** - View device info & maintenance history
7. **Maintenance Schedule** - Track maintenance requests by status
8. **Maintenance Report** - Create new maintenance report with images
9. **Notifications** - View app notifications with read status
10. **Profile** - User info & account settings

### State Management (Riverpod)

- **FutureProvider**: For async data (devices, users, requests)
- **StateNotifierProvider**: For mutable state (adding/updating items)
- **Provider**: For simple state & dependencies

Example provider usage:

```dart
// Watch provider value in widget
final devices = ref.watch(devicesProvider);

// Mutate state
ref.read(addDeviceProvider.notifier).addDevice(newDevice);

// Refresh provider
ref.refresh(devicesProvider);
```

## 🛠️ Development Workflow

### Add a New Feature

1. **Define model** → `lib/domain/models/my_model.dart`
2. **Create abstract repository** → `lib/domain/repositories/my_repository.dart`
3. **Implement fake repository** → `lib/data/repositories/fake_my_repository.dart`
4. **Create providers** → `lib/presentation/providers/my_provider.dart`
5. **Build UI** → `lib/screens/my_screen.dart`
6. **Add to routes** → Update `main.dart`

### Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

### Analyze Code

```bash
# Static analysis
flutter analyze

# Format code
dart format lib/

# Fix issues
dart fix --apply
```

## 🔄 Converting to Real Backend

1. **Replace FakeUserRepository:**

   ```dart
   // lib/data/repositories/user_repository_impl.dart
   class UserRepositoryImpl implements UserRepository {
     final http.Client _httpClient;

     Future<User?> getCurrentUser() async {
       final response = await _httpClient.get(
         Uri.parse('https://api.example.com/users/me')
       );
       // Parse JSON and return User
     }
   }
   ```

2. **Update providers:**

   ```dart
   final userRepositoryProvider = Provider<UserRepository>((ref) {
     return UserRepositoryImpl(http.Client());
   });
   ```

3. **Add authentication token management**
4. **Implement error handling for network calls**
5. **Add retry logic & offline support**

## 📊 Architecture Decisions

### Why Clean Architecture?

- **Testability**: Easy to test business logic independently
- **Maintainability**: Clear separation of concerns
- **Scalability**: Easy to add new features without breaking existing code
- **Flexibility**: Easy to swap implementations (fake → real, REST → GraphQL)

### Why Riverpod?

- **Type-safe**: Compiler catches errors
- **Testable**: Providers can be overridden in tests
- **Efficient**: Only rebuilds affected widgets
- **Intuitive**: Declarative reactive programming

## 🚨 Known Limitations

1. **No persistent storage** - Uses in-memory storage, cleared on app restart
2. **Mock authentication** - Any email works with "password123"
3. **Simulated delays** - 300-500ms delays on all repository calls
4. **No real images** - Uses placeholder images from unsplash.com
5. **No notifications** - Notification system is mock data

## 🔄 Common Tasks

### Add a new screen

1. Create file: `lib/screens/my_screen.dart`
2. Import required packages:
   ```dart
   import 'package:flutter/material.dart';
   import 'package:flutter_riverpod/flutter_riverpod.dart';
   ```
3. Add to routes in `main.dart`:
   ```dart
   '/my-route': (context) => const MyScreen(),
   ```

### Modify a model

- Edit file in `lib/domain/models/`
- Update `copyWith()` method
- Update mock data in corresponding fake repository

### Change a color

- Edit `lib/utils/colors.dart`
- Colors are referenced globally as `AppColors.primary`, etc.

### Add form validation

- Use `TextFormField` instead of `TextField`
- Provide `validator` callback:
  ```dart
  TextFormField(
    validator: (value) {
      if (value?.isEmpty ?? true) return 'Required';
      return null;
    },
  )
  ```

## 📱 Building for Release

### Android

```bash
flutter build apk --release
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🐛 Troubleshooting

**Issue**: App won't run

```bash
# Clean build
flutter clean
flutter pub get
flutter run
```

**Issue**: Dependency errors

```bash
# Update to compatible versions
flutter pub upgrade
```

**Issue**: Hot reload not working

```bash
# Restart daemon
flutter run --verbose
```

## 📞 Support

For questions or issues:

1. Check the `IMPLEMENTATION_SUMMARY.md` for architecture details
2. Review comments in source code
3. Check Flutter documentation: https://flutter.dev/docs

---

**Last Updated**: 2024
**Flutter Version**: 3.9.2+
**Dart Version**: 3.9.2+
**Status**: Production-ready MVP
