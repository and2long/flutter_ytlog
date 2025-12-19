import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_ytlog/flutter_ytlog.dart';

void main() {
  test('formatDateTimeWithTimeZone formats local with numeric offset', () {
    final dt = DateTime(2024, 1, 2, 3, 4, 5, 6);
    final offset = dt.timeZoneOffset;
    final sign = offset.isNegative ? '-' : '+';
    final hours = offset.inHours.abs().toString().padLeft(2, '0');
    final minutes = (offset.inMinutes.abs() % 60).toString().padLeft(2, '0');
    final expected = '2024-01-02T03:04:05.006$sign$hours:$minutes';
    expect(Log.formatDateTimeWithTimeZone(dt), expected);
  });
}
