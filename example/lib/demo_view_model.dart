import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart';
import 'package:unitech_sdk/unitech_sdk.dart';

/// Owns the SDK instance passed to it; the view only renders its state.
class DemoViewModel extends ChangeNotifier {
  DemoViewModel({required UnitechSdk sdk}) : _sdk = sdk;

  final UnitechSdk _sdk;
  StreamSubscription<BroadcastMessage>? _subscription;
  bool _disposed = false;
  bool _initialized = false;
  bool _busy = false;
  bool _scannerEnabled = true;
  bool _scan2KeyEnabled = true;
  List<String> _scans = const [];
  String? _message;

  bool get busy => _busy;
  bool get scannerEnabled => _scannerEnabled;
  bool get scan2KeyEnabled => _scan2KeyEnabled;
  List<String> get scans => _scans;
  String? get message => _message;

  Future<void> initialize() async {
    if (_initialized || _disposed) return;
    _initialized = true;
    _subscription = _sdk.scanMessages.listen(
      (event) {
        if (_disposed) return;
        _scans = List.unmodifiable([
          '${event.timestamp ?? DateTime.now()}: ${event.data}',
          ..._scans,
        ]);
        notifyListeners();
      },
      onError: (Object error) => _showMessage('Scan failed: $error'),
    );
    try {
      await _sdk.startListening();
    } catch (error) {
      _showMessage('Scanner startup failed: $error');
    }
  }

  Future<void> setScannerEnabled(bool enabled) => _run(() async {
        await _sdk.setScannerEnabled(enabled);
        if (!_disposed) _scannerEnabled = enabled;
      }, 'Scanner command sent');

  Future<void> setScan2KeyEnabled(bool enabled) => _run(() async {
        await _sdk.setScan2KeyEnabled(enabled);
        if (!_disposed) _scan2KeyEnabled = enabled;
      }, 'Scan2Key command sent');

  void clearScans() {
    if (_disposed) return;
    _scans = const [];
    notifyListeners();
  }

  Future<void> setTimeMode(int mode) =>
      _run(() => _sdk.setTimeMode(mode), 'Time mode command sent');

  Future<void> syncTime() =>
      _run(() => _sdk.setDateTime(DateTime.now()), 'Time command sent');

  Future<void> installApp(String path, String packageName) async {
    if (_busy || _disposed) return;
    if (path.trim().isEmpty || packageName.trim().isEmpty) {
      _showMessage('Enter an APK path and package name');
      return;
    }
    await _run(
      () => _sdk.installApp(path.trim(), packageName.trim()),
      'Install command sent',
    );
  }

  Future<void> runCommand(String command) async {
    if (_busy || _disposed) return;
    if (command.trim().isEmpty) {
      _showMessage('Enter a system command');
      return;
    }
    await _run(() => _sdk.runSysCmd(command), 'Command sent');
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    if (_busy || _disposed) return;
    _busy = true;
    _message = null;
    notifyListeners();
    try {
      await action();
      if (!_disposed) _message = success;
    } catch (error) {
      if (!_disposed) _message = 'Command failed: $error';
    } finally {
      if (!_disposed) {
        _busy = false;
        notifyListeners();
      }
    }
  }

  void _showMessage(String message) {
    if (_disposed) return;
    _message = message;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    unawaited(_releaseResources());
    super.dispose();
  }

  Future<void> _releaseResources() async {
    try {
      await Future.wait([
        if (_subscription != null) _subscription!.cancel(),
        _sdk.close(),
      ]);
    } catch (error, stack) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: error,
        stack: stack,
        context: ErrorDescription('while closing the scanner'),
      ));
    }
  }
}
