import 'package:flutter/material.dart';
import '../../widgets/duration_input.dart';
import '../../widgets/pace_unit_selector.dart';
import '../../models/enums.dart';

class DistanceModeWidget extends StatelessWidget {
  const DistanceModeWidget({
    super.key,
    required this.timeController,
    required this.paceController,
    required this.paceUnit,
    required this.onPaceUnitChanged,
    required this.distanceValidator,
    required this.timeValidator,
  });

  final TextEditingController timeController;
  final TextEditingController paceController;
  final PaceUnit paceUnit;
  final ValueChanged<PaceUnit> onPaceUnitChanged;
  final String? Function(String?) distanceValidator;
  final String? Function(String?) timeValidator;

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
        DurationInput(
          controller: paceController,
          label: 'Pace (mm:ss)',
          hint: 'e.g. 05:00',
          validator: (v) => paceController.text.isEmpty ? 'Enter pace' : null,
        ),
        const SizedBox(height: 8),
        PaceUnitSelector(paceUnit: paceUnit, onChanged: onPaceUnitChanged),
      ],
    );
  }
}
