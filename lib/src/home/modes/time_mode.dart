import 'package:flutter/material.dart';
import '../../widgets/duration_input.dart';
import '../../widgets/distance_input.dart';
import '../../widgets/pace_unit_selector.dart';
import '../../models/enums.dart';

class TimeModeWidget extends StatelessWidget {
  const TimeModeWidget({
    super.key,
    required this.paceController,
    required this.distanceController,
    required this.distanceUnit,
    required this.onDistanceUnitChanged,
    required this.paceValidator,
    required this.distanceValidator,
    required this.paceUnit,
    required this.onPaceUnitChanged,
  });

  final TextEditingController paceController;
  final TextEditingController distanceController;
  final DistanceUnit distanceUnit;
  final ValueChanged<DistanceUnit> onDistanceUnitChanged;
  final String? Function(String?) paceValidator;
  final String? Function(String?) distanceValidator;
  final PaceUnit paceUnit;
  final ValueChanged<PaceUnit> onPaceUnitChanged;

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
        DistanceInput(
          controller: distanceController,
          unit: distanceUnit,
          onUnitChanged: onDistanceUnitChanged,
          validator: distanceValidator,
        ),
        const SizedBox(height: 8),
        // pace unit selector is useful here too
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: PaceUnitSelector(
            paceUnit: paceUnit,
            onChanged: onPaceUnitChanged,
          ),
        ),
      ],
    );
  }
}
