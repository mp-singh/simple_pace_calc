import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pace_calc/src/utils/fieldhouse_utils.dart';
import 'package:simple_pace_calc/src/models/enums.dart';

void main() {
  test('default lane map contains 1..6', () {
    for (var i = 1; i <= 6; i++) {
      expect(defaultLaneLapMeters.containsKey(i), isTrue);
      expect(defaultLaneLapMeters[i]! > 0, isTrue);
    }
  });

  test('lapMetersForLane uses map when available', () {
    expect(lapMetersForLane(1), closeTo(defaultLaneLapMeters[1]!, 1e-9));
    // lapMetersForLane without explicit map may compute via formula, allow small tolerance
    expect(lapMetersForLane(6), closeTo(defaultLaneLapMeters[6]!, 1e-2));
  });

  test('computeLapPaceSeconds computes expected value for perKm', () {
    // pace 5:00 per km = 300 sec/km, lane1=200m -> lap = 300 * 0.2 = 60s
    final secs = computeLapPaceSeconds(
      300,
      PaceUnit.perKm,
      lapMetersForLane(1),
    );
    expect(secs, equals(60));
  });
}
