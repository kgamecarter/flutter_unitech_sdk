import 'package:flutter/material.dart';
import 'package:flutter_broadcasts/flutter_broadcasts.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:unitech_sdk_example/main.dart';

import 'fake_sdk.dart';

void main() {
  testWidgets('shows scans, clears them, and releases the device',
      (tester) async {
    final sdk = FakeSdk();
    await tester.pumpWidget(MyApp(sdk: sdk));
    expect(find.text('Scanner'), findsOneWidget);
    sdk.events.add(BroadcastMessage(
        name: 'unitech.scanservice.data', data: {'text': 'ABC'}));
    await tester.pump();
    expect(find.textContaining('ABC'), findsOneWidget);
    await tester.tap(find.text('Clear Scanned Data'));
    await tester.pump();
    expect(find.text('No data scanned yet'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(sdk.closed, isTrue);
    expect(sdk.events.hasListener, isFalse);
    await sdk.events.close();
  });

  testWidgets('failed switch command is shown without changing its value',
      (tester) async {
    final sdk = FakeSdk()..failure = StateError('denied');
    await tester.pumpWidget(MyApp(sdk: sdk));
    await tester.tap(find.text('Enable Scanner'));
    await tester.pumpAndSettle();
    expect(find.textContaining('denied'), findsOneWidget);
    expect(
        tester
            .widget<SwitchListTile>(
                find.widgetWithText(SwitchListTile, 'Enable Scanner'))
            .value,
        isTrue);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    await sdk.events.close();
  });

  for (final size in [const Size(375, 667), const Size(667, 375)]) {
    testWidgets('command feedback stays visible at $size with large text',
        (tester) async {
      await tester.binding.setSurfaceSize(size);
      tester.platformDispatcher.textScaleFactorTestValue = 2;
      addTearDown(() async {
        tester.platformDispatcher.clearTextScaleFactorTestValue();
        await tester.binding.setSurfaceSize(null);
      });
      final sdk = FakeSdk();
      await tester.pumpWidget(MyApp(sdk: sdk));
      await tester.scrollUntilVisible(
        find.text('Run Command'),
        300,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.enterText(
          find.widgetWithText(TextField, 'System Command'), 'echo hello');
      await tester.ensureVisible(find.text('Run Command'));
      await tester.tap(find.text('Run Command'));
      await tester.pumpAndSettle();
      expect(find.text('Command sent').hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
      await tester.pump();
      await sdk.events.close();
    });
  }
}
