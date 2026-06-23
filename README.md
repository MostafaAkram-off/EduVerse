<div align="center">

# EduVerse

**A full-featured e-learning mobile platform built with Flutter**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white)](https://dart.dev)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS-lightgrey?logo=android)](https://flutter.dev)
[![Architecture](https://img.shields.io/badge/Architecture-Clean%20Architecture-blueviolet)](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)

</div>

---

## About

EduVerse is a cross-platform mobile application that connects students with instructors in an online learning environment. Students can browse and enroll in courses, watch video lessons, track attendance, submit assignments, earn certificates, and pay securely via PayMob. Instructors can create and manage courses, upload content, and monitor their students.

---

## Features

### Student
- Browse course catalog with AI-powered recommendations
- Enroll in courses with PayMob payment integration (Card, Bank Transfer, Installments)
- Stream video lessons with an in-app media player
- Track attendance via QR code scanning
- Submit and view assignments
- Download payment receipts as PDF
- View and download earned certificates
- Manage profile and account settings

### Instructor
- Create and publish courses with cover images
- Upload course materials and video content
- Monitor enrolled students
- Manage course sessions

### General
- JWT-based authentication with OTP email verification
- Forgot password / reset password flow
- Dark & light theme support
- Localization-ready (flutter_localizations)
- Secure token storage

---

## Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter 3 / Dart 3 |
| State Management | flutter_bloc (Cubit) |
| Dependency Injection | get_it + injectable |
| Navigation | go_router |
| Networking | Dio |
| Local Storage | shared_preferences + flutter_secure_storage |
| Media Player | media_kit + media_kit_video |
| Image Loading | cached_network_image |
| PDF Generation | pdf + printing |
| QR Scanner | mobile_scanner |
| Payment | PayMob (Unified Checkout) |
| Backend | ASP.NET Core REST API |
| Cloud Storage | Azure Blob Storage |

---

## Architecture

The project follows **Clean Architecture** with a feature-first folder structure:

```
lib/
├── core/                   # Shared utilities, theme, navigation, constants
├── config/                 # DI setup, Dio interceptors, base state/response
├── features/
│   ├── auth/               # Login, Register (OTP), Forgot Password
│   │   ├── data/           # DataSources, Repositories, Models
│   │   ├── domain/         # Repository interfaces, Use Cases
│   │   └── ui/             # Cubits, Screens
│   ├── instructor/         # Instructor dashboard & course management
│   └── onboarding/         # App intro screens
└── student/
    └── features/
        ├── home/           # Recommended courses feed
        ├── courses/        # Course catalog & detail
        ├── enrollment/     # Enrollment flow & PayMob checkout
        ├── learning/       # Video player & lesson content
        ├── assignments/    # Assignment submission
        ├── attendance/     # QR-based attendance
        ├── certificates/   # Certificate viewer & download
        ├── notifications/  # Push notifications
        └── profile/        # User profile management
```

---

## Getting Started

### Prerequisites

- Flutter SDK `^3.8.1`
- Dart SDK `^3.0`
- Android Studio / VS Code
- A connected Android/iOS device or emulator

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/MostafaAkram-off/EduVerse.git
cd EduVerse

# 2. Install dependencies
flutter pub get

# 3. Run the app
flutter run
```

### Build Release APK

```bash
flutter build apk --release
```

---

## Backend

The app connects to a live ASP.NET Core REST API:

```
https://eduverseapi.azurewebsites.net
```

Authentication uses JWT tokens stored securely on-device. All API communication goes through a Dio client with an auth interceptor that automatically attaches and refreshes tokens.

---

## Payment

Payments are handled via **PayMob Unified Checkout**. When a student enrolls in a paid course, the app calls the backend to create a PayMob order and receives a checkout URL. The URL is opened in the device's browser where the student completes payment, then returns to the app.

Supported payment methods (configured on PayMob dashboard):
- Credit / Debit Card
- Bank Transfer (Instapay, Fawry, Aman)
- Installments

---

## License

This project is for educational and portfolio purposes.
