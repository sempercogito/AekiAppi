# AGENT.md — Coding-Agent Instructions

This document describes everything a coding agent (or new contributor) needs to
know to work effectively on **AekiAppi**.

---

## Repository at a glance

| Item | Value |
|---|---|
| Language | Dart / Flutter (≥ 3.0) |
| Target platforms | Android (API 21+), iOS 12+ |
| State management | `provider` + `ChangeNotifier` |
| BLE library | `flutter_blue_plus` |
| Hashing | `crypto` (SHA-1 for BLE auth) |

---

## Development environment

### Recommended: VS Code Dev Container

Open the repository in VS Code and choose **"Reopen in Container"**.  The
container is defined in `.devcontainer/` and pre-installs Flutter, Dart, the
Android SDK and all recommended VS Code extensions.

### Manual setup

1. Install the Flutter SDK (≥ 3.0): https://docs.flutter.dev/get-started/install
2. Verify: `flutter doctor`
3. Install dependencies: `flutter pub get`

---

## Key commands

| Task | Command |
|---|---|
| Install dependencies | `flutter pub get` |
| Run tests | `flutter test` |
| Static analysis (lint) | `flutter analyze` |
| Format code | `dart format lib/ test/` |
| Build Android APK (debug) | `flutter build apk --debug` |
| Build Android APK (release) | `flutter build apk --release` |
| Build iOS (release) | `flutter build ios --release --no-codesign` |
| Run on device / emulator | `flutter run` |

Run **`flutter analyze` and `flutter test` before every commit.**

---

## Project structure

```
lib/
├── main.dart                  # App entry point, theme, Provider root
├── models/
│   └── scooter_state.dart     # Immutable value object for scooter state
├── screens/
│   ├── scan_screen.dart       # BLE device-discovery UI
│   └── home_screen.dart       # Scooter control panel
└── services/
    └── scooter_service.dart   # BLE logic: scan · auth · commands · notifications

test/
└── scooter_service_test.dart  # Pure-Dart unit tests (no device required)
```

---

## BLE protocol summary

### UUIDs

| Role | UUID |
|---|---|
| Challenge (read) | `00002556-1212-efde-1523-785feabcd123` |
| Auth response (write) | `00002557-1212-efde-1523-785feabcd123` |
| Command (write) | `0000155f-1212-efde-1523-785feabcd123` |
| Notification (notify) | `0000155e-1212-efde-1523-785feabcd123` |
| Read trigger (write) | `00001564-1212-efde-1523-785feabcd123` |

### Authentication flow

1. Connect to the scooter (advertisement names: `AIKE`, `AIKE_T`, `AIKE_11`).
2. Read 20-byte challenge from `00002556…`.
3. Compute `SHA-1(challenge ‖ key)` where `key = bytes([0xFF] * 20)`.
4. Write 20-byte digest to `00002557…`.
5. Send commands to `0000155f…`.

### 10-byte command packet layout

```
Offset  Description
0       Header (always 0x00)
1       Registry (0xD4 for normal commands, 0xD2 for transport mode)
2       Reserved (0x00)
3       Command ID
4-6     Reserved (0x00)
7       Parameter value
8-9     Reserved (0x00)
```

### Implemented commands

| Command | ID | Parameter |
|---|---|---|
| Unlock | 0x01 | 0x00 |
| Lock | 0x02 | 0x00 |
| Eco Mode | 0x03 | 0x01 = on, 0x00 = off |
| Open Battery Tray | 0x04 | 0x00 |
| Auto-lock Timer | 0x06 | minutes (0 = disabled) |
| Auto-brake | 0x07 | 0x01 = on, 0x00 = off |
| Transport Mode | — | uses registry 0xD2, see `buildTransportPacket` |

### Notification registry IDs

| Registry | Name | Payload |
|---|---|---|
| 0x00C0 | Battery Level | 1 byte: 0–100 % |
| 0x00C1 | Lock Status | 1 byte: 0x01 = locked |
| 0x00C6 | Eco Mode | 1 byte: 0x01 = on |
| 0x01A2 | Settings Pack | 8 bytes (see `_parseSettingsPack`) |
| 0x03C1 | Battery Voltage | 2 bytes big-endian, millivolts |
| 0xFCFC | Firmware Info | ASCII string |

---

## Code conventions

* **Immutability** — `ScooterState` is immutable; use `copyWith` to derive new
  states.
* **`ChangeNotifier`** — `ScooterService` calls `notifyListeners()` after every
  state mutation; widgets observe it via `Consumer<ScooterService>`.
* **Pure functions** — `buildCommandPacket`, `buildTransportPacket`, and
  `computeAuthResponse` are top-level pure functions; keep them testable without
  mocks.
* **Error handling** — surface errors through `ScooterService.error`; never
  throw uncaught exceptions from command methods.
* **Single quotes** — use single quotes for Dart string literals (enforced by
  `analysis_options.yaml`).

---

## Testing guidelines

* Tests live in `test/`.
* Unit tests must not depend on real BLE hardware; mock `flutter_blue_plus`
  classes with `mocktail` if needed.
* The three public pure functions (`buildCommandPacket`, `buildTransportPacket`,
  `computeAuthResponse`) must each have a correctness test against a known-good
  vector from the reverse-engineering write-up.
* Run `flutter test --coverage` to generate a coverage report.

---

## CI

GitHub Actions runs on every push and pull request to `main`:

1. **Analyze** — `flutter analyze`
2. **Test** — `flutter test --coverage`
3. **Build APK** — `flutter build apk --debug` (smoke-test only, artifact
   uploaded)

See `.github/workflows/ci.yml`.

---

## Platform notes

### Android

* Minimum SDK: 21 (Android 5.0).
* `BLUETOOTH_SCAN` and `BLUETOOTH_CONNECT` permissions are required on API 31+.
* `ACCESS_FINE_LOCATION` is required for BLE scanning on API < 31.

### iOS

* `NSBluetoothAlwaysUsageDescription` must be set (already done in
  `ios/Runner/Info.plist`).
* Background BLE is **not** currently configured; add the `bluetooth-central`
  UIBackgroundModes key if needed.
