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

### Instance API and architecture

For applications that need dependency injection and an owned scanner lifecycle,
use the instance API:

```dart
import 'package:unitech_sdk/unitech_sdk.dart';

final sdk = UnitechSdk();
final subscription = sdk.scanMessages.listen((message) {
  print(message.data);
});

try {
  await sdk.startListening();
  await sdk.setScannerEnabled(true);
  await sdk.setScan2KeyEnabled(false);
  // Keep the subscription alive while your screen or controller is active.
} finally {
  await subscription.cancel();
  await sdk.close();
}
```

In a real screen, start listening during initialization and perform the cleanup
when the owning controller is disposed, as shown in [example](example/).
Each instance owns a separate receiver; repeated start/close calls are safe,
and a closed receiver cannot be restarted. Startup errors are returned by
`startListening`, and cleanup errors by `close`, when reported by the underlying
broadcast plugin. The instance API also provides `setTimeMode`, `setDateTime`,
`installApp`, and `runSysCmd`.

The SDK is the device data-access boundary: `UnitechSdk` composes the platform
interface and scanner broadcast service. UI state stays in the application's
ViewModel. The example uses only a view and a ViewModel, with constructor
injection and no extra architecture packages.

Existing `Scanner`, `ClockCtrl`, and `AppManagementCtrl` entry points remain
available. Scanner commands now return `Future<void>` so callers can await
broadcast completion and handle errors. Existing calls may continue to ignore
the result, and the methods can still be used as `void Function(bool)` callbacks.
Projects enabling `unawaited_futures` may need to explicitly ignore the future.
Completion means the command was sent,
not that the device has finished installing an APK or applying every operation.

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

The SDK receives `unitech.scanservice.data` directly on Android. Listen through `scannerReceiver` to read the broadcast extras, including the barcode in `data?['text']`.

```dart
import 'package:unitech_sdk/scanner.dart';

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
*   [android_intent_plus](https://pub.dev/packages/android_intent_plus)
*   [intl](https://pub.dev/packages/intl)

