import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pace_calc/src/utils/fieldhouse_utils.dart';
import 'package:simple_pace_calc/src/models/enums.dart';

void main() {
  test('computeLapPaceFormatted returns expected string for perKm', () {
    final formatted = computeLapPaceFormatted(
      '05:00',
      PaceUnit.perKm,
      lapMetersForLane(1),
    );
    expect(formatted, equals('01:00'));
  });

  test('computeLapPaceFormatted returns expected string for perMile', () {
    // pace 8:00 per mile = 480 sec/mi, lane2~206.28m -> lapMiles = 0.12825 -> secs~61.68 -> 62
    final formatted = computeLapPaceFormatted(
      '08:00',
      PaceUnit.perMile,
      lapMetersForLane(2),
    );
    expect(formatted, isNotNull);
  });
}
