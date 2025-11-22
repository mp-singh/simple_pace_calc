import 'package:flutter/material.dart';
import '../../widgets/duration_input.dart';
import '../../widgets/distance_input.dart';
import '../../widgets/pace_unit_selector.dart';
import '../../widgets/fieldhouse_lane_selector.dart';
import '../../models/enums.dart';

class TrackModeWidget extends StatelessWidget {
  const TrackModeWidget({
    super.key,
    required this.paceController,
    required this.paceValidator,
    required this.paceUnit,
    required this.onPaceUnitChanged,
    required this.fieldhouseLane,
    required this.useCustomLap,
    required this.onFieldhouseLaneChanged,
    required this.onUseCustomLapChanged,
    required this.fieldhouseCustomController,
    required this.distanceController,
    required this.distanceUnit,
    required this.onDistanceUnitChanged,
    required this.distanceValidator,
    required this.customLapValidator,
  });

  final TextEditingController paceController;
  final String? Function(String?) paceValidator;
  final PaceUnit paceUnit;
  final ValueChanged<PaceUnit> onPaceUnitChanged;
  final int fieldhouseLane;
  final bool useCustomLap;
  final ValueChanged<int> onFieldhouseLaneChanged;
  final ValueChanged<bool> onUseCustomLapChanged;
  final TextEditingController fieldhouseCustomController;
  final TextEditingController distanceController;
  final DistanceUnit distanceUnit;
  final ValueChanged<DistanceUnit> onDistanceUnitChanged;
  final String? Function(String?) distanceValidator;
  final String? Function(String?) customLapValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DurationInput(
          controller: paceController,
          label: 'Pace (mm:ss)',
          hint: 'e.g. 05:00',
          validator: paceValidator,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: PaceUnitSelector(
            paceUnit: paceUnit,
            onChanged: onPaceUnitChanged,
          ),
        ),
        const SizedBox(height: 8),
        FieldhouseLaneSelector(
          lane: fieldhouseLane,
          enabled: !useCustomLap,
          onChanged: (l) => onFieldhouseLaneChanged(l),
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Use custom lap length'),
          value: useCustomLap,
          onChanged: (v) => onUseCustomLapChanged(v),
        ),
        TextFormField(
          enabled: useCustomLap,
          controller: fieldhouseCustomController,
          decoration: InputDecoration(
            labelText: 'Custom lap length (m)',
            hintText: 'e.g. 206.28',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          ),
          validator: customLapValidator,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
        ),
        const SizedBox(height: 8),
        DistanceInput(
          controller: distanceController,
          unit: distanceUnit,
          onUnitChanged: onDistanceUnitChanged,
          validator: distanceValidator,
        ),
      ],
    );
  }
}
