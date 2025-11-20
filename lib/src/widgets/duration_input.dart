import 'package:flutter/material.dart';
import '../utils/input_formatters.dart';
import 'duration_picker.dart';
import '../utils/time_utils.dart';

/// Reusable duration text input with optional duration picker.
class DurationInput extends StatelessWidget {
  const DurationInput({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final String hint;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(label),
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, child) {
            return TextFormField(
              controller: controller,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                hintText: hint,
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (value.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => controller.clear(),
                      ),
                    IconButton(
                      tooltip: 'Pick duration',
                      icon: const Icon(Icons.timer),
                      onPressed: () async {
                        final picked = await showDurationPicker(context);
                        if (picked != null) {
                          controller.text = formatSeconds(picked);
                        }
                      },
                    ),
                  ],
                ),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [TimeInputFormatter()],
              validator: validator,
            );
          },
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}
