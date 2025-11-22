import 'package:flutter/material.dart';
import '../utils/time_utils.dart';
import '../utils/fieldhouse_utils.dart';
import '../utils/validators.dart';
import '../utils/calculations.dart';
import '../utils/mode_cache.dart';
import '../models/enums.dart';
// labels util intentionally available if needed; keep for consistency
// duration picker used by DurationInput
import '../widgets/mode_selector.dart';
import '../widgets/result_display.dart';
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
  DistanceUnit _distanceUnit = DistanceUnit.kilometers;
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
  final ModeCache _modeCache = ModeCache();

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
        // Clear results when validation fails
        _fieldhouseResults.clear();
        _lapsResult.clear();
        _lastDistanceMeters = null;
        return;
      }

      final timeText = _timeController.text.trim();
      final paceText = _paceController.text.trim();
      final distanceText = _distanceController.text.trim();

      if (_mode == CalcMode.pace) {
        _result = calculatePace(
          timeText: timeText,
          distanceText: distanceText,
          distanceUnit: _distanceUnit,
          paceUnit: _paceUnit,
        );
        return;
      }

      if (_mode == CalcMode.time) {
        _result = calculateTime(
          paceText: paceText,
          distanceText: distanceText,
          distanceUnit: _distanceUnit,
          paceUnit: _paceUnit,
        );
        return;
      }

      if (_mode == CalcMode.distance) {
        final (result, lastDist) = calculateDistance(
          timeText: timeText,
          paceText: paceText,
          distanceUnit: _distanceUnit,
          paceUnit: _paceUnit,
        );
        _result = result;
        _lastDistanceMeters = lastDist;
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
            // Validation will handle this
            _fieldhouseResults.clear();
            _lapsResult.clear();
            return;
          }
          final parsed = double.tryParse(custom.replaceAll(',', ''));
          if (parsed == null || parsed <= 0) {
            // Validation will handle this
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
            // This shouldn't happen with valid lane
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
            // Non-custom: show all lanes with selected first
            final List<int> allLanes = [1, 2, 3, 4, 5, 6];
            final List<int> lanes = [
              _fieldhouseLane,
              ...allLanes.where((l) => l != _fieldhouseLane),
            ];

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
          // Validation will handle this
          _fieldhouseResults.clear();
          _lapsResult.clear();
          _result = 'Enter a pace or distance to calculate';
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
      _modeCache.clearAll();

      // Reset custom lap toggle but keep current mode and lane selection
      _useCustomLap = false;
    });
  }

  String? _validateCustomLap(String? value) {
    if (_useCustomLap) {
      if (value == null || value.trim().isEmpty) {
        return 'Custom lap length is required';
      }
      final parsed = double.tryParse(value.replaceAll(',', ''));
      if (parsed == null || parsed <= 0) {
        return 'Invalid custom lap length';
      }
    }
    return null;
  }

  // moved label helpers to `lib/src/utils/labels.dart`

  // Mode selector is provided by `ModeSelector` widget.

  void _switchMode(CalcMode newMode) {
    if (newMode == _mode) return;
    // save current inputs for the existing mode
    _modeCache.save(_mode, {
      'time': _timeController.text,
      'pace': _paceController.text,
      'distance': _distanceController.text,
      'fieldhouseLane': _fieldhouseLane.toString(),
      'fieldhouseCustom': _fieldhouseCustomController.text,
      'fieldhouseUseCustom': _useCustomLap.toString(),
      'distanceUnit': _distanceUnit.index.toString(),
      'paceUnit': _paceUnit.index.toString(),
    });

    // restore inputs for the new mode (if any)
    final saved = _modeCache.load(newMode);
    // Clear any lingering validation errors when switching modes so hidden
    // fields do not keep showing errors after a mode change.
    _formKey.currentState?.reset();
    _timeController.text = saved['time'] ?? '';
    _paceController.text = saved['pace'] ?? '';
    _distanceController.text =
        saved['distance'] ?? ''; // Will be '' since not saved
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

    // Recalculate for Track mode to restore results based on saved inputs
    // if (newMode == CalcMode.track) {
    //   _calculate();
    // }
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
                  timeValidator: validateTime,
                  distanceValidator: validateDistance,
                ),

              if (_mode == CalcMode.time)
                TimeModeWidget(
                  paceController: _paceController,
                  distanceController: _distanceController,
                  distanceUnit: _distanceUnit,
                  onDistanceUnitChanged: (u) =>
                      setState(() => _distanceUnit = u),
                  paceValidator: validatePace,
                  distanceValidator: validateDistance,
                  paceUnit: _paceUnit,
                  onPaceUnitChanged: (p) => setState(() => _paceUnit = p),
                ),

              if (_mode == CalcMode.distance)
                DistanceModeWidget(
                  timeController: _timeController,
                  paceController: _paceController,
                  paceUnit: _paceUnit,
                  onPaceUnitChanged: (p) => setState(() => _paceUnit = p),
                ),

              if (_mode == CalcMode.track)
                TrackModeWidget(
                  paceController: _paceController,
                  paceValidator: validatePaceOptional,
                  paceUnit: _paceUnit,
                  onPaceUnitChanged: (p) => setState(() => _paceUnit = p),
                  fieldhouseLane: _fieldhouseLane,
                  useCustomLap: _useCustomLap,
                  onFieldhouseLaneChanged: (l) => setState(() {
                    _fieldhouseLane = l;
                    _useCustomLap = false;
                  }),
                  onUseCustomLapChanged: (v) => setState(() {
                    _useCustomLap = v;
                    if (!v) {
                      _fieldhouseCustomController.clear();
                      _formKey.currentState?.validate();
                    }
                  }),
                  fieldhouseCustomController: _fieldhouseCustomController,
                  distanceController: _distanceController,
                  distanceUnit: _distanceUnit,
                  onDistanceUnitChanged: (u) =>
                      setState(() => _distanceUnit = u),
                  distanceValidator: validateDistanceOptional,
                  customLapValidator: _validateCustomLap,
                ),

              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _calculate,
                      child: const Text(
                        'Calculate',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                        shadowColor: Theme.of(
                          context,
                        ).colorScheme.shadow.withValues(alpha: 0.2),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAll,
                      child: const Text(
                        'Clear',
                        style: TextStyle(fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.5),
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              Card(
                elevation: 2,
                shadowColor: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: 0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.1),
                          end: Offset.zero,
                        ).animate(animation),
                        child: child,
                      ),
                    ),
                    child: _mode == CalcMode.track
                        ? TrackResultDisplay(
                            key: const ValueKey('track'),
                            fieldhouseResults: _fieldhouseResults,
                            lapsResult: _lapsResult,
                            showMoreLanes: _showMoreLanes,
                            onToggleShowMoreLanes: () => setState(() {
                              _showMoreLanes = !_showMoreLanes;
                            }),
                            useCustomLap: _useCustomLap,
                            fieldhouseLane: _fieldhouseLane,
                            onLaneSelected: (int lane) {
                              setState(() => _fieldhouseLane = lane);
                              _calculate();
                            },
                            errorMessage: _result,
                          )
                        : _mode == CalcMode.distance
                        ? Column(
                            key: const ValueKey('distance'),
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Distance Section Header
                              Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.straighten,
                                      size: 20,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Distance Result',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
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
                                  vertical: 8,
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Calculated distance',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.8),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.15),
                                            Theme.of(context)
                                                .colorScheme
                                                .primary
                                                .withValues(alpha: 0.08),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        _result.isEmpty
                                            ? ''
                                            : _result.replaceFirst(
                                                'Distance: ',
                                                '',
                                              ),
                                        style: TextStyle(
                                          fontFeatures: const [
                                            FontFeature.tabularFigures(),
                                          ],
                                          fontSize: 17,
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.onSurface,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (_lastDistanceMeters != null) ...[
                                const Divider(height: 24),
                                // Conversions Section Header
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.compare_arrows,
                                        size: 18,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .primary
                                            .withValues(alpha: 0.7),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Conversions',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.9),
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
                                          'Kilometers',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${(_lastDistanceMeters! / 1000.0).toStringAsFixed(3)} km',
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
                                          'Miles',
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.8),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        '${(_lastDistanceMeters! / 1609.344).toStringAsFixed(3)} mi',
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
                            ],
                          )
                        : Text(
                            key: const ValueKey('other'),
                            _result.isEmpty
                                ? 'Result will appear here'
                                : _result,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                ),
              ),
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
