# realworld_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Firebase

Android is configured for the `realworld-ke-2026` Firebase project through
`android/app/google-services.json` and the Google Services Gradle plugin.
Application startup initializes Firebase before showing the app. Email/password
sign-up, login, password reset, and logout use Firebase Authentication. The
Hustle screen reads `hustles` documents from Cloud Firestore and sums each
document's numeric `price` field.
The app currently has no Firebase Authentication integration.

The Home screen's **Test Firestore** button opens a live `test` collection
viewer. **Write timestamp** adds a document with a server-generated `timestamp`;
the `StreamBuilder` list updates as documents arrive.

Configure Firestore security rules for the access model you intend to use.
Firebase configuration for web, iOS, macOS, and Windows is not present in this
project; register those platform apps and generate FlutterFire options before
running Firebase features on those platforms.

Run `flutter test` for the automated widget tests.
