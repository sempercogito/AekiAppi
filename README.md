# AekiAppi

Flutter app for controlling your Äike T-scooter via Bluetooth Low Energy (BLE).

## Features

- **Scan** for nearby Äike scooters (AIKE, AIKE\_T, AIKE\_11)
- **Authenticate** using the SHA-1 challenge-response scheme documented in the
  reverse-engineering write-up by Rasmus Moorats
- **Lock / Unlock** the scooter
- **Open the battery tray**
- Toggle **Eco Mode**
- Toggle **Auto-brake**
- Set the **Auto-lock Timer** (0–60 min)
- Enable / disable **Transport Mode**
- Display live **battery level**, **battery voltage**, and **firmware version**
  from BLE notifications

## Architecture

```
lib/
├── main.dart                  # Entry point + Material theme + Provider setup
├── models/
│   └── scooter_state.dart     # Immutable state snapshot with copyWith
├── screens/
│   ├── scan_screen.dart       # BLE discovery UI
│   └── home_screen.dart       # Scooter control panel
└── services/
    └── scooter_service.dart   # BLE service: scan, auth, commands, notifications
```

## BLE Protocol

Authentication (runs once after connecting):
1. Read 20-byte challenge from characteristic `00002556-1212-efde-1523-785feabcd123`
2. Compute `SHA-1(challenge ‖ key)` where `key` = 20 × `0xFF` (default key)
3. Write 20-byte digest to `00002557-1212-efde-1523-785feabcd123`

Commands are 10-byte packets written to `0000155f-1212-efde-1523-785feabcd123`.
Status notifications arrive on `0000155e-1212-efde-1523-785feabcd123`.

See `lib/services/scooter_service.dart` for the full command and notification
registry reference.

## Getting Started

```bash
flutter pub get
flutter run
```

### Android permissions

The app requests the following permissions at runtime:

| Permission | Purpose |
|---|---|
| `BLUETOOTH_SCAN` | Discover nearby scooters |
| `BLUETOOTH_CONNECT` | Connect to and communicate with the scooter |
| `ACCESS_FINE_LOCATION` | Required on Android < 12 for BLE scanning |

### iOS permissions

`NSBluetoothAlwaysUsageDescription` is declared in `ios/Runner/Info.plist`.

## Running Tests

```bash
flutter test
```
