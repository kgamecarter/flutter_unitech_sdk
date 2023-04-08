import 'unitech_sdk_platform_interface.dart';

class ClockCtrl {
  static Future<void> setTimeMode(int mode) async {
    await UnitechSdkPlatform.instance.setTimeMode(mode);
  }

  static Future<void> setDateTime(DateTime dateTime) async {
    await UnitechSdkPlatform.instance.setDateTime(dateTime);
  }
}
