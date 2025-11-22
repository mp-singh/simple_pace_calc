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
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(
                            context,
                          ).colorScheme.outline.withValues(alpha: 0.3),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.primary,
                          width: 2,
                        ),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 1.5,
                        ),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: Theme.of(context).colorScheme.error,
                          width: 2,
                        ),
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surface,
                      hintText: 'e.g. 232',
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (value.text.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                              onPressed: () => controller.clear(),
                              tooltip: 'Clear',
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
                  vertical: 15.5,
                  horizontal: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 2,
                  ),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surface,
              ),
              isDense: true,
              isExpanded: true,
              icon: Icon(
                Icons.expand_more,
                color: Theme.of(
                  context,
                ).colorScheme.onSurface.withValues(alpha: 0.6),
              ),
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
