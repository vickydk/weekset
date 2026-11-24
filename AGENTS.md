# Agent instructions

This is **Weekset**: a Flutter/Dart app that ships **Android and iOS from one codebase**.

Assistants must follow this file. Do not invent a second stack (React Native, native-only, web, desktop) unless the user explicitly asks. Prefer small, reviewable changes. Match existing code once the Flutter project exists.

Canonical product context: [Weekset on Notion](https://app.notion.com/p/c9f885f46cd582c0ae6f811d74793e03). One fitness center, many trainers, many clients. A client has one trainer. Phase 1 is access, the shared week, the session log, and the solo day. The center grants roles. Workout notes stay between the client and their trainer.

These working rules come from STRAOUR. The product does not. Do not copy STRAOUR features (rides, maps, garage, Firebase Auth) into this repo.

# Quick orientation

| Item | Detail |
| --- | --- |
| Product | Weekset — the shared week between a trainer and a client |
| Repo | Flutter mobile app (this repository) |
| Platforms | Android and iOS only |
| Language | Dart (null-safe) |
| UI | Flutter widgets; catalogue new UI in Widgetbook |
| Auth | Email and password. Access token plus rotating refresh token, in secure storage |
| Backend | Weekset API (`API_BASE_URL`); JSON over HTTPS |
| Docs | `README.md` (product, when present), this file (how to work), `CLAUDE.md` (pointer here), the Notion page (scope) |

Intended layout after `flutter create` (adjust names only if the repo already differs):

```text
lib/
  main.dart                 # app entry
  widgetbook.dart           # Widgetbook entry
  app.dart
  core/                     # theme, routing, network, secure storage
  features/
    auth/
    schedule/               # availability, requests, fixed week
    session_log/
    solo_plan/
    client/                 # client shell
    trainer/                # trainer shell
    center/                 # center shell
test/                       # *_test.dart next to the behavior they cover
android/
ios/
```

Keep feature code together (`features/<name>/data`, `domain`, and `presentation`). Shared widgets live under `lib/core/` or `lib/features/shared/`, not as one-off copies. One theme, three navigation shells.

# Before changing code

1. Read this file and the relevant feature folder. If `pubspec.yaml` is missing, scaffold Flutter first — do not dump Dart into the repo root.
2. Confirm the change is for **both** Android and iOS. Platform channels or `dart:io` branches are allowed only when the platform requires it.
3. Do not add web, macOS, Windows, or Linux targets.
4. Do not expand scope past the current ticket. Payments, chat, body metrics, wearables, and a second center are later phases.
5. Do not commit secrets (`.env` with production URLs, keystores, tokens). Use Flutter flavors / dart-define / gitignored config.
6. Reuse existing widgets, theme, and session helpers. Do not create a parallel design system. Visual tokens are charcoal `#121417`, paper `#F4F1EA`, lime `#C6F135`.
7. New user-visible screens and reusable widgets need Widgetbook use cases in the same change (see **Widgetbook catalogue**).

# Tooling

Use the Flutter SDK on PATH (or FVM if this repo later adds `.fvmrc`).

```bash
flutter pub get
dart format .
flutter analyze
flutter test
flutter run                      # device/simulator
flutter run -t lib/widgetbook.dart
```

- Format Dart with `dart format` (trailing commas, 80-column default unless `analysis_options.yaml` says otherwise).
- Treat `flutter analyze` issues as blockers, not noise. Do not ignore lints to land a change.
- Codegen (`build_runner`, Widgetbook generator, json_serializable, etc.) belongs in the same PR as the annotations that require it. Commit generated files the project already commits; do not fight that convention.
- Android and iOS must both build. Do not land a Dart-only change that breaks Gradle or Xcode without checking.

# Tests

- Put tests under `test/` as `*_test.dart`. Name them after the unit or widget under test (`login_view_test.dart`, `auth_repository_test.dart`).
- Prefer **unit tests** for parsing, mapping, validators, and session logic. Prefer **widget tests** for UI states (loading, error, empty, signed-in routing).
- Use `flutter_test`. Mock HTTP with `mocktail` (or the library already in `pubspec.yaml`). No real network and no real device accounts in unit/widget tests.
- Cover auth routing: signed-out → welcome or log in; signed-in → the shell for that role; session restore in progress → the app does not flash the wrong shell.
- Cover login and reset password: success, failure, and validation errors.
- Do not add `integration_test` unless the task is an end-to-end flow and a device/emulator is in scope.
- A change is not done if tests for the new behavior are missing. Run `flutter test` before you stop.

# Before opening a PR

- [ ] `dart format .` is clean
- [ ] `flutter analyze` is clean
- [ ] `flutter test` passes
- [ ] New/changed widgets have Widgetbook use cases
- [ ] Android and iOS implications considered (permissions, secure storage, Gradle/Podfile)
- [ ] No secrets, no unrelated refactors, no extra platforms
- [ ] README / config samples updated only when env or setup actually changed

# Opening the PR

Use a short title that says **why**, not a file list. Example: `Add email login and the three role shells`.

Body:

```markdown
## Summary
- …

## Test plan
- [ ] …
```

Include what you ran (`flutter analyze`, `flutter test`, Widgetbook target, iOS simulator and/or Android emulator). Do not force-push `main`. Do not skip hooks.

# Widgetbook catalogue

Weekset uses [Widgetbook](https://docs.widgetbook.io) as the visual catalogue for reusable widgets and screens. The catalogue is part of the product, not an optional demo.

**Entry:** `lib/widgetbook.dart` (run with `flutter run -t lib/widgetbook.dart`). Use `@App()` + `widgetbook_generator` / `build_runner` unless the repo already uses a manual `directories` tree — then match that.

**Use cases:** colocate as `*.widgetbook.dart` next to the widget (or under `lib/**/widgetbook/` if that pattern is already present). Each use case is:

```dart
@UseCase(name: 'default', type: LoginScreen)
Widget buildLoginScreenUseCase(BuildContext context) { /* … */ }
```

Rules:

- Every new reusable widget or screen gets at least a `default` use case. Add named variants for **loading**, **error**, **empty**, **disabled**, and auth or schedule states the screen can show.
- `name` values are unique per `type`. Prefer `default`, `loading`, `error`, `disabled`, `with_long_text`.
- Catalogue **presentational** UI. Mock repositories and navigation. Widgetbook must not call production APIs or store real tokens.
- Wrap use cases with the same `Theme`, localization, and (if needed) device-frame addons as the app. Support the dark gym theme the app ships.
- Screens that are not pure (welcome, login, today) still belong in Widgetbook with faked session state so reviewers can see them without a full app boot.
- If you change a widget’s public look or states, update or add use cases in the same PR. Do not leave the catalogue stale.
