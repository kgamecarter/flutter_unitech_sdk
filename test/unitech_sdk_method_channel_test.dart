import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitech_sdk/unitech_sdk_method_channel.dart';

void main() {
  MethodChannelUnitechSdk platform = MethodChannelUnitechSdk();
  const MethodChannel channel = MethodChannel('unitech_sdk');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
