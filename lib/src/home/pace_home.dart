import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/conversions.dart';
import '../utils/time_utils.dart';
import '../models/enums.dart';
// labels util intentionally available if needed; keep for consistency
// duration picker used by DurationInput
import '../widgets/mode_selector.dart';
import '../widgets/pace_unit_selector.dart';
import '../widgets/distance_input.dart';
import '../widgets/duration_input.dart';

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
  CalcMode _mode = CalcMode.pace;
  DistanceUnit _distanceUnit = DistanceUnit.meters;
  PaceUnit _paceUnit = PaceUnit.perKm;

  final TextEditingController _timeController = TextEditingController();
  final TextEditingController _distanceController = TextEditingController();
  final TextEditingController _paceController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String _result = '';
  double? _lastDistanceMeters;
  // cache inputs per mode so each mode remembers its own values
  final Map<CalcMode, Map<String, String>> _modeCache = {
    CalcMode.pace: {},
    CalcMode.time: {},
    CalcMode.distance: {},
  };

  @override
  void dispose() {
    _timeController.dispose();
    _distanceController.dispose();
    _paceController.dispose();
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
      // For non-distance results clear the last distance cache
      _lastDistanceMeters = null;
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
      'distanceUnit': _distanceUnit.index.toString(),
      'paceUnit': _paceUnit.index.toString(),
    };

    // restore inputs for the new mode (if any)
    final saved = _modeCache[newMode] ?? {};
    _timeController.text = saved['time'] ?? '';
    _paceController.text = saved['pace'] ?? '';
    _distanceController.text = saved['distance'] ?? '';
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

              // inputs (delegated to widget components)
              if (_mode != CalcMode.time)
                DurationInput(
                  controller: _timeController,
                  label: 'Time (hh:mm:ss or mm:ss)',
                  hint: 'e.g. 00:04:46',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter time';
                    if (parseTimeToSeconds(v) == null) return 'Invalid time';
                    return null;
                  },
                ),
              if (_mode != CalcMode.pace)
                DurationInput(
                  controller: _paceController,
                  label: 'Pace (mm:ss)',
                  hint: 'e.g. 05:00',
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter pace';
                    if (parseTimeToSeconds(v) == null) return 'Invalid pace';
                    return null;
                  },
                ),
              if (_mode != CalcMode.distance)
                DistanceInput(
                  controller: _distanceController,
                  unit: _distanceUnit,
                  onUnitChanged: (u) => setState(() => _distanceUnit = u),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Enter distance';
                    final d = double.tryParse(v.replaceAll(',', ''));
                    if (d == null || d <= 0) return 'Invalid distance';
                    return null;
                  },
                ),

              // pace unit selector
              PaceUnitSelector(
                paceUnit: _paceUnit,
                onChanged: (p) => setState(() => _paceUnit = p),
              ),

              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _calculate,
                child: const Text('Calculate'),
              ),

              const SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    _result.isEmpty ? 'Result will appear here' : _result,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              if (_lastDistanceMeters != null) ...[
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
