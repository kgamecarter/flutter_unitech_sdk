import 'unitech_sdk_platform_interface.dart';

class AppManagementCtrl {
  static Future<void> installApp(String path, String pkgName) async {
    await UnitechSdkPlatform.instance
        .appManagementCtrlInstallApp(path, pkgName);
  }

  static Future<void> runSysCmd(String command) async {
    await UnitechSdkPlatform.instance.appManagementCtrlRunSysCmd(command);
  }
}
