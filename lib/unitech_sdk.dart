import 'package:flutter_broadcasts/flutter_broadcasts.dart';

import 'scanner.dart';
import 'unitech_sdk_platform_interface.dart';

/// An injectable device API with its own scanner receiver.
///
/// Create one instance per owner and call [close] when that owner is disposed.
/// The static APIs remain available for existing applications.
class UnitechSdk {
  UnitechSdk({
    UnitechSdkPlatform? platform,
    BroadcastReceiver? receiver,
  })  : _platform = platform,
        _receiver = receiver ??
            BroadcastReceiver(names: const ['unitech.scanservice.data']);

  final UnitechSdkPlatform? _platform;
  final BroadcastReceiver _receiver;
  Future<void>? _starting;
  Future<void>? _closing;
  bool _closed = false;

  UnitechSdkPlatform get _device => _platform ?? UnitechSdkPlatform.instance;

  Stream<BroadcastMessage> get scanMessages => _receiver.messages;

  Future<void> startListening() {
    if (_closed) {
      return Future.error(StateError('UnitechSdk is closed.'));
    }
    return _starting ??= _receiver.start();
  }

  Future<void> setScannerEnabled(bool enabled) =>
      Scanner.enableScanner(enabled);

  Future<void> setScan2KeyEnabled(bool enabled) =>
      Scanner.enableScan2Key(enabled);

  Future<void> setTimeMode(int mode) => _device.clockCtrlSetTimeMode(mode);

  Future<void> setDateTime(DateTime value) =>
      _device.clockCtrlSetDateTime(value);

  Future<void> installApp(String path, String packageName) =>
      _device.appManagementCtrlInstallApp(path, packageName);

  Future<void> runSysCmd(String command) =>
      _device.appManagementCtrlRunSysCmd(command);

  /// Stops the owned receiver, including when startup is still pending.
  ///
  /// Calling this more than once returns the same cleanup future.
  Future<void> close() {
    _closed = true;
    return _closing ??= _stopListening();
  }

  Future<void> _stopListening() async {
    try {
      await _starting;
    } catch (_) {
      // Startup errors are delivered to startListening's caller. Still attempt
      // cleanup in case the receiver was partially initialized.
    }
    await _receiver.stop();
  }
}
