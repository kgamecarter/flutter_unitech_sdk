import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'unitech_sdk_method_channel.dart';

abstract class UnitechSdkPlatform extends PlatformInterface {
  /// Constructs a UnitechSdkPlatform.
  UnitechSdkPlatform() : super(token: _token);

  static final Object _token = Object();

  static UnitechSdkPlatform _instance = MethodChannelUnitechSdk();

  /// The default instance of [UnitechSdkPlatform] to use.
  ///
  /// Defaults to [MethodChannelUnitechSdk].
  static UnitechSdkPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [UnitechSdkPlatform] when
  /// they register themselves.
  static set instance(UnitechSdkPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }

  Future<void> setTimeMode(int mode) {
    throw UnimplementedError('setTimeMode() has not been implemented.');
  }

  Future<void> setDateTime(DateTime dateTime) {
    throw UnimplementedError('setDateTime() has not been implemented.');
  }
}
