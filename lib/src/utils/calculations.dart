import '../models/enums.dart';
import 'conversions.dart';
import 'time_utils.dart';
import 'fieldhouse_utils.dart';

/// Calculation logic extracted from PaceHomePage.

String calculatePace({
  required String timeText,
  required String distanceText,
  required DistanceUnit distanceUnit,
  required PaceUnit paceUnit,
}) {
  final totalSeconds = parseTimeToSeconds(timeText);
  if (totalSeconds == null) return 'Invalid time';

  final distanceVal = double.tryParse(distanceText.replaceAll(',', ''));
  if (distanceVal == null || distanceVal <= 0) return 'Invalid distance';

  double unitDistance;
  if (paceUnit == PaceUnit.perKm) {
    unitDistance = distanceToKilometers(distanceVal, distanceUnit);
  } else {
    unitDistance = distanceToMiles(distanceVal, distanceUnit);
  }
  if (unitDistance <= 0) return 'Distance must be > 0';

  final paceSec = (totalSeconds / unitDistance).round();
  final unitLabel = paceUnit == PaceUnit.perKm ? 'per km' : 'per mile';
  return 'Pace: ${formatSeconds(paceSec)} $unitLabel';
}

String calculateTime({
  required String paceText,
  required String distanceText,
  required DistanceUnit distanceUnit,
  required PaceUnit paceUnit,
}) {
  final paceSec = parseTimeToSeconds(paceText);
  if (paceSec == null) return 'Invalid pace';

  final distanceVal = double.tryParse(distanceText.replaceAll(',', ''));
  if (distanceVal == null || distanceVal <= 0) return 'Invalid distance';

  double unitDistance;
  if (paceUnit == PaceUnit.perKm) {
    unitDistance = distanceToKilometers(distanceVal, distanceUnit);
  } else {
    unitDistance = distanceToMiles(distanceVal, distanceUnit);
  }
  if (unitDistance <= 0) return 'Distance must be > 0';

  final totalSec = (paceSec * unitDistance).round();
  return 'Time: ${formatSeconds(totalSec)}';
}

(String, double?) calculateDistance({
  required String timeText,
  required String paceText,
  required DistanceUnit distanceUnit,
  required PaceUnit paceUnit,
}) {
  final totalSec = parseTimeToSeconds(timeText);
  if (totalSec == null) return ('Invalid time', null);

  final paceSec = parseTimeToSeconds(paceText);
  if (paceSec == null) return ('Invalid pace', null);

  final distInUnits = totalSec / paceSec;
  String out;
  double? lastDistanceMeters;
  if (paceUnit == PaceUnit.perKm) {
    double outValue;
    switch (distanceUnit) {
      case DistanceUnit.meters:
        outValue = distInUnits * 1000.0;
        out = '${outValue.toStringAsFixed(2)} m';
        break;
      case DistanceUnit.kilometers:
        outValue = distInUnits;
        out = '${outValue.toStringAsFixed(3)} km';
        break;
      case DistanceUnit.miles:
        outValue = distInUnits / 1.609344;
        out = '${outValue.toStringAsFixed(3)} mi';
        break;
    }
    lastDistanceMeters = distInUnits * 1000.0;
  } else {
    double outValue;
    switch (distanceUnit) {
      case DistanceUnit.meters:
        outValue = distInUnits * 1609.344;
        out = '${outValue.toStringAsFixed(2)} m';
        break;
      case DistanceUnit.kilometers:
        outValue = distInUnits * 1.609344;
        out = '${outValue.toStringAsFixed(3)} km';
        break;
      case DistanceUnit.miles:
        outValue = distInUnits;
        out = '${outValue.toStringAsFixed(3)} mi';
        break;
    }
    lastDistanceMeters = distInUnits * 1609.344;
  }
  return (out, lastDistanceMeters);
}

