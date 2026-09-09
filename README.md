# MSAI Chat

A complete, production-ready WhatsApp-style mobile messaging application built with Flutter, Dart, Material 3, and an Android-first scalable architecture.

## 1. Project Overview

**MSAI Chat** delivers a modern, full-featured messaging experience inspired by top messaging tools while maintaining complete brand uniqueness.

### Features
* **Authentication**: Email/Password, Phone OTP Architecture, Password Reset, Session Persistence, Profile Creation.
* **Chats**: One-to-one messaging, Group chats, Text messages, Image/Video preview, Voice recording (Hold-to-record UI with timer/progress), Documents, Message timestamps, Sent/Delivered/Read ticks, Reply, Forward, Star/Save, Delete, Copy, Search, Pin, Mute, Archive, Block & Report user.
* **Groups**: Create group, Subject & Description, Avatar, Member management, Admin roles & permissions, Leave/Exit group.
* **Updates / Status**: Text and media status updates, Status expiration (24h architecture), Status viewer, Viewed/Unviewed status indicators, Privacy settings.
* **Communities**: Create & manage communities, Announcement channels, Group linking.
* **Calls**: Voice & Video call interfaces, Incoming/Outgoing call views, Call duration, Call history with missed call indicators, WebRTC-compatible signaling abstraction.
* **Profile & Settings**: Avatar customization, Name & About editor, Privacy settings, Theme switcher (Dark mode default, Light mode, System theme), Notifications, Storage & Data usage, Language, Logout.

---

## 2. Requirements

* **Flutter SDK**: `>=3.11.0` (Dart SDK `>=3.11.0 <4.0.0`)
* **Android Studio**: Android SDK Build-Tools 33.0.0 or higher
* **Java Development Kit**: OpenJDK 17 or higher
* **Git**: Installed for version control

---

## 3. Flutter Installation

1. Download the Flutter SDK from [flutter.dev](https://flutter.dev/docs/get-started/install).
2. Extract the archive to a directory (e.g., `~/flutter` or `C:\src\flutter`).
3. Add Flutter to your system `PATH`:
   ```bash
   export PATH="$PATH:`pwd`/flutter/bin"
   ```
4. Verify installation:
   ```bash
   flutter doctor
   ```

---

## 4. Dart Setup

The Dart SDK is bundled with Flutter. Verify Dart version:
```bash
dart --version
```

---

## 5. Package Installation

To install all project dependencies listed in `pubspec.yaml`:

```bash
flutter pub get
```

### Key Packages Used
* `provider`: State management & dependency injection.
* `shared_preferences`: Local storage and persistent session caching.
* `permission_handler`: Android runtime permissions management.
* `path_provider`: Device storage path resolution.
* `image_picker`: Camera and gallery media capture.
* `file_picker`: Document and file sharing selector.
* `intl`: Date, time, and timestamp formatting.
* `uuid`: Cryptographically secure unique identifier generation.

---

## 6. Backend Setup

The application employs a Repository/Service pattern (`lib/services/` & `lib/repositories/`) to isolate networking and database logic from UI components.

To connect MSAI Chat to your custom production backend REST/GraphQL/WebSocket API:
1. Implement `AuthService`, `ChatService`, `MessageService`, `CallService` interfaces in `lib/services/`.
2. Update `config/app_config.dart` with your production API endpoints.

---

## 7. Firebase Setup (Optional Backend Integration)

If using Firebase (Firebase Auth, Cloud Firestore, Firebase Storage, FCM):

1. Create a project in [Firebase Console](https://console.firebase.google.com/).
2. Register your Android app package (`com.msai.chat`).
3. Download `google-services.json` and place it in `android/app/`.
4. Enable Firebase Authentication (Email/Password & Phone number providers).
5. Deploy Firestore Security Rules:
   ```
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth != null && request.auth.uid == userId;
       }
       match /chats/{chatId} {
         allow read, write: if request.auth != null;
       }
     }
   }
   ```

---

## 8. Android Configuration

Android permissions are declared in `android/app/src/main/AndroidManifest.xml`:
* `INTERNET`: Network requests & WebRTC signaling.
* `CAMERA`: Taking profile photos, status media, and video calls.
* `RECORD_AUDIO` & `MODIFY_AUDIO_SETTINGS`: Voice messaging and voice/video calling.
* `READ_MEDIA_IMAGES`, `READ_MEDIA_VIDEO`, `READ_MEDIA_AUDIO`: Gallery media picker on Android 13+.
* `POST_NOTIFICATIONS`: Push notifications for messages and incoming calls.

### Permission Checks
Runtime permissions are dynamically requested using `permission_handler` in `lib/services/media_service.dart`.

---

## 9. Environment Variables / Configuration

Configuration defaults are stored in `config/app_config.dart`. Pass runtime environment variables during build using `--dart-define`:

```bash
flutter run --dart-define=API_BASE_URL=https://api.msaichat.com/v1 --dart-define=WEBRTC_SIGNALING_URL=wss://signaling.msaichat.com
```

> **SECURITY NOTE**: NEVER hardcode API keys or production secrets directly in Dart source files. Store private keys in secure environment variables or secret vaults.

---

## 10. Running the App

Start the application on an attached Android emulator or real device:

```bash
flutter run
```

To run in release mode:
```bash
flutter run --release
```

---

## 11. Debugging

* Run analyzer checks:
  ```bash
  dart analyze
  ```
* Run unit and integration tests:
  ```bash
  flutter test
  ```
* Open Flutter DevTools for performance profiling and memory inspection:
  ```bash
  flutter pub global run devtools
  ```

---

## 12. Building APK

Generate a debug Android APK:

```bash
flutter build apk --debug
```

---

## 13. Building Release APK

To create an optimized, production release APK for Android deployment:

```bash
flutter build apk --release
```

The compiled APK file will be created at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 14. Production Deployment Notes

Before deploying to the Google Play Store or production servers:
1. Configure Android App Signing keys in `android/key.properties` and update `android/app/build.gradle`.
2. Ensure production backend credentials and HTTPS/WSS endpoints are configured via `--dart-define`.
3. Set up WebRTC STUN/TURN server credentials for reliable cross-network voice and video call connectivity.
4. Verify ProGuard / R8 code shrinking rules in `android/app/proguard-rules.pro`.
