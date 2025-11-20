import 'package:flutter/material.dart';

import '../utils/fieldhouse_utils.dart';

/// A simple lane selector for Fieldhouse mode (lanes 1..6).
class FieldhouseLaneSelector extends StatelessWidget {
  const FieldhouseLaneSelector({
    super.key,
    required this.lane,
    required this.onChanged,
    this.enabled = true,
  });

  final int lane;
  final ValueChanged<int> onChanged;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Lane'),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>(
          initialValue: lane,
          onChanged: enabled
              ? (v) {
                  if (v != null) onChanged(v);
                }
              : null,
          items: List.generate(6, (i) {
            final laneIndex = i + 1;
            final meters = lapMetersForLane(laneIndex);
            return DropdownMenuItem(
              value: laneIndex,
              child: Text('Lane $laneIndex — ${meters.toStringAsFixed(2)} m'),
            );
          }),
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 12,
              horizontal: 12,
            ),
            filled: true,
            fillColor: Theme.of(context).inputDecorationTheme.fillColor,
          ),
        ),
        // distance preview removed from below the dropdown (now shown inline in items)
      ],
    );
  }
}
