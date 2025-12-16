import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'unitech_sdk_platform_interface.dart';

/// An implementation of [UnitechSdkPlatform] that uses method channels.
class MethodChannelUnitechSdk extends UnitechSdkPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('unitech_sdk');

  @override
  Future<void> clockCtrlSetTimeMode(int mode) async {
    await methodChannel.invokeMethod<void>('ClockCtrl.setTimeMode', mode);
  }

  final format = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  Future<void> clockCtrlSetDateTime(DateTime dateTime) async {
    await methodChannel.invokeMethod<void>(
      'ClockCtrl.setDateTime',
      format.format(dateTime).split(' '),
    );
  }

  @override
  Future<void> appManagementCtrlInstallApp(String path, String pkgName) async {
    await methodChannel.invokeMethod<void>(
      'AppManagementCtrl.installApp',
      <String>[path, pkgName],
    );
  }

  @override
  Future<void> appManagementCtrlRunSysCmd(String command) async {
    await methodChannel.invokeMethod<void>(
      'AppManagementCtrl.runSysCmd',
      command,
    );
  }
}
