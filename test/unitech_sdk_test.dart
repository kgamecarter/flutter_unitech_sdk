import 'package:flutter_test/flutter_test.dart';
import 'package:unitech_sdk/clock_ctrl.dart';
import 'package:unitech_sdk/unitech_sdk_platform_interface.dart';
import 'package:unitech_sdk/unitech_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUnitechSdkPlatform
    with MockPlatformInterfaceMixin
    implements UnitechSdkPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');

  @override
  Future<void> clockCtrl_setTimeMode(int mode) => Future.value();

  @override
  Future<void> clockCtrl_setDateTime(DateTime dateTime) => Future.value();

  @override
  Future<void> appManagementCtrl_installApp(String path, String pkgName) =>
      Future.value();

  @override
  Future<void> appManagementCtrl_runSysCmd(String command) => Future.value();
}

void main() {
  final UnitechSdkPlatform initialPlatform = UnitechSdkPlatform.instance;

  test('$MethodChannelUnitechSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUnitechSdk>());
  });

  test('getPlatformVersion', () async {
    //UnitechSdk unitechSdkPlugin = UnitechSdk();
    MockUnitechSdkPlatform fakePlatform = MockUnitechSdkPlatform();
    UnitechSdkPlatform.instance = fakePlatform;

    //expect(await unitechSdkPlugin.getPlatformVersion(), '42');
  });
}
