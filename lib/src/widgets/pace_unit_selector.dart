import 'package:flutter/material.dart';
import '../models/enums.dart';

class PaceUnitSelector extends StatelessWidget {
  const PaceUnitSelector({
    super.key,
    required this.paceUnit,
    required this.onChanged,
  });

  final PaceUnit paceUnit;
  final ValueChanged<PaceUnit> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('Pace unit:'),
        const SizedBox(width: 12),
        ChoiceChip(
          label: const Text('per km'),
          selected: paceUnit == PaceUnit.perKm,
          onSelected: (_) => onChanged(PaceUnit.perKm),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('per mile'),
          selected: paceUnit == PaceUnit.perMile,
          onSelected: (_) => onChanged(PaceUnit.perMile),
        ),
      ],
    );
  }
}
