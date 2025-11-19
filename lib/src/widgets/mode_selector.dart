import 'package:flutter/material.dart';
import '../models/enums.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key, required this.mode, required this.onChanged});

  final CalcMode mode;
  final ValueChanged<CalcMode> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ChoiceChip(
          label: const Text('Pace'),
          selected: mode == CalcMode.pace,
          onSelected: (_) => onChanged(CalcMode.pace),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Time'),
          selected: mode == CalcMode.time,
          onSelected: (_) => onChanged(CalcMode.time),
        ),
        const SizedBox(width: 8),
        ChoiceChip(
          label: const Text('Distance'),
          selected: mode == CalcMode.distance,
          onSelected: (_) => onChanged(CalcMode.distance),
        ),
      ],
    );
  }
}
