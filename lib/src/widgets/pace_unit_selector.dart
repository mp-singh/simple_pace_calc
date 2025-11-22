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
    return Wrap(
      spacing: 8,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          'Pace unit:',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withValues(alpha: 0.8),
          ),
        ),
        ChoiceChip(
          label: const Text('per km'),
          selected: paceUnit == PaceUnit.perKm,
          onSelected: (_) => onChanged(PaceUnit.perKm),
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
          labelStyle: TextStyle(
            color: paceUnit == PaceUnit.perKm
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: paceUnit == PaceUnit.perKm
                  ? Colors.transparent
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
        ChoiceChip(
          label: const Text('per mile'),
          selected: paceUnit == PaceUnit.perMile,
          onSelected: (_) => onChanged(PaceUnit.perMile),
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
          labelStyle: TextStyle(
            color: paceUnit == PaceUnit.perMile
                ? Theme.of(context).colorScheme.onPrimaryContainer
                : Theme.of(context).colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(
              color: paceUnit == PaceUnit.perMile
                  ? Colors.transparent
                  : Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
            ),
          ),
        ),
      ],
    );
  }
}
