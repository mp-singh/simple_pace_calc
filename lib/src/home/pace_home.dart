import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/conversions.dart';
import '../utils/time_utils.dart';
import '../utils/fieldhouse_utils.dart';
import '../models/enums.dart';
// labels util intentionally available if needed; keep for consistency
// duration picker used by DurationInput
import '../widgets/mode_selector.dart';
// mode-specific inputs are provided by sub-widgets in `modes/`
// mode sub-widgets
import 'modes/pace_mode.dart';
import 'modes/time_mode.dart';
import 'modes/distance_mode.dart';
import 'modes/track_mode.dart';

class PaceHomePage extends StatefulWidget {
  const PaceHomePage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<PaceHomePage> createState() => _PaceHomePageState();
}

class _PaceHomePageState extends State<PaceHomePage> {
  CalcMode _mode = CalcMode.track;
  DistanceUnit _distanceUnit = DistanceUnit.meters;
  PaceUnit _paceUnit = PaceUnit.perKm;
  // Fieldhouse specific
  int _fieldhouseLane = 1;
  final TextEditingController _fieldhouseCustomController =
      TextEditingController();
  // when true, use the custom lap length value and disable lane selector
  bool _useCustomLap = false;

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _paceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _result = '';
  double? _lastDistanceMeters;
  // structured results for Fieldhouse mode (lane/custom results)
  List<Map<String, String>> _fieldhouseResults = [];
  // structured results for Laps mode
  Map<String, String> _lapsResult = {};
  // whether to show additional lanes (3..6) in the Track results
  bool _showMoreLanes = false;
  // cache inputs per mode so each mode remembers its own values
  final Map<CalcMode, Map<String, String>> _modeCache = {
    CalcMode.pace: {},
    CalcMode.time: {},
    CalcMode.distance: {},
    CalcMode.track: {},
  };

  @override
  void dispose() {
    _timeController.dispose();
    _distanceController.dispose();
    _paceController.dispose();
    _fieldhouseCustomController.dispose();
    super.dispose();
  }

