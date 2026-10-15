import 'package:flutter_test/flutter_test.dart';
import 'package:unitech_sdk/scanner.dart';

void main() {
  test('legacy calls and void callbacks remain source compatible', () async {
    // Existing callers can discard the result or use the old callback type.
    Scanner.enableScanner(true);
    Scanner.enableScan2Key(false);
    const void Function(bool) enableScanner = Scanner.enableScanner;
    const void Function(bool) enableScan2Key = Scanner.enableScan2Key;
    enableScanner(false);
    enableScan2Key(true);

    // Callers that need completion or error handling can now await the same API.
    await Scanner.enableScanner(true);
    await Scanner.enableScan2Key(false);
  });
}
