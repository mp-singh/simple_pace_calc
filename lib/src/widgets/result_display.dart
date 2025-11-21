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
  });

  final List<Map<String, String>> fieldhouseResults;
  final Map<String, String> lapsResult;
  final bool showMoreLanes;
  final VoidCallback onToggleShowMoreLanes;
  final bool useCustomLap;
  final int fieldhouseLane;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (fieldhouseResults.isNotEmpty) ...[
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

              Widget primaryRow = Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '$primaryLabel — $primaryMeters m',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: primarySelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      primaryPace,
                      style: TextStyle(
                        fontFeatures: const [FontFeature.tabularFigures()],
                        fontSize: 15,
                        fontWeight: primarySelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
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
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$label — $meters m',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        pace,
                        style: TextStyle(
                          fontFeatures: const [FontFeature.tabularFigures()],
                          fontSize: 15,
                          fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
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
                      child: TextButton.icon(
                        onPressed: onToggleShowMoreLanes,
                        icon: Icon(
                          showMoreLanes ? Icons.expand_less : Icons.expand_more,
                          size: 18,
                        ),
                        label: Text(
                          showMoreLanes
                              ? 'Show fewer lanes'
                              : 'Show more lanes',
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
          const Divider(),
        if (lapsResult.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Laps',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  lapsResult['exact'] ?? '',
                  style: TextStyle(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Rounded Up Laps',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${lapsResult['roundsUp']}',
                  style: TextStyle(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Total distance',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${lapsResult['roundsUpMeters']} m',
                  style: TextStyle(
                    fontFeatures: const [FontFeature.tabularFigures()],
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (fieldhouseResults.isEmpty && lapsResult.isEmpty)
          const Text('Result will appear here', style: TextStyle(fontSize: 16)),
      ],
    );
  }
}
