import '../models/enums.dart';

double distanceToKilometers(double value, DistanceUnit unit) {
  switch (unit) {
    case DistanceUnit.meters:
      return value / 1000.0;
    case DistanceUnit.kilometers:
      return value;
    case DistanceUnit.miles:
      return value * 1.609344;
  }
}

double distanceToMiles(double value, DistanceUnit unit) {
  switch (unit) {
    case DistanceUnit.meters:
      return value / 1609.344;
    case DistanceUnit.kilometers:
      return value / 1.609344;
    case DistanceUnit.miles:
      return value;
  }
}
