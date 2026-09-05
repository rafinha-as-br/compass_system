import 'package:flutter/material.dart';
import 'package:routecraft_app/shared/widgets/travel_status_chip.dart';

/// Summary card for a travel — used in the Início list and the Roteiro hub.
/// A "dumb" widget: it takes already-resolved strings, it doesn't know
/// about the `Travel` domain entity.
class TravelCard extends StatelessWidget {
  final String travelName;
  final String routeSummary;
  final TravelStatusChipVariant status;
  final VoidCallback? onTap;

  const TravelCard({
    super.key,
    required this.travelName,
    required this.routeSummary,
    required this.status,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      travelName,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      routeSummary,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              TravelStatusChip(status: status),
            ],
          ),
        ),
      ),
    );
  }
}
