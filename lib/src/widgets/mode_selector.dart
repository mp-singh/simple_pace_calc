import 'package:flutter/material.dart';
import '../models/enums.dart';

class ModeSelector extends StatelessWidget {
  const ModeSelector({super.key, required this.mode, required this.onChanged});

  final CalcMode mode;
  final ValueChanged<CalcMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedColor = theme.colorScheme.primary;
    final unselectedColor = theme.colorScheme.surface;

    Widget chip(String label, CalcMode value) {
      final selected = mode == value;
      return ChoiceChip(
        avatar: selected
            ? Icon(
                Icons.check_circle,
                color: Colors.green, // use green for clear UX
                size: 20,
              )
            : null,
        label: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? theme.colorScheme.onPrimary : null,
            fontSize: 14,
          ),
        ),
        selected: selected,
        onSelected: (_) => onChanged(value),
        backgroundColor: unselectedColor,
        selectedColor: selectedColor,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? Colors.transparent : theme.dividerColor,
          ),
        ),
      );
    }

    return Center(
      child: Wrap(
        spacing: 8,
        runSpacing: 6,
        alignment: WrapAlignment.center,
        children: [
          // Track (merged Fieldhouse + Laps) first per request
          chip('Track', CalcMode.track),
          chip('Pace', CalcMode.pace),
          chip('Time', CalcMode.time),
          chip('Distance', CalcMode.distance),
        ],
      ),
    );
  }
}
