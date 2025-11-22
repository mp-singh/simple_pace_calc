import 'package:flutter/material.dart';

/// Widget for displaying Track mode results.

class TrackResultDisplay extends StatelessWidget {
  const TrackResultDisplay({
    super.key,
    required this.fieldhouseResults,
    required this.lapsResult,
    required this.showMoreLanes,
    required this.onToggleShowMoreLanes,
    required this.useCustomLap,
    required this.fieldhouseLane,
    required this.onLaneSelected,
    required this.errorMessage,
  });

  final List<Map<String, String>> fieldhouseResults;
  final Map<String, String> lapsResult;
  final bool showMoreLanes;
  final VoidCallback onToggleShowMoreLanes;
  final bool useCustomLap;
  final int fieldhouseLane;
  final ValueChanged<int> onLaneSelected;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fieldhouseResults.isNotEmpty) ...[
          // Lane Paces Section Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.directions_run,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lane Paces',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Builder(
            builder: (context) {
              final theme = Theme.of(context);
              final primary = fieldhouseResults.first;
              final primaryLaneStr = primary['lane'];
              final primaryLabel = primary['label'] ?? '';
              final primaryMeters = primary['meters'] ?? '';
              final primaryPace = primary['pace'] ?? '';
              final primarySelected =
                  !useCustomLap &&
                  primaryLaneStr != null &&
                  int.tryParse(primaryLaneStr) == fieldhouseLane;

              Widget primaryRow = InkWell(
                onTap: primaryLaneStr != null && primaryLaneStr != 'custom'
                    ? () => onLaneSelected(int.parse(primaryLaneStr))
                    : null,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$primaryLabel — $primaryMeters m',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: primarySelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              theme.colorScheme.primary.withValues(
                                alpha: primarySelected ? 0.15 : 0.1,
                              ),
                              theme.colorScheme.primary.withValues(
                                alpha: primarySelected ? 0.08 : 0.05,
                              ),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          primaryPace,
                          style: TextStyle(
                            fontFeatures: const [FontFeature.tabularFigures()],
                            fontSize: 16,
                            fontWeight: primarySelected
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
              final secondary = fieldhouseResults.skip(1).map((r) {
                final laneStr = r['lane'];
                final label = r['label'] ?? '';
                final meters = r['meters'] ?? '';
                final pace = r['pace'] ?? '';
                final sel =
                    !useCustomLap &&
                    laneStr != null &&
                    int.tryParse(laneStr) == fieldhouseLane;
                return InkWell(
                  onTap: laneStr != null && laneStr != 'custom'
                      ? () => onLaneSelected(int.parse(laneStr))
                      : null,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '$label — $meters m',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: sel
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.8,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                theme.colorScheme.primary.withValues(
                                  alpha: sel ? 0.12 : 0.08,
                                ),
                                theme.colorScheme.primary.withValues(
                                  alpha: sel ? 0.06 : 0.04,
                                ),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            pace,
                            style: TextStyle(
                              fontFeatures: const [
                                FontFeature.tabularFigures(),
                              ],
                              fontSize: 14,
                              fontWeight: sel
                                  ? FontWeight.w700
                                  : FontWeight.w600,
                              color: theme.colorScheme.onSurface.withValues(
                                alpha: 0.9,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList();

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  primaryRow,
                  if (fieldhouseResults.length > 1)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: OutlinedButton.icon(
                        onPressed: onToggleShowMoreLanes,
                        icon: Icon(
                          showMoreLanes ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                        ),
                        label: Text(
                          showMoreLanes ? 'Show fewer lanes' : 'Show all lanes',
                        ),
                      ),
                    ),
                  if (showMoreLanes) ...secondary,
                ],
              );
            },
          ),
        ],
        if (fieldhouseResults.isNotEmpty && lapsResult.isNotEmpty)
          const Divider(height: 32),
        if (lapsResult.isNotEmpty) ...[
          // Laps Section Header
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Icon(
                  Icons.flag,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Lap Calculations',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Exact laps needed',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    lapsResult['exact'] ?? '',
                    style: TextStyle(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Rounded up laps',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${lapsResult['roundsUp']}',
                    style: TextStyle(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total distance',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.1),
                        Theme.of(
                          context,
                        ).colorScheme.primary.withValues(alpha: 0.05),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${lapsResult['roundsUpMeters']} m',
                    style: TextStyle(
                      fontFeatures: const [FontFeature.tabularFigures()],
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        if (fieldhouseResults.isEmpty && lapsResult.isEmpty)
          errorMessage.isNotEmpty
              ? Text(
                  errorMessage,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.error,
                  ),
                )
              : const Text(
                  'Result will appear here',
                  style: TextStyle(fontSize: 16),
                ),
      ],
    );
  }
}
