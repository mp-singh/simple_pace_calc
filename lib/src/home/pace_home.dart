import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../utils/input_formatters.dart';
import '../utils/conversions.dart';
import '../utils/time_utils.dart';
import '../models/enums.dart';
import '../widgets/duration_picker.dart';

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

  String _distanceUnitLabel(DistanceUnit u) {
    switch (u) {
      case DistanceUnit.meters:
        return 'Meters';
      case DistanceUnit.kilometers:
        return 'Kilometers';
      case DistanceUnit.miles:
        return 'Miles';
    }
  }

  String _paceUnitLabel(PaceUnit p) {
    switch (p) {
      case PaceUnit.perKm:
        return 'per km';
      case PaceUnit.perMile:
        return 'per mile';
    }
  }

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
            Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModeSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Pace'),
          selected: _mode == CalcMode.pace,
          onSelected: (_) => _switchMode(CalcMode.pace),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Time'),
          selected: _mode == CalcMode.time,
          onSelected: (_) => _switchMode(CalcMode.time),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Distance'),
          selected: _mode == CalcMode.distance,
          onSelected: (_) => _switchMode(CalcMode.distance),
        ),
      ],
    );
  }

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
              _buildModeSelector(),
              const SizedBox(height: 16),

              // inputs
              if (_mode != CalcMode.time) ...[
                const Text('Time (hh:mm:ss or mm:ss)'),
                const SizedBox(height: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _timeController,
                  builder: (context, value, child) {
                    return TextFormField(
                      controller: _timeController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'e.g. 00:04:46',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (value.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _timeController.clear(),
                              ),
                            IconButton(
                              tooltip: 'Pick duration',
                              icon: const Icon(Icons.timer),
                              onPressed: () async {
                                final picked = await showDurationPicker(
                                  context,
                                );
                                if (picked != null) {
                                  _timeController.text = formatSeconds(picked);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [TimeInputFormatter()],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter time';
                        if (parseTimeToSeconds(v) == null) {
                          return 'Invalid time';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],

              if (_mode != CalcMode.pace) ...[
                const Text('Pace (mm:ss)'),
                const SizedBox(height: 8),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _paceController,
                  builder: (context, value, child) {
                    return TextFormField(
                      controller: _paceController,
                      decoration: InputDecoration(
                        border: const OutlineInputBorder(),
                        hintText: 'e.g. 05:00',
                        suffixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (value.text.isNotEmpty)
                              IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => _paceController.clear(),
                              ),
                            IconButton(
                              tooltip: 'Pick pace',
                              icon: const Icon(Icons.timer),
                              onPressed: () async {
                                final picked = await showDurationPicker(
                                  context,
                                );
                                if (picked != null) {
                                  _paceController.text = formatSeconds(picked);
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [TimeInputFormatter()],
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Enter pace';
                        if (parseTimeToSeconds(v) == null) {
                          return 'Invalid pace';
                        }
                        return null;
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
              ],

              if (_mode != CalcMode.distance) ...[
                const Text('Distance'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: ValueListenableBuilder<TextEditingValue>(
                        valueListenable: _distanceController,
                        builder: (context, value, child) {
                          return TextFormField(
                            controller: _distanceController,
                            decoration: InputDecoration(
                              border: const OutlineInputBorder(),
                              hintText: 'e.g. 232',
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (value.text.isNotEmpty)
                                    IconButton(
                                      icon: const Icon(Icons.clear),
                                      onPressed: () =>
                                          _distanceController.clear(),
                                    ),
                                ],
                              ),
                            ),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[0-9.,]'),
                              ),
                            ],
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Enter distance';
                              }
                              final d = double.tryParse(v.replaceAll(',', ''));
                              if (d == null || d <= 0) {
                                return 'Invalid distance';
                              }
                              return null;
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    DropdownButton<DistanceUnit>(
                      value: _distanceUnit,
                      onChanged: (v) => setState(() => _distanceUnit = v!),
                      items: const [
                        DropdownMenuItem(
                          value: DistanceUnit.meters,
                          child: Text('Meters'),
                        ),
                        DropdownMenuItem(
                          value: DistanceUnit.kilometers,
                          child: Text('Kilometers'),
                        ),
                        DropdownMenuItem(
                          value: DistanceUnit.miles,
                          child: Text('Miles'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],

              // pace unit selector
              Row(
                children: [
                  const Text('Pace unit:'),
                  const SizedBox(width: 12),
                  ChoiceChip(
                    label: const Text('per km'),
                    selected: _paceUnit == PaceUnit.perKm,
                    onSelected: (_) =>
                        setState(() => _paceUnit = PaceUnit.perKm),
                  ),
                  const SizedBox(width: 8),
                  ChoiceChip(
                    label: const Text('per mile'),
                    selected: _paceUnit == PaceUnit.perMile,
                    onSelected: (_) =>
                        setState(() => _paceUnit = PaceUnit.perMile),
                  ),
                ],
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
              Text(
                'Selected: ${_distanceUnitLabel(_distanceUnit)} • ${_paceUnitLabel(_paceUnit)}',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 8),
              if (_lastDistanceMeters != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildConversionCard(
                        context,
                        'Meters',
                        _lastDistanceMeters!.toStringAsFixed(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildConversionCard(
                        context,
                        'Kilometers',
                        (_lastDistanceMeters! / 1000.0).toStringAsFixed(3),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildConversionCard(
                        context,
                        'Miles',
                        (_lastDistanceMeters! / 1609.344).toStringAsFixed(3),
                      ),
                    ),
                  ],
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
