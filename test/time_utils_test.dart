import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pace_calc/src/utils/time_utils.dart';

void main() {
  group('parseTimeToSeconds', () {
    test('parses mm:ss', () {
      expect(parseTimeToSeconds('04:30'), equals(270));
    });

    test('parses hh:mm:ss', () {
      expect(parseTimeToSeconds('01:02:03'), equals(3723));
    });

    test('parses single seconds', () {
      expect(parseTimeToSeconds('5'), equals(5));
    });

    test('returns null for invalid', () {
      expect(parseTimeToSeconds('abc'), isNull);
      expect(parseTimeToSeconds('1:60:xx'), isNull);
    });
  });

  group('formatSeconds', () {
    test('formats mm:ss', () {
      expect(formatSeconds(270), equals('04:30'));
    });

    test('formats hh:mm:ss', () {
      expect(formatSeconds(3723), equals('01:02:03'));
    });
  });
}
