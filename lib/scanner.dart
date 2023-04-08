import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart';

class Scanner {
  static void enableScanner(bool enable) {
    var intent = AndroidIntent(
      action:
          enable ? "unitech.scanservice.start" : "unitech.scanservice.close",
      arguments: {
        'close': true,
      },
    );
    intent.sendBroadcast();
  }

  static void enableScan2Key(bool enable) {
    var intent = AndroidIntent(
      action: "unitech.scanservice.scan2key_setting",
      arguments: {
        'scan2key': enable,
      },
    );
    intent.sendBroadcast();
  }

  static final BroadcastReceiver scannerReceiver = BroadcastReceiver(
    names: <String>[
      "unitech.scanservice.data",
    ],
  );
}
