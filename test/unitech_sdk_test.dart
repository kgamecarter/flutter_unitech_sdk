import 'package:flutter_test/flutter_test.dart';
import 'package:unitech_sdk/clock_ctrl.dart';
import 'package:unitech_sdk/unitech_sdk_platform_interface.dart';
import 'package:unitech_sdk/unitech_sdk_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockUnitechSdkPlatform
    with MockPlatformInterfaceMixin
    implements UnitechSdkPlatform {
  @override
  Future<void> clockCtrlSetTimeMode(int mode) => Future.value();

  @override
  Future<void> clockCtrlSetDateTime(DateTime dateTime) => Future.value();

  @override
  Future<void> appManagementCtrlInstallApp(String path, String pkgName) =>
      Future.value();

  @override
  Future<void> appManagementCtrlRunSysCmd(String command) => Future.value();
}

void main() {
  final UnitechSdkPlatform initialPlatform = UnitechSdkPlatform.instance;

  test('$MethodChannelUnitechSdk is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelUnitechSdk>());
  });
}
