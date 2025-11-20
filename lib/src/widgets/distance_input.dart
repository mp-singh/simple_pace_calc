import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/enums.dart';

/// A reusable distance input with a numerical text field and unit selector.
class DistanceInput extends StatelessWidget {
  const DistanceInput({
    super.key,
    required this.controller,
    required this.unit,
    required this.onUnitChanged,
    this.validator,
    this.autovalidateMode,
  });

  final TextEditingController controller;
  final DistanceUnit unit;
  final ValueChanged<DistanceUnit> onUnitChanged;
  final String? Function(String?)? validator;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Distance'),
              const SizedBox(height: 8),
              ValueListenableBuilder<TextEditingValue>(
                valueListenable: controller,
                builder: (context, value, child) {
                  return TextFormField(
                    controller: controller,
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      hintText: 'e.g. 232',
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (value.text.isNotEmpty)
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => controller.clear(),
                            ),
                        ],
                      ),
                    ),
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                    ],
                    validator: validator,
                    autovalidateMode: autovalidateMode,
                  );
                },
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
        const SizedBox(width: 8),
        // keep the dropdown at the right and let the input expand to fill space
        Padding(
          padding: const EdgeInsets.only(top: 28.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: DropdownButtonFormField<DistanceUnit>(
              initialValue: unit,
              onChanged: (v) {
                if (v != null) onUnitChanged(v);
              },
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).inputDecorationTheme.fillColor,
              ),
              isDense: true,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: DistanceUnit.meters,
                  child: Text('Meters'),
                ),
                DropdownMenuItem(
                  value: DistanceUnit.kilometers,
                  child: Text('Kilometers'),
                ),
                DropdownMenuItem(
                  value: DistanceUnit.miles,
                  child: Text('Miles'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
