import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/step_card_view_models.dart';

/// Card for displaying a Boundary (Start/End) step in the itinerary.
///
/// Consumes a [BoundaryStepViewCardModel] to show start or destination
/// location.
///
/// Layout: Simple row with an icon, title, and location.
class BoundaryStepCard extends StatelessWidget {
  final BoundaryStepViewCardModel step;

  const BoundaryStepCard({
    super.key,
    required this.step,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            step.isStart ? Icons.trip_origin : Icons.flag_outlined,
            size: 18,
            color: theme.colorScheme.primary.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  step.title,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                ),
                Text(
                  step.location,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

