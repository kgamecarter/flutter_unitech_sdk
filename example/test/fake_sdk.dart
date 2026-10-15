import 'dart:async';

import 'package:flutter_broadcasts/flutter_broadcasts.dart';
import 'package:unitech_sdk/unitech_sdk.dart';

class FakeSdk extends UnitechSdk {
  final events = StreamController<BroadcastMessage>.broadcast();
  final calls = <Object>[];
  Completer<void>? pending;
  Object? failure;
  Object? startupFailure;
  int starts = 0;
  bool closed = false;

  @override
  Stream<BroadcastMessage> get scanMessages => events.stream;
  @override
  Future<void> startListening() async {
    starts++;
    if (startupFailure != null) throw startupFailure!;
  }

  @override
  Future<void> close() async {
    closed = true;
  }

  Future<void> _record(Object call) async {
    calls.add(call);
    await pending?.future;
    if (failure != null) throw failure!;
  }

  @override
  Future<void> setScannerEnabled(bool value) => _record(['scanner', value]);
  @override
  Future<void> setScan2KeyEnabled(bool value) => _record(['scan2key', value]);
  @override
  Future<void> setTimeMode(int value) => _record(['mode', value]);
  @override
  Future<void> setDateTime(DateTime value) => _record(value);
  @override
  Future<void> installApp(String path, String pkg) => _record([path, pkg]);
  @override
  Future<void> runSysCmd(String command) => _record(command);
}
