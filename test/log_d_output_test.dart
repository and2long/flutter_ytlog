import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ytlog/flutter_ytlog.dart';

String _stripAnsi(String input) {
  return input.replaceAll(RegExp(r'\x1B\[[0-9;]*m'), '');
}

void main() {
  test('Log.d prints expected line', () {
    final originalNow = Log.now;
    final originalPrinter = Log.printer;

    final fixed = DateTime(2024, 1, 2, 3, 4, 5, 6);
    Log.now = () => fixed;

    String? printed;
    Log.printer = (message) => printed = message;

    try {
      Log.d('TAG', 'Hello World');
      expect(printed, isNotNull);

      final plain = _stripAnsi(printed!).trimRight();
      final expectedPrefix = Log.formatDateTimeWithTimeZone(fixed);
      expect(plain, '$expectedPrefix [DEBUG] [TAG] : Hello World');
    } finally {
      Log.now = originalNow;
      Log.printer = originalPrinter;
    }
  });
}
