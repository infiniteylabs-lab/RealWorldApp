# Session Notes

## App Work

- Replaced the Alerts placeholder with an interactive alert center. New authored posts generate alerts through the in-memory `PostStore`.
- Added the functional profile and connected post creation, saved posts, and detail-page bookmarks.
- Flutter widget tests passed (4 tests); Flutter analysis reported no issues.
- The app launched in Chrome. Windows desktop launch was blocked because the Visual Studio C++ toolchain is unavailable.

## Firebase Status

- Android Firebase project: `realworld-ke-2026`.
- `android/app/google-services.json` matches package `com.example.realworld_app`.
- Cloud Firestore and Cloud Storage were not wired at the time these notes were written. `flutter pub add` could not resolve packages because access to `pub.dev` failed with a socket error.
- Firebase CLI and FlutterFire CLI were not available. iOS and Web Firebase configuration files/options are missing.
- App demo data currently remains in memory and resets when the app restarts.

## Launcher Icon Status

- `pubspec.yaml` includes `flutter_launcher_icons: ^0.14.3`, the Android/iOS generator configuration, and the `assets/icon.png` asset entry.
- `assets/icon.png` now uses the existing 512px Flutter icon from `web/icons/Icon-512.png`.
- Package resolution and launcher generation remain pending because access to `pub.dev` failed.
