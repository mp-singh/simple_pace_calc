import '../utils/time_utils.dart';

/// Common validators for form inputs.

String? validateTime(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter time';
  if (parseTimeToSeconds(value) == null) return 'Invalid time';
  return null;
}

String? validatePace(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter pace';
  if (parseTimeToSeconds(value) == null) return 'Invalid pace';
  return null;
}

String? validatePaceOptional(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  if (parseTimeToSeconds(value) == null) return 'Invalid pace';
  return null;
}

String? validateDistance(String? value) {
  if (value == null || value.trim().isEmpty) return 'Enter distance';
  final d = double.tryParse(value.replaceAll(',', ''));
  if (d == null || d <= 0) return 'Invalid distance';
  return null;
}

String? validateDistanceOptional(String? value) {
  if (value == null || value.trim().isEmpty) return null;
  final d = double.tryParse(value.replaceAll(',', ''));
  if (d == null || d <= 0) return 'Invalid distance';
  return null;
}
