
import 'unitech_sdk_platform_interface.dart';

class UnitechSdk {
  Future<String?> getPlatformVersion() {
    return UnitechSdkPlatform.instance.getPlatformVersion();
  }
}
