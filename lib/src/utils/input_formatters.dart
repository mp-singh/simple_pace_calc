import 'package:flutter/services.dart';

/// Formats a duration-like input automatically inserting colons.
///
/// Behavior: keeps only digits and formats as:
/// - ss -> "ss"
/// - mss or mmss -> "m:ss" / "mm:ss"
/// - hmmss or hhmmss -> "h:mm:ss" / "hh:mm:ss"
class TimeInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');

    // last 2 are seconds
    final sec = digits.length >= 2
        ? digits.substring(digits.length - 2)
        : digits;
    final rest = digits.length > 2
        ? digits.substring(0, digits.length - 2)
        : '';

    String result;
    if (rest.isEmpty) {
      result = sec; // ss
    } else if (rest.length <= 2) {
      // minutes + seconds -> m:ss or mm:ss
      result = '$rest:${sec.padLeft(2, '0')}';
    } else {
      // hours exist: hours + minutes + seconds
      final hours = rest.substring(0, rest.length - 2);
      final minutes = rest.substring(rest.length - 2);
      result = '$hours:${minutes.padLeft(2, '0')}:${sec.padLeft(2, '0')}';
    }

    // Position the caret at end
    return TextEditingValue(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
