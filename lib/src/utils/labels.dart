import '../models/enums.dart';

String distanceUnitLabel(DistanceUnit unit) {
  switch (unit) {
    case DistanceUnit.meters:
      return 'Meters';
    case DistanceUnit.kilometers:
      return 'Kilometers';
    case DistanceUnit.miles:
      return 'Miles';
  }
}

String paceUnitLabel(PaceUnit unit) {
  switch (unit) {
    case PaceUnit.perKm:
      return 'min/km';
    case PaceUnit.perMile:
      return 'min/mi';
  }
}