  void _calculate() {
    setState(() {
      _result = '';
      if (!_formKey.currentState!.validate()) {
        _result = 'Fix input errors';
        return;
      }

      final timeText = _timeController.text.trim();
      final paceText = _paceController.text.trim();
      final distanceText = _distanceController.text.trim();

      final distanceVal = double.tryParse(distanceText.replaceAll(',', ''));

      if (_mode == CalcMode.pace) {
        final totalSeconds = parseTimeToSeconds(timeText);
        if (totalSeconds == null || distanceVal == null) {
          _result = 'Enter valid time and distance';
          return;
        }
        double unitDistance;
        if (_paceUnit == PaceUnit.perKm) {
          unitDistance = distanceToKilometers(distanceVal, _distanceUnit);
        } else {
          unitDistance = distanceToMiles(distanceVal, _distanceUnit);
        }
        if (unitDistance <= 0) {
          _result = 'Distance must be > 0';
          return;
        }
        final paceSec = (totalSeconds / unitDistance).round();
        final unitLabel = _paceUnit == PaceUnit.perKm ? 'per km' : 'per mile';
        _result = 'Pace: ${formatSeconds(paceSec)} $unitLabel';
        return;
      }

      if (_mode == CalcMode.time) {
        final paceSec = parseTimeToSeconds(paceText);
        if (paceSec == null || distanceVal == null) {
          _result = 'Enter valid pace and distance';
          return;
        }
        double unitDistance;
        if (_paceUnit == PaceUnit.perKm) {
          unitDistance = distanceToKilometers(distanceVal, _distanceUnit);
        } else {
          unitDistance = distanceToMiles(distanceVal, _distanceUnit);
        }
        if (unitDistance <= 0) {
          _result = 'Distance must be > 0';
          return;
        }
        final totalSec = (paceSec * unitDistance).round();
        _result = 'Time: ${formatSeconds(totalSec)}';
        return;
      }

      if (_mode == CalcMode.distance) {
        final totalSec = parseTimeToSeconds(timeText);
        final paceSec = parseTimeToSeconds(paceText);
        if (totalSec == null || paceSec == null) {
          _result = 'Enter valid time and pace';
          return;
        }
        final distInUnits = totalSec / paceSec;
        String out;
        if (_paceUnit == PaceUnit.perKm) {
          double outValue;
          switch (_distanceUnit) {
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
          // distInUnits is kilometers here -> store meters
          _lastDistanceMeters = distInUnits * 1000.0;
        } else {
          double outValue;
          switch (_distanceUnit) {
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
          // distInUnits is miles here -> store meters
          _lastDistanceMeters = distInUnits * 1609.344;
        }
        _result = 'Distance: $out';
        return;
      }
      if (_mode == CalcMode.track) {
        // Track mode combines Fieldhouse (lap paces per lane) and Laps (laps required)
        final paceSec = parseTimeToSeconds(paceText);
        final distText = _distanceController.text.trim();
        final parsedDist = double.tryParse(distText.replaceAll(',', ''));

        // Determine lap length (custom preferred)
        double lapMeters;
        if (_useCustomLap) {
          final custom = _fieldhouseCustomController.text.trim();
          if (custom.isEmpty) {
            // If neither pace nor distance present, defer validation to later
            if (paceSec == null && (parsedDist == null || parsedDist <= 0)) {
              _result = 'Enter a pace or a distance to calculate';
              _fieldhouseResults.clear();
              _lapsResult.clear();
              return;
            }
            _result = 'Enter custom lap length or disable custom';
            _fieldhouseResults.clear();
            _lapsResult.clear();
            return;
          }
          final parsed = double.tryParse(custom.replaceAll(',', ''));
          if (parsed == null || parsed <= 0) {
            _result = 'Invalid custom lap length';
            _fieldhouseResults.clear();
            _lapsResult.clear();
            return;
          }
          lapMeters = parsed;
        } else {
          try {
            lapMeters = lapMetersForLane(
              _fieldhouseLane,
              laneMap: defaultLaneLapMeters,
            );
          } catch (e) {
            _result = 'Invalid lane';
            _fieldhouseResults.clear();
            _lapsResult.clear();
            return;
          }
        }

        // Compute lap paces if pace provided
        if (paceSec != null) {
          // If custom lap: single result
          if (_useCustomLap) {
            final lapSecs = computeLapPaceSeconds(
              paceSec,
              _paceUnit,
              lapMeters,
            );
            if (lapSecs == null) {
              _result = 'Could not compute lap pace';
              _fieldhouseResults.clear();
              // do not return; allow laps calculation if distance present
            } else {
              _fieldhouseResults = [
                {
                  'lane': 'custom',
                  'label': 'Custom lap',
                  'meters': lapMeters.toStringAsFixed(2),
                  'pace': formatSeconds(lapSecs),
                },
              ];
              _lastDistanceMeters = lapMeters;
            }
          } else {
            // Non-custom: show selected lane first plus lanes 3..6
            final List<int> lanes = [];
            final seen = <int>{};
            if (_fieldhouseLane >= 1 && _fieldhouseLane <= 6) {
              lanes.add(_fieldhouseLane);
              seen.add(_fieldhouseLane);
            }
            for (var l = 3; l <= 6; l++) {
              if (!seen.contains(l)) {
                lanes.add(l);
                seen.add(l);
              }
            }

            final List<Map<String, String>> results = [];
            double? firstLapMeters;
            for (final l in lanes) {
              double metersForLane;
              try {
                metersForLane = lapMetersForLane(
                  l,
                  laneMap: defaultLaneLapMeters,
                );
              } catch (e) {
                continue;
              }
              final lapSecs = computeLapPaceSeconds(
                paceSec,
                _paceUnit,
                metersForLane,
              );
              if (lapSecs == null) continue;
              firstLapMeters ??= metersForLane;
              results.add({
                'lane': l.toString(),
                'label': 'Lane $l',
                'meters': metersForLane.toStringAsFixed(2),
                'pace': formatSeconds(lapSecs),
              });
            }
            if (results.isEmpty) {
              _fieldhouseResults.clear();
              _result = 'Could not compute lap paces';
              // do not return; allow laps calculation if distance present
            } else {
              _lastDistanceMeters = firstLapMeters;
              _fieldhouseResults = results;
              // keep a newline text fallback
              _result = _fieldhouseResults
                  .map((r) => '${r['label']} — ${r['meters']} m: ${r['pace']}')
                  .join('\n');
            }
          }
        } else {
          // no pace entered
          _fieldhouseResults.clear();
        }

        // Compute laps required if distance provided
        if (parsedDist != null && parsedDist > 0) {
          // normalize to meters
          double distanceMeters;
          switch (_distanceUnit) {
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

          _lapsResult = {
            'exact': exactLaps.toStringAsFixed(2),
            'roundsUp': roundsUp.toString(),
            'roundsUpMeters': (roundsUp * lapMeters).toStringAsFixed(2),
            'lapMeters': lapMeters.toStringAsFixed(2),
          };

          // if no textual _result yet, provide a fallback
          if (_result.isEmpty) {
            _result =
                'Laps: ${_lapsResult['exact']}\n'
                'Rounded Up Laps: ${_lapsResult['roundsUp']} laps (${_lapsResult['roundsUpMeters']} m)';
          }

          _lastDistanceMeters = distanceMeters;
        } else {
          _lapsResult.clear();
        }

        if (paceSec == null && (parsedDist == null || parsedDist <= 0)) {
          _result = 'Enter a pace or a distance to calculate';
          _fieldhouseResults.clear();
          _lapsResult.clear();
          return;
        }

        return;
      }
      // For non-distance results clear the last distance cache
      _lastDistanceMeters = null;
    });
  }

  void _clearAll() {
    setState(() {
      // Clear all form inputs
      _timeController.clear();
      _distanceController.clear();
      _paceController.clear();
      _fieldhouseCustomController.clear();

      // Clear computed results and caches
      _result = '';
      _fieldhouseResults.clear();
      _lapsResult.clear();
      _lastDistanceMeters = null;
      _showMoreLanes = false;

      // Clear per-mode caches so switching back won't repopulate fields
      for (final k in _modeCache.keys.toList()) {
        _modeCache[k] = {};
      }

      // Reset custom lap toggle but keep current mode and lane selection
      _useCustomLap = false;
    });
  }

  // moved label helpers to `lib/src/utils/labels.dart`

  Widget _buildConversionCard(
    BuildContext context,
    String label,
    String value,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: Theme.of(context).textTheme.bodySmall),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: Text(
                    value,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'Copy',
                  icon: const Icon(Icons.copy, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Copied to clipboard')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Mode selector is provided by `ModeSelector` widget.

  void _switchMode(CalcMode newMode) {
    if (newMode == _mode) return;
    // save current inputs for the existing mode
    _modeCache[_mode] = {
      'time': _timeController.text,
      'pace': _paceController.text,
      'distance': _distanceController.text,
      'fieldhouseLane': _fieldhouseLane.toString(),
      'fieldhouseCustom': _fieldhouseCustomController.text,
      'fieldhouseUseCustom': _useCustomLap.toString(),
      'distanceUnit': _distanceUnit.index.toString(),
      'paceUnit': _paceUnit.index.toString(),
    };

    // restore inputs for the new mode (if any)
    final saved = _modeCache[newMode] ?? {};
    _timeController.text = saved['time'] ?? '';
    _paceController.text = saved['pace'] ?? '';
    _distanceController.text = saved['distance'] ?? '';
    if (saved.containsKey('fieldhouseLane')) {
      final idx = int.tryParse(saved['fieldhouseLane']!);
      if (idx != null && idx >= 1 && idx <= 6) {
        _fieldhouseLane = idx;
      }
    }
    _fieldhouseCustomController.text = saved['fieldhouseCustom'] ?? '';
    if (saved.containsKey('fieldhouseUseCustom')) {
      _useCustomLap = saved['fieldhouseUseCustom'] == 'true';
    }
    // Clear any lingering validation errors when switching modes so hidden
    // fields do not keep showing errors after a mode change.
    _formKey.currentState?.reset();
    if (saved.containsKey('distanceUnit')) {
      final idx = int.tryParse(saved['distanceUnit']!);
      if (idx != null && idx >= 0 && idx < DistanceUnit.values.length) {
        _distanceUnit = DistanceUnit.values[idx];
      }
    }
    if (saved.containsKey('paceUnit')) {
      final idx = int.tryParse(saved['paceUnit']!);
      if (idx != null && idx >= 0 && idx < PaceUnit.values.length) {
        _paceUnit = PaceUnit.values[idx];
      }
    }

    // clear track-related results when switching away
    if (newMode != CalcMode.track) {
      _fieldhouseResults.clear();
      _lapsResult.clear();
      _showMoreLanes = false;
    }

    // If entering Track mode and no saved distance unit, default to kilometers
    if (newMode == CalcMode.track && !saved.containsKey('distanceUnit')) {
      _distanceUnit = DistanceUnit.kilometers;
    }

    setState(() {
      _mode = newMode;
      // clear transient result when switching modes
      _result = '';
      // only keep _lastDistanceMeters when returning to distance mode
      if (_mode != CalcMode.distance) _lastDistanceMeters = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simple Pace Calculator'),
        actions: [
          IconButton(
            tooltip: 'Toggle theme',
            icon: Icon(widget.isDark ? Icons.dark_mode : Icons.light_mode),
            onPressed: widget.onToggleTheme,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModeSelector(mode: _mode, onChanged: _switchMode),
              const SizedBox(height: 16),

              // Mode-specific inputs moved to their own widgets for clarity
              if (_mode == CalcMode.pace)
                PaceModeWidget(
                  timeController: _timeController,
                  distanceController: _distanceController,
                  distanceUnit: _distanceUnit,
                  onDistanceUnitChanged: (u) =>
                      setState(() => _distanceUnit = u),
                  paceUnit: _paceUnit,
                  onPaceUnitChanged: (p) => setState(() => _paceUnit = p),
                  timeValidator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter time';
                    if (parseTimeToSeconds(v) == null) return 'Invalid time';
                    return null;
                  },
                  distanceValidator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter distance';
                    final d = double.tryParse(v.replaceAll(',', ''));
                    if (d == null || d <= 0) return 'Invalid distance';
                    return null;
                  },
                ),

              if (_mode == CalcMode.time)
                TimeModeWidget(
                  paceController: _paceController,
                  distanceController: _distanceController,
                  distanceUnit: _distanceUnit,
                  onDistanceUnitChanged: (u) =>
                      setState(() => _distanceUnit = u),
                  paceValidator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter pace';
                    if (parseTimeToSeconds(v) == null) return 'Invalid pace';
                    return null;
                  },
                  distanceValidator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter distance';
                    final d = double.tryParse(v.replaceAll(',', ''));
                    if (d == null || d <= 0) return 'Invalid distance';
                    return null;
                  },
                  paceUnit: _paceUnit,
                  onPaceUnitChanged: (p) => setState(() => _paceUnit = p),
                ),

              if (_mode == CalcMode.distance)
                DistanceModeWidget(
                  timeController: _timeController,
                  paceController: _paceController,
                  paceUnit: _paceUnit,
                  onPaceUnitChanged: (p) => setState(() => _paceUnit = p),
                  distanceValidator: (v) {
                    // In Distance mode we don't show a distance input; keep
                    // the validator signature available if needed.
                    return null;
                  },
                  timeValidator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter time';
                    if (parseTimeToSeconds(v) == null) return 'Invalid time';
                    return null;
                  },
                ),

              if (_mode == CalcMode.track)
                TrackModeWidget(
                  paceController: _paceController,
                  paceValidator: (v) {
                    // Track allows empty pace (laps-only)
                    if (v == null || v.trim().isEmpty) return null;
                    if (parseTimeToSeconds(v) == null) return 'Invalid pace';
                    return null;
                  },
                  paceUnit: _paceUnit,
                  onPaceUnitChanged: (p) => setState(() => _paceUnit = p),
                  fieldhouseLane: _fieldhouseLane,
                  useCustomLap: _useCustomLap,
                  onFieldhouseLaneChanged: (l) => setState(() {
                    _fieldhouseLane = l;
                    _useCustomLap = false;
                  }),
                  onUseCustomLapChanged: (v) =>
                      setState(() => _useCustomLap = v),
                  fieldhouseCustomController: _fieldhouseCustomController,
                  distanceController: _distanceController,
                  distanceUnit: _distanceUnit,
                  onDistanceUnitChanged: (u) =>
                      setState(() => _distanceUnit = u),
                  distanceValidator: (v) {
                    if (v == null || v.trim().isEmpty) return null;
                    final d = double.tryParse(v.replaceAll(',', ''));
                    if (d == null || d <= 0) return 'Invalid distance';
                    return null;
                  },
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _calculate,
                      child: const Text('Calculate'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  OutlinedButton(
                    onPressed: _clearAll,
                    child: const Text('Clear'),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: _mode == CalcMode.track
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_fieldhouseResults.isNotEmpty) ...[
                              // Show only the primary (selected/custom) lane row first.
                              Builder(
                                builder: (context) {
                                  final theme = Theme.of(context);
                                  final primary = _fieldhouseResults.first;
                                  final primaryLaneStr = primary['lane'];
                                  final primaryLabel = primary['label'] ?? '';
                                  final primaryMeters = primary['meters'] ?? '';
                                  final primaryPace = primary['pace'] ?? '';
                                  final primarySelected =
                                      !_useCustomLap &&
                                      primaryLaneStr != null &&
                                      int.tryParse(primaryLaneStr) ==
                                          _fieldhouseLane;

                                  Widget primaryRow = Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 6,
                                    ),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '$primaryLabel — $primaryMeters m',
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: primarySelected
                                                  ? FontWeight.w700
                                                  : FontWeight.w500,
                                              color:
                                                  theme.colorScheme.onSurface,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Text(
                                          primaryPace,
                                          style: TextStyle(
                                            fontFeatures: const [
                                              FontFeature.tabularFigures(),
                                            ],
                                            fontSize: 15,
                                            fontWeight: primarySelected
                                                ? FontWeight.w700
                                                : FontWeight.w500,
                                            color: theme.colorScheme.onSurface,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );

                                  // Build secondary rows (lanes 3..6)
                                  final secondary = _fieldhouseResults
                                      .skip(1)
                                      .map((r) {
                                        final laneStr = r['lane'];
                                        final label = r['label'] ?? '';
                                        final meters = r['meters'] ?? '';
                                        final pace = r['pace'] ?? '';
                                        final sel =
                                            !_useCustomLap &&
                                            laneStr != null &&
                                            int.tryParse(laneStr) ==
                                                _fieldhouseLane;
                                        return Padding(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 6,
                                          ),
                                          child: Row(
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  '$label — $meters m',
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    fontWeight: sel
                                                        ? FontWeight.w700
                                                        : FontWeight.w500,
                                                    color: theme
                                                        .colorScheme
                                                        .onSurface,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                pace,
                                                style: TextStyle(
                                                  fontFeatures: const [
                                                    FontFeature.tabularFigures(),
                                                  ],
                                                  fontSize: 15,
                                                  fontWeight: sel
                                                      ? FontWeight.w700
                                                      : FontWeight.w500,
                                                  color: theme
                                                      .colorScheme
                                                      .onSurface,
                                                ),
                                              ),
                                            ],
                                          ),
                                        );
                                      })
                                      .toList();

                                  return Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      primaryRow,
                                      if (_fieldhouseResults.length > 1)
                                        Align(
                                          alignment: Alignment.centerLeft,
                                          child: TextButton.icon(
                                            onPressed: () => setState(() {
                                              _showMoreLanes = !_showMoreLanes;
                                            }),
                                            icon: Icon(
                                              _showMoreLanes
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              size: 18,
                                            ),
                                            label: Text(
                                              _showMoreLanes
                                                  ? 'Show fewer lanes'
                                                  : 'Show more lanes',
                                            ),
                                          ),
                                        ),
                                      if (_showMoreLanes) ...secondary,
                                    ],
                                  );
                                },
                              ),
                            ],
                            if (_lapsResult.isNotEmpty) ...[
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Laps',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      _lapsResult['exact'] ?? '',
                                      style: TextStyle(
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Rounded Up Laps',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${_lapsResult['roundsUp']}',
                                      style: TextStyle(
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Total distance',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      '${_lapsResult['roundsUpMeters']} m',
                                      style: TextStyle(
                                        fontFeatures: const [
                                          FontFeature.tabularFigures(),
                                        ],
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            if (_fieldhouseResults.isEmpty &&
                                _lapsResult.isEmpty)
                              Text(
                                _result.isEmpty
                                    ? 'Result will appear here'
                                    : _result,
                                style: const TextStyle(fontSize: 16),
                              ),
                          ],
                        )
                      : Text(
                          _result.isEmpty ? 'Result will appear here' : _result,
                          style: const TextStyle(fontSize: 16),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              if (_lastDistanceMeters != null && _mode != CalcMode.track) ...[
                const SizedBox(height: 8),
                LayoutBuilder(
                  builder: (context, constraints) {
                    // calculate a reasonable card width based on available space
                    final available = constraints.maxWidth;
                    // when wide, show three cards in a row; otherwise allow wrapping
                    final cardWidth = available > 560
                        ? (available - 16) / 3
                        : (available * 0.9);

                    return Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        SizedBox(
                          width: cardWidth,
                          child: _buildConversionCard(
                            context,
                            'Meters',
                            _lastDistanceMeters!.toStringAsFixed(2),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _buildConversionCard(
                            context,
                            'Kilometers',
                            (_lastDistanceMeters! / 1000.0).toStringAsFixed(3),
                          ),
                        ),
                        SizedBox(
                          width: cardWidth,
                          child: _buildConversionCard(
                            context,
                            'Miles',
                            (_lastDistanceMeters! / 1609.344).toStringAsFixed(
                              3,
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
              const SizedBox(height: 8),
              const Text(
                'Notes: Input formats: time and pace use mm:ss or hh:mm:ss. Distance accepts decimal.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
