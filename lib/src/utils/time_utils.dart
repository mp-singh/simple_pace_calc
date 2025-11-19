int? parseTimeToSeconds(String input) {
  final parts = input
      .split(':')
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();
  try {
    if (parts.isEmpty) return null;
    if (parts.length == 1) return int.parse(parts[0]);
    if (parts.length == 2) {
      final m = int.parse(parts[0]);
      final s = int.parse(parts[1]);
      return m * 60 + s;
    }
    if (parts.length == 3) {
      final h = int.parse(parts[0]);
      final m = int.parse(parts[1]);
      final s = int.parse(parts[2]);
      return h * 3600 + m * 60 + s;
    }
  } catch (_) {
    return null;
  }
  return null;
}

String formatSeconds(int seconds) {
  final h = seconds ~/ 3600;
  final m = (seconds % 3600) ~/ 60;
  final s = seconds % 60;
  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}
