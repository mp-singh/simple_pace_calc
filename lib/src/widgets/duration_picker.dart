import 'package:flutter/material.dart';

/// Shows a duration picker dialog and returns total seconds or null if cancelled.
Future<int?> showDurationPicker(BuildContext context) {
  int hours = 0;
  int minutes = 0;
  int seconds = 0;

  return showDialog<int>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Pick duration'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hours
                    Column(
                      children: [
                        const Text('H'),
                        DropdownButton<int>(
                          value: hours,
                          items: List.generate(11, (i) => i)
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text('$v'),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => hours = v ?? 0),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Minutes
                    Column(
                      children: [
                        const Text('M'),
                        DropdownButton<int>(
                          value: minutes,
                          items: List.generate(60, (i) => i)
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v.toString().padLeft(2, '0')),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => minutes = v ?? 0),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // Seconds
                    Column(
                      children: [
                        const Text('S'),
                        DropdownButton<int>(
                          value: seconds,
                          items: List.generate(60, (i) => i)
                              .map(
                                (v) => DropdownMenuItem(
                                  value: v,
                                  child: Text(v.toString().padLeft(2, '0')),
                                ),
                              )
                              .toList(),
                          onChanged: (v) => setState(() => seconds = v ?? 0),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).pop(hours * 3600 + minutes * 60 + seconds),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}
