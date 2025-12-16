# unitech_sdk

A Flutter plugin for integrating with Unitech handheld devices. This SDK provides functionalities to control the scanner, manage applications, and configure system clock settings on Unitech Android devices.

## Features

*   **Scanner Control**: Enable/disable scanner, toggle Scan2Key (keyboard wedge), and listen for barcode data broadcasts.
*   **App Management**: Install APKs and run system commands (requires system privileges).
*   **Clock Control**: Set system time and time mode.

## Installation

Add `unitech_sdk` to your `pubspec.yaml` dependencies.

```yaml
dependencies:
  unitech_sdk:
    # If local
    path: .
    # If git
    # git:
    #   url: https://github.com/your_repo/unitech_sdk.git
```

## Usage

### 1. Scanner

Control the built-in barcode scanner.

#### Enable/Disable Scanner

```dart
import 'package:unitech_sdk/scanner.dart';

// Enable scanner
Scanner.enableScanner(true);

// Disable scanner
Scanner.enableScanner(false);
```

#### Scan to Key (Keyboard Wedge)

Enable or disable the feature where scanned data is injected as key events (like typing).

```dart
// Enable Scan2Key
Scanner.enableScan2Key(true);

// Disable Scan2Key
Scanner.enableScan2Key(false);
```

#### Listen for Scan Data

Use the `scannerReceiver` to listen for broadcast intents from the scanner service (`unitech.scanservice.data`).

```dart
import 'package:unitech_sdk/scanner.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart';

// ... inside your widget or controller initialization

void startListening() {
  Scanner.scannerReceiver.start();
  Scanner.scannerReceiver.messages.listen((BroadcastMessage message) {
    if (message.name == "unitech.scanservice.data") {
      // The payload is in message.data
      // Example: extracting barcode text
      // Note: The actual key for barcode data depends on Unitech's SDK specification.
      // Common keys might be 'text', 'data', 'barcode', etc.
      print("Received scan data: ${message.data}");
    }
  });
}

void stopListening() {
  Scanner.scannerReceiver.stop();
}
```

### 2. App Management

**Note:** These features typically require the app to be signed with the system certificate or have specific permissions granted by the OS to function correctly.

```dart
import 'package:unitech_sdk/app_management_ctrl.dart';

// Install an APK from a specific path
// path: Absolute path to the APK file
// pkgName: Package name of the app
await AppManagementCtrl.installApp("/sdcard/Download/update.apk", "com.example.myapp");

// Run a system shell command
await AppManagementCtrl.runSysCmd("reboot");
```

### 3. Clock Control

Manage system time settings.

```dart
import 'package:unitech_sdk/clock_ctrl.dart';

// Set Time Mode
// mode: Integer representing the mode (e.g., Auto vs Manual)
await ClockCtrl.setTimeMode(1); 

// Set System Date and Time
await ClockCtrl.setDateTime(DateTime.now());
```

## Requirements

*   Flutter >=3.19.1
*   Android Device (Unitech Handheld)

## Dependencies

This package relies on the following plugins:
*   [flutter_broadcasts](https://pub.dev/packages/flutter_broadcasts)
*   [android_intent_plus](https://pub.dev/packages/android_intent_plus)
*   [intl](https://pub.dev/packages/intl)

