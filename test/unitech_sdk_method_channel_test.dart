import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitech_sdk/unitech_sdk_method_channel.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final platform = MethodChannelUnitechSdk();
  const channel = MethodChannel('unitech_sdk');
  final calls = <MethodCall>[];
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    calls.clear();
    messenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  test('encodes all device commands using the native contract', () async {
    await platform.clockCtrlSetTimeMode(1);
    await platform.clockCtrlSetDateTime(DateTime(2026, 10, 15, 9, 8, 7));
    await platform.appManagementCtrlInstallApp('/sdcard/app.apk', 'com.app');
    await platform.appManagementCtrlRunSysCmd('echo hello');

    expect(calls.map((call) => call.method), [
      'ClockCtrl.setTimeMode',
      'ClockCtrl.setDateTime',
      'AppManagementCtrl.installApp',
      'AppManagementCtrl.runSysCmd',
    ]);
    expect(calls.map((call) => call.arguments), [
      1,
      ['15/10/2026', '09:08:07'],
      ['/sdcard/app.apk', 'com.app'],
      'echo hello',
    ]);
  });

  test('propagates platform failures', () async {
    messenger.setMockMethodCallHandler(channel, (_) async {
      throw PlatformException(code: 'denied');
    });
    await expectLater(
      platform.appManagementCtrlRunSysCmd('echo hello'),
      throwsA(isA<PlatformException>()),
    );
  });
}