(Map<String, List<Map<String, String>>>, Map<String, String>, double?)
calculateTrack({
  required String paceText,
  required String distanceText,
  required DistanceUnit distanceUnit,
  required PaceUnit paceUnit,
  required int fieldhouseLane,
  required bool useCustomLap,
  required String fieldhouseCustomText,
}) {
  final paceSec = parseTimeToSeconds(paceText);
  final distText = distanceText.trim();
  final parsedDist = double.tryParse(distText.replaceAll(',', ''));

  double lapMeters;
  if (useCustomLap) {
    final custom = fieldhouseCustomText.trim();
    if (custom.isEmpty) {
      if (paceSec == null && (parsedDist == null || parsedDist <= 0)) {
        return ({}, {}, null);
      }
      return (
        {'error': []},
        {'error': 'Enter custom lap length or disable custom'},
        null,
      );
    }
    final parsed = double.tryParse(custom.replaceAll(',', ''));
    if (parsed == null || parsed <= 0) {
      return ({'error': []}, {'error': 'Invalid custom lap length'}, null);
    }
    lapMeters = parsed;
  } else {
    try {
      lapMeters = lapMetersForLane(
        fieldhouseLane,
        laneMap: defaultLaneLapMeters,
      );
    } catch (e) {
      return ({'error': []}, {'error': 'Invalid lane'}, null);
    }
  }

  List<Map<String, String>> fieldhouseResults = [];
  Map<String, String> lapsResult = {};
  double? lastDistanceMeters;

  if (paceSec != null) {
    if (useCustomLap) {
      final lapSecs = computeLapPaceSeconds(paceSec, paceUnit, lapMeters);
      if (lapSecs != null) {
        fieldhouseResults = [
          {
            'lane': 'custom',
            'label': 'Custom lap',
            'meters': lapMeters.toStringAsFixed(2),
            'pace': formatSeconds(lapSecs),
          },
        ];
        lastDistanceMeters = lapMeters;
      }
    } else {
      final List<int> lanes = [];
      final seen = <int>{};
      if (fieldhouseLane >= 1 && fieldhouseLane <= 6) {
        lanes.add(fieldhouseLane);
        seen.add(fieldhouseLane);
      }
      for (var l = 3; l <= 6; l++) {
        if (!seen.contains(l)) {
          lanes.add(l);
          seen.add(l);
        }
      }

      double? firstLapMeters;
      for (final l in lanes) {
        double metersForLane;
        try {
          metersForLane = lapMetersForLane(l, laneMap: defaultLaneLapMeters);
        } catch (e) {
          continue;
        }
        final lapSecs = computeLapPaceSeconds(paceSec, paceUnit, metersForLane);
        if (lapSecs == null) continue;
        firstLapMeters ??= metersForLane;
        fieldhouseResults.add({
          'lane': l.toString(),
          'label': 'Lane $l',
          'meters': metersForLane.toStringAsFixed(2),
          'pace': formatSeconds(lapSecs),
        });
      }
      if (fieldhouseResults.isNotEmpty) {
        lastDistanceMeters = firstLapMeters;
      }
    }
  }

  if (parsedDist != null && parsedDist > 0) {
    double distanceMeters;
    switch (distanceUnit) {
      case DistanceUnit.meters:
        distanceMeters = parsedDist;
        break;
      case DistanceUnit.kilometers:
        distanceMeters = parsedDist * 1000.0;
        break;
      case DistanceUnit.miles:
        distanceMeters = parsedDist * 1609.344;
        break;
    }

    final exactLaps = distanceMeters / lapMeters;
    final roundsUp = exactLaps.ceil();

    lapsResult = {
      'exact': exactLaps.toStringAsFixed(2),
      'roundsUp': roundsUp.toString(),
      'roundsUpMeters': (roundsUp * lapMeters).toStringAsFixed(2),
      'lapMeters': lapMeters.toStringAsFixed(2),
    };

    lastDistanceMeters = distanceMeters;
  }

  return (
    fieldhouseResults.isEmpty && lapsResult.isEmpty
        ? {'error': fieldhouseResults}
        : {'results': fieldhouseResults},
    lapsResult,
    lastDistanceMeters,
  );
}
