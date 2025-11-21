import '../models/enums.dart';

/// Utility for managing mode-specific input caching.

class ModeCache {
  final Map<CalcMode, Map<String, String>> _cache = {
    CalcMode.pace: {},
    CalcMode.time: {},
    CalcMode.distance: {},
    CalcMode.track: {},
  };

  void saveMode(
    CalcMode mode, {
    required String time,
    required String pace,
    required String distance,
    required int fieldhouseLane,
    required String fieldhouseCustom,
    required bool fieldhouseUseCustom,
    required DistanceUnit distanceUnit,
    required PaceUnit paceUnit,
  }) {
    _cache[mode] = {
      'time': time,
      'pace': pace,
      'distance': distance,
      'fieldhouseLane': fieldhouseLane.toString(),
      'fieldhouseCustom': fieldhouseCustom,
      'fieldhouseUseCustom': fieldhouseUseCustom.toString(),
      'distanceUnit': distanceUnit.index.toString(),
      'paceUnit': paceUnit.index.toString(),
    };
  }

  Map<String, String> loadMode(CalcMode mode) => _cache[mode] ?? {};

  void clearAll() {
    for (final k in _cache.keys.toList()) {
      _cache[k] = {};
    }
  }

  void save(CalcMode mode, Map<String, String> data) {
    _cache[mode] = Map.from(data);
  }

  Map<String, String> load(CalcMode mode) => _cache[mode] ?? {};
}
