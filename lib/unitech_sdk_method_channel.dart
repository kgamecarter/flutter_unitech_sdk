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
  Future<String?> getPlatformVersion() async {
    final version =
        await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }

  @override
  Future<void> setTimeMode(int mode) async {
    await methodChannel.invokeMethod<void>('setTimeMode', mode);
  }

  final format = DateFormat('dd/MM/yyyy HH:mm:ss');

  @override
  Future<void> setDateTime(DateTime dateTime) async {
    await methodChannel.invokeMethod<void>(
      'setDateTime',
      format.format(dateTime).split(' '),
    );
  }
}
