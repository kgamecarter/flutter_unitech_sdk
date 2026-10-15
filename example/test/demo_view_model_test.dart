import 'dart:async';

import 'package:flutter_broadcasts/flutter_broadcasts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitech_sdk_example/demo_view_model.dart';

import 'fake_sdk.dart';

void main() {
  late FakeSdk sdk;
  late DemoViewModel model;

  setUp(() {
    sdk = FakeSdk();
    model = DemoViewModel(sdk: sdk);
  });
  tearDown(() async {
    model.dispose();
    await Future<void>.delayed(Duration.zero);
    await sdk.events.close();
  });

  test('scans are immutable snapshots and can be cleared', () async {
    await model.initialize();
    await model.initialize();
    final before = model.scans;
    sdk.events.add(BroadcastMessage(
        name: 'unitech.scanservice.data', data: {'text': 'ABC'}));
    await Future<void>.delayed(Duration.zero);
    expect(sdk.starts, 1);
    expect(before, isEmpty);
    expect(model.scans.single, contains('ABC'));
    expect(() => model.scans.add('change'), throwsUnsupportedError);
    model.clearScans();
    expect(model.scans, isEmpty);
  });

  test('waits for success and prevents duplicate commands', () async {
    sdk.pending = Completer<void>();
    final command = model.setScannerEnabled(false);
    expect(model.busy, isTrue);
    expect(model.scannerEnabled, isTrue);
    expect(model.message, isNull);
    await model.setScannerEnabled(false);
    expect(sdk.calls, hasLength(1));
    sdk.pending!.complete();
    await command;
    expect(model.busy, isFalse);
    expect(model.scannerEnabled, isFalse);
    expect(model.message, 'Scanner command sent');
  });

  test('failed switches retain previous state and expose an error', () async {
    sdk.failure = StateError('denied');
    await model.setScannerEnabled(false);
    await model.setScan2KeyEnabled(false);
    expect(model.scannerEnabled, isTrue);
    expect(model.scan2KeyEnabled, isTrue);
    expect(model.busy, isFalse);
    expect(model.message, contains('denied'));
  });

  test('validates input and only reports installation after completion',
      () async {
    await model.installApp(' ', 'com.app');
    await model.runCommand(' ');
    expect(sdk.calls, isEmpty);
    sdk.pending = Completer<void>();
    final install = model.installApp(' /app.apk ', ' com.app ');
    expect(model.message, isNull);
    expect(sdk.calls.single, ['/app.apk', 'com.app']);
    sdk.pending!.complete();
    await install;
    expect(model.message, 'Install command sent');
    sdk.failure = StateError('denied');
    await model.runCommand('echo hello');
    expect(model.message, contains('Command failed'));
  });

  test('clock actions and commands reach the SDK', () async {
    await model.setTimeMode(1);
    await model.setTimeMode(0);
    await model.syncTime();
    await model.runCommand('echo hello');
    expect(sdk.calls[0], ['mode', 1]);
    expect(sdk.calls[1], ['mode', 0]);
    expect(sdk.calls[2], isA<DateTime>());
    expect(sdk.calls[3], 'echo hello');
  });

  test('startup and stream errors become visible state', () async {
    sdk.startupFailure = StateError('unavailable');
    await model.initialize();
    expect(model.message, contains('Scanner startup failed'));
    sdk.events.addError(StateError('stream failed'));
    await Future<void>.delayed(Duration.zero);
    expect(model.message, contains('Scan failed'));
  });

  test('dispose cancels scans and ignores pending command completion',
      () async {
    final disposableSdk = FakeSdk()..pending = Completer<void>();
    final disposableModel = DemoViewModel(sdk: disposableSdk);
    await disposableModel.initialize();
    int notifications = 0;
    disposableModel.addListener(() => notifications++);
    final command = disposableModel.setScannerEnabled(false);
    disposableModel.dispose();
    disposableSdk.events
        .add(BroadcastMessage(name: 'unitech.scanservice.data'));
    disposableSdk.pending!.complete();
    await command;
    await Future<void>.delayed(Duration.zero);
    expect(notifications, 1);
    expect(disposableSdk.closed, isTrue);
    expect(disposableSdk.events.hasListener, isFalse);
    await disposableSdk.events.close();
  });
}
