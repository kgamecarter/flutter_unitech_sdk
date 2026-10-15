import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart';

class Scanner {
  /// Sends the scanner setting and completes when the broadcast is sent.
  static Future<void> enableScanner(bool enable) {
    var intent = AndroidIntent(
      action:
          enable ? "unitech.scanservice.start" : "unitech.scanservice.close",
      arguments: {
        'close': true,
      },
    );
    return intent.sendBroadcast();
  }

  /// Sends the keyboard-wedge setting and reports broadcast failures.
  static Future<void> enableScan2Key(bool enable) {
    var intent = AndroidIntent(
      action: "unitech.scanservice.scan2key_setting",
      arguments: {
        'scan2key': enable,
      },
    );
    return intent.sendBroadcast();
  }

  static final BroadcastReceiver scannerReceiver = BroadcastReceiver(
    names: <String>[
      "unitech.scanservice.data",
    ],
  );
}
