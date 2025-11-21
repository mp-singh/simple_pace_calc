import 'package:flutter/material.dart';
import '../../widgets/duration_input.dart';
import '../../widgets/distance_input.dart';
import '../../widgets/pace_unit_selector.dart';
import '../../models/enums.dart';

class PaceModeWidget extends StatelessWidget {
  const PaceModeWidget({
    super.key,
    required this.timeController,
    required this.distanceController,
    required this.distanceUnit,
    required this.onDistanceUnitChanged,
    required this.paceUnit,
    required this.onPaceUnitChanged,
    required this.timeValidator,
    required this.distanceValidator,
  });

  final TextEditingController timeController;
  final TextEditingController distanceController;
  final DistanceUnit distanceUnit;
  final ValueChanged<DistanceUnit> onDistanceUnitChanged;
  final PaceUnit paceUnit;
  final ValueChanged<PaceUnit> onPaceUnitChanged;
  final String? Function(String?) timeValidator;
  final String? Function(String?) distanceValidator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DurationInput(
          controller: timeController,
          label: 'Time (hh:mm:ss or mm:ss)',
          hint: 'e.g. 00:04:46',
          validator: timeValidator,
        ),
        DistanceInput(
          controller: distanceController,
          unit: distanceUnit,
          onUnitChanged: onDistanceUnitChanged,
          validator: distanceValidator,
        ),
        const SizedBox(height: 8),
        PaceUnitSelector(paceUnit: paceUnit, onChanged: onPaceUnitChanged),
      ],
    );
  }
}
