import 'package:flutter_test/flutter_test.dart';
import 'package:simple_pace_calc/src/utils/conversions.dart';
import 'package:simple_pace_calc/src/models/enums.dart';

void main() {
  group('distanceToKilometers', () {
    test('meters to km', () {
      expect(
        distanceToKilometers(1500, DistanceUnit.meters),
        closeTo(1.5, 1e-9),
      );
    });

    test('kilometers passthrough', () {
      expect(distanceToKilometers(2.0, DistanceUnit.kilometers), equals(2.0));
    });

    test('miles to km', () {
      expect(
        distanceToKilometers(3.0, DistanceUnit.miles),
        closeTo(3.0 * 1.609344, 1e-9),
      );
    });
  });

  group('distanceToMiles', () {
    test('meters to miles', () {
      expect(
        distanceToMiles(1609.344, DistanceUnit.meters),
        closeTo(1.0, 1e-9),
      );
    });

    test('kilometers to miles', () {
      expect(
        distanceToMiles(1.609344, DistanceUnit.kilometers),
        closeTo(1.0, 1e-9),
      );
    });

    test('miles passthrough', () {
      expect(distanceToMiles(5.0, DistanceUnit.miles), equals(5.0));
    });
  });
}
