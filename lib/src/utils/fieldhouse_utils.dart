import '../models/enums.dart';
import 'time_utils.dart';
// conversions.dart is not needed currently but kept for future use
// import 'conversions.dart';

/// Default conservative lane lap lengths (meters) for lanes 1..6.
const Map<int, double> defaultLaneLapMeters = {
  1: 202,
  2: 208,
  3: 214,
  4: 220,
  5: 226,
  6: 232,
};

/// Compute lap meters for a given lane using either the provided map or a
/// geometric formula (increase by 2π*laneWidth per lane).
double lapMetersForLane(
  int lane, {
  Map<int, double>? laneMap,
  double laneWidth = 1.0,
}) {
  // Prefer an explicit lane map if provided.
  if (laneMap != null && laneMap.containsKey(lane)) return laneMap[lane]!;

  // Use the canonical defaults for lanes 1..6. If the lane isn't present,
  // treat it as an invalid/unsupported lane rather than computing a geometric
  // approximation.
  if (defaultLaneLapMeters.containsKey(lane)) {
    return defaultLaneLapMeters[lane]!;
  }

  throw ArgumentError.value(
    lane,
    'lane',
    'Unknown lane — no default distance available',
  );
}

/// Compute lap pace seconds given a pace expressed in seconds per unit
/// (per km or per mile) and a lap length in meters.
int? computeLapPaceSeconds(
  int paceSecondsPerUnit,
  PaceUnit unit,
  double lapMeters,
) {
  if (paceSecondsPerUnit <= 0) return null;
  if (lapMeters <= 0) return null;

  double lapDistanceInUnit;
  if (unit == PaceUnit.perKm) {
    lapDistanceInUnit = lapMeters / 1000.0;
  } else {
    lapDistanceInUnit = lapMeters / 1609.344;
  }

  final lapPace = paceSecondsPerUnit * lapDistanceInUnit;
  return lapPace <= 0 ? null : lapPace.round();
}

/// High-level helper: parse pace string, compute lap pace formatted or return null
String? computeLapPaceFormatted(
  String paceString,
  PaceUnit unit,
  double lapMeters,
) {
  final paceSec = parseTimeToSeconds(paceString);
  if (paceSec == null) return null;
  final secs = computeLapPaceSeconds(paceSec, unit, lapMeters);
  if (secs == null) return null;
  return formatSeconds(secs);
}
