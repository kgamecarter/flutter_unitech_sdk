import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitech_sdk/scanner.dart';
import 'package:unitech_sdk/unitech_sdk.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('instance receivers coexist with the legacy shared receiver', () async {
    const channel = MethodChannel('unitech_sdk/scanner');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    final activeIds = <int>{};
    messenger.setMockMethodCallHandler(channel, (call) async {
      final id = call.arguments as int;
      if (call.method == 'startReceiver') {
        activeIds.add(id);
      } else if (call.method == 'stopReceiver') {
        activeIds.remove(id);
      } else {
        fail('Unexpected receiver method: ${call.method}');
      }
      return null;
    });

    final first = UnitechSdk();
    final second = UnitechSdk();
    final legacy = Scanner.scannerReceiver;
    final firstMessages = <BroadcastMessage>[];
    final secondMessages = <BroadcastMessage>[];
    final legacyMessages = <BroadcastMessage>[];
    final subscriptions = [
      first.scanMessages.listen(firstMessages.add),
      second.scanMessages.listen(secondMessages.add),
      legacy.messages.listen(legacyMessages.add),
    ];
    addTearDown(() async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      await first.close();
      await second.close();
      await legacy.stop();
      messenger.setMockMethodCallHandler(channel, null);
    });

    Future<void> sendScan(String text) async {
      for (final id in activeIds.toList()) {
        await messenger.handlePlatformMessage(
          channel.name,
          channel.codec.encodeMethodCall(MethodCall('receiveBroadcast', {
            'receiverId': id,
            'name': 'unitech.scanservice.data',
            'data': {'text': text},
          })),
          null,
        );
      }
      await Future<void>.delayed(Duration.zero);
    }

    await first.startListening();
    await second.startListening();
    await legacy.start();
    await Future<void>.delayed(Duration.zero);
    expect(activeIds, hasLength(3));
    await sendScan('first');
    expect(firstMessages.single.data, {'text': 'first'});
    expect(secondMessages.single.data, {'text': 'first'});
    expect(legacyMessages.single.data, {'text': 'first'});

    await first.close();
    expect(activeIds, hasLength(2));
    await sendScan('second');
    expect(firstMessages, hasLength(1));
    expect(secondMessages.last.data, {'text': 'second'});
    expect(legacyMessages.last.data, {'text': 'second'});
    expect(legacy.isListening, isTrue);
  });
}
