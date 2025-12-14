# WARP.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Repo type
Flutter app (Dart SDK constraint in `pubspec.yaml` is `^3.10.3`) using:
- Riverpod (with `riverpod_annotation` + code generation)
- GoRouter for navigation
- Dio + CookieJar for API/networking
- Freezed + json_serializable for models

## Common commands
All commands assume you are at the repo root.

### Install dependencies
- `flutter pub get`

### Run the app
- `flutter run`

### Lint / static analysis
- `flutter analyze`

Optional (custom lint rules via `custom_lint` + `riverpod_lint`):
- `dart run custom_lint`

### Format
- `dart format .`

### Tests
- Run all tests:
  - `flutter test`
- Run a single test file:
  - `flutter test test/widget_test.dart`
- Run a single test by name (string/regex match):
  - `flutter test test/widget_test.dart --plain-name "App smoke test"`

### Code generation (Freezed / Riverpod / JSON)
This repo commits generated files like `*.g.dart` and `*.freezed.dart`. When editing annotated files (e.g. `@freezed`, `@riverpod`), regenerate with:
- One-shot build:
  - `dart run build_runner build --delete-conflicting-outputs`
- Watch mode:
  - `dart run build_runner watch --delete-conflicting-outputs`

## High-level architecture

### Entry point + dependency injection
- `lib/main.dart`
  - `main()` initializes `SharedPreferences` and injects it by overriding `storageServiceProvider` inside `ProviderScope`.
  - `routerProvider` builds the app’s `GoRouter`.
  - `LoopsApp` uses `MaterialApp.router` and themes from `core/theme/app_theme.dart`.

### Routing
- `lib/main.dart:routerProvider`
  - Uses `ShellRoute` to provide a shared `Scaffold` (`MainScreen`) with bottom navigation.
  - Main routes:
    - `/` → feed (`FeedScreen`)
    - `/profile` → profile (`ProfileScreen`)
    - `/login` → login (`LoginScreen`)

### State management (Riverpod)
Patterns used in this repo:
- Feature controllers are `@riverpod` classes that extend generated `_$...` base types and usually return `AsyncValue<T>`.
  - Example: `features/feed/presentation/controllers/feed_controller.dart`
  - Generated providers live in `*.g.dart` next to the source (`part '...g.dart'`).
- Repositories are typically provided via plain `Provider<T>` in the data layer.
  - Examples: `authRepositoryProvider`, `feedRepositoryProvider`

### “Clean-ish” feature structure
Most code under `lib/features/<feature>` follows:
- `domain/`
  - Interfaces (repositories) + pure models
- `data/`
  - Concrete implementations (API-backed repositories)
- `presentation/`
  - Screens/widgets and Riverpod controllers

### Core services
- `lib/core/storage/storage_service.dart`
  - Thin wrapper around `SharedPreferences` (keys: instance, logged_in, token).
- `lib/core/network/api_client.dart`
  - Wraps Dio.
  - Maintains an in-memory `CookieJar` and attaches the `X-XSRF-TOKEN` header when present.
  - Uses Laravel Sanctum-style CSRF bootstrapping via `ensureCsrfCookie()` (`/sanctum/csrf-cookie`).
  - Base URL comes from `StorageService.getInstance()` (defaults to `https://loops.video`).

### Auth flow (server session + CSRF)
- `features/auth/presentation/screens/login_screen.dart`
  - Requires a captcha token (Cloudflare Turnstile) before login.
  - Captcha is implemented with an in-app WebView in `CaptchaScreen`.
- `features/auth/data/repositories/auth_repository_impl.dart`
  - Logs in via POST `login` after `ensureCsrfCookie()`.
  - Handles 2FA verification via `api/v1/auth/2fa/verify`.
  - Authentication state is tracked via `StorageService.keyLoggedIn` (cookies are in-memory).

### Feed flow
- `features/feed/data/repositories/feed_repository_impl.dart`
  - Fetches feeds from `api/v1/feed/for-you` and `api/v1/feed/following`.
- `features/feed/presentation/screens/feed_screen.dart`
  - Vertical `PageView` with `VideoPlayerWidget` per item.

### Profile flow
- `features/profile/presentation/controllers/profile_controller.dart`
  - Uses `AuthRepository.getCurrentUser()`.
- `features/profile/presentation/screens/profile_screen.dart`
  - If user is null, shows a login button that navigates to `/login`.
