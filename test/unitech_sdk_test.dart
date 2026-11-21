import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:unitech_sdk/app_management_ctrl.dart';
import 'package:unitech_sdk/clock_ctrl.dart';
import 'package:unitech_sdk/unitech_sdk.dart';
import 'package:unitech_sdk/unitech_sdk_method_channel.dart';
import 'package:unitech_sdk/unitech_sdk_platform_interface.dart';

class FakePlatform extends UnitechSdkPlatform {
  final calls = <Object>[];

  @override
  Future<void> clockCtrlSetTimeMode(int mode) async => calls.add(mode);
  @override
  Future<void> clockCtrlSetDateTime(DateTime value) async => calls.add(value);
  @override
  Future<void> appManagementCtrlInstallApp(String path, String pkg) async =>
      calls.add([path, pkg]);
  @override
  Future<void> appManagementCtrlRunSysCmd(String command) async =>
      calls.add(command);
}

class FakeReceiver extends ScannerReceiver {
  final events = StreamController<BroadcastMessage>.broadcast();
  Completer<void>? startup;
  int starts = 0;
  int stops = 0;

  @override
  Stream<BroadcastMessage> get messages => events.stream;
  @override
  Future<void> start() async {
    starts++;
    await startup?.future;
  }

  @override
  Future<void> stop() async {
    stops++;
  }
}

void main() {
  test('method channel is the default implementation', () {
    expect(UnitechSdkPlatform.instance, isA<MethodChannelUnitechSdk>());
  });

  test('instance API and legacy API delegate the same device commands',
      () async {
    final original = UnitechSdkPlatform.instance;
    final platform = FakePlatform();
    final receiver = FakeReceiver();
    final sdk = UnitechSdk(platform: platform, receiver: receiver);
    addTearDown(() async {
      UnitechSdkPlatform.instance = original;
      await sdk.close();
      await receiver.events.close();
    });
    final date = DateTime(2026, 10, 15);
    await sdk.setTimeMode(1);
    await sdk.setDateTime(date);
    await sdk.installApp('/app.apk', 'com.app');
    await sdk.runSysCmd('echo hello');
    UnitechSdkPlatform.instance = platform;
    await ClockCtrl.setTimeMode(1);
    await ClockCtrl.setDateTime(date);
    await AppManagementCtrl.installApp('/app.apk', 'com.app');
    await AppManagementCtrl.runSysCmd('echo hello');
    expect(platform.calls.take(4), [
      1,
      date,
      ['/app.apk', 'com.app'],
      'echo hello'
    ]);
    expect(platform.calls.skip(4), platform.calls.take(4));
  });

  test('starts once and forwards scan messages', () async {
    final receiver = FakeReceiver();
    final sdk = UnitechSdk(receiver: receiver);
    await sdk.startListening();
    await sdk.startListening();
    final message = BroadcastMessage(
        name: 'unitech.scanservice.data', data: {'text': 'ABC'});
    final result = sdk.scanMessages.first;
    receiver.events.add(message);
    expect(await result, same(message));
    expect(receiver.starts, 1);
    await sdk.close();
    await sdk.close();
    expect(receiver.stops, 1);
    await expectLater(sdk.startListening(), throwsStateError);
    await receiver.events.close();
  });

  test('close waits for startup before stopping the receiver', () async {
    final receiver = FakeReceiver()..startup = Completer<void>();
    final sdk = UnitechSdk(receiver: receiver);
    final starting = sdk.startListening();
    final closing = sdk.close();
    await Future<void>.delayed(Duration.zero);
    expect(receiver.stops, 0);
    receiver.startup!.complete();
    await starting;
    await closing;
    expect(receiver.stops, 1);
    await receiver.events.close();
  });

  test('cleanup still runs after startup fails', () async {
    final receiver = FakeReceiver()..startup = Completer<void>();
    final sdk = UnitechSdk(receiver: receiver);
    final starting = expectLater(sdk.startListening(), throwsStateError);
    final closing = sdk.close();
    receiver.startup!.completeError(StateError('start failed'));
    await starting;
    await closing;
    expect(receiver.stops, 1);
    await receiver.events.close();
  });
}
