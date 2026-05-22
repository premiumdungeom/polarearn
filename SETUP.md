# PolarEarn Flutter App — Setup Guide

## What's included

```
polarearn/
├── lib/
│   ├── main.dart                  # App entry, routing, splash
│   ├── services/
│   │   ├── api_service.dart       # All HTTP calls to your PHP backend
│   │   └── theme.dart             # Colors, fonts, ThemeData
│   └── screens/
│       ├── login_screen.dart      # Login page
│       ├── register_screen.dart   # Registration page
│       ├── home_screen.dart       # Dashboard (balance, chart, quick actions)
│       ├── accounts_screen.dart   # Bank accounts management
│       └── withdraw_screen.dart   # Withdrawal request & status
├── pubspec.yaml                   # Dependencies
├── ajax_dashboard.php             # NEW — upload to your server
├── ajax_get_accounts.php          # NEW — upload to your server
└── ajax_csrf.php                  # NEW — upload to your server
```

---

## Step 1 — Upload the new PHP files

Upload these 3 files to your web server (same folder as your other PHP files):
- `ajax_dashboard.php`
- `ajax_get_accounts.php`
- `ajax_csrf.php`

---

## Step 2 — Set your domain in the Flutter app

Open `lib/services/api_service.dart` and change line 6:

```dart
static const String baseUrl = 'https://YOUR_DOMAIN.com';
```

Replace `YOUR_DOMAIN.com` with your actual domain, e.g.:
```dart
static const String baseUrl = 'https://polarearn.com';
```

Also update the referral share link in `home_screen.dart` (line ~205):
```dart
'https://YOUR_DOMAIN.com/register?ref=$code'
```

---

## Step 3 — Install Flutter

If you don't have Flutter installed:

1. Download Flutter SDK: https://flutter.dev/docs/get-started/install/windows
2. Add Flutter to your PATH
3. Run `flutter doctor` to check everything is set up
4. Install Android Studio: https://developer.android.com/studio
5. Accept Android licenses: `flutter doctor --android-licenses`

---

## Step 4 — Install dependencies

In the `polarearn/` folder, run:

```bash
flutter pub get
```

---

## Step 5 — Run on Android

Connect your Android phone via USB (enable Developer Mode + USB Debugging), then:

```bash
flutter run
```

Or build a release APK to share/install:

```bash
flutter build apk --release
```

The APK will be at:
```
build/app/outputs/flutter-apk/app-release.apk
```

---

## Step 6 — Android permissions

In `android/app/src/main/AndroidManifest.xml`, make sure you have:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

(Flutter usually adds this automatically.)

---

## Session handling notes

The Flutter app stores your PHP session cookie securely using `flutter_secure_storage`.
This means once a user logs in, they stay logged in — just like the web app.

If your server uses HTTPS (which it should), sessions will work seamlessly.
If your server uses HTTP only, you may need to configure the cookie storage differently.

---

## Screens to add next

These screens are referenced in the bottom nav / quick actions but not yet built.
You can build them the same way as the existing screens:

- `tasks_screen.dart` — Daily tasks list
- `referrals_screen.dart` — Referral code + list of referrals
- `profile_screen.dart` — User profile, settings, logout
- `upgrade_screen.dart` — Plan activation / upgrade
- `checkin_screen.dart` — Daily check-in

---

## Dependencies used

| Package | Purpose |
|---|---|
| `http` | HTTP requests to your PHP backend |
| `flutter_secure_storage` | Secure session cookie storage |
| `fl_chart` | Earnings line chart |
| `google_fonts` | DM Sans font (matches your web app) |
| `share_plus` | Referral link sharing |
| `shimmer` | Loading skeleton animations (optional) |
