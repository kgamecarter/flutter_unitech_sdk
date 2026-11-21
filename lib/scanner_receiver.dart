import 'dart:async';

import 'package:flutter/services.dart';

/// A barcode broadcast from the Unitech scan service.
class BroadcastMessage {
  BroadcastMessage({required this.name, this.data})
      : timestamp = DateTime.now();

  final String name;
  final Map<String, dynamic>? data;
  final DateTime? timestamp;
}

/// An independently startable subscription to Unitech scanner broadcasts.
class ScannerReceiver {
  static const _channel = MethodChannel('unitech_sdk/scanner');
  static final _receivers = <int, ScannerReceiver>{};
  static int _nextId = 0;

  final int _id = _nextId++;
  final _messages = StreamController<BroadcastMessage>.broadcast();
  Future<void> _operation = Future<void>.value();
  bool _listening = false;

  bool get isListening => _listening;
  Stream<BroadcastMessage> get messages => _messages.stream;

  Future<void> start() => _enqueue(() async {
        if (_listening) return;
        _channel.setMethodCallHandler(_receiveMessage);
        _receivers[_id] = this;
        try {
          await _channel.invokeMethod<void>('startReceiver', _id);
          _listening = true;
        } catch (_) {
          _receivers.remove(_id);
          rethrow;
        }
      });

  Future<void> stop() => _enqueue(() async {
        if (!_listening) return;
        await _channel.invokeMethod<void>('stopReceiver', _id);
        _receivers.remove(_id);
        _listening = false;
      });

  Future<void> _enqueue(Future<void> Function() action) {
    final next = _operation.then((_) => action(),
        onError: (Object error, StackTrace stack) => action());
    _operation = next;
    return next;
  }

  static Future<void> _receiveMessage(MethodCall call) async {
    if (call.method != 'receiveBroadcast') return;
    final arguments = call.arguments as Map<Object?, Object?>;
    final receiver = _receivers[arguments['receiverId']];
    if (receiver == null) return;
    receiver._messages.add(BroadcastMessage(
      name: arguments['name'] as String,
      data: Map<String, dynamic>.from(arguments['data'] as Map),
    ));
  }
}
