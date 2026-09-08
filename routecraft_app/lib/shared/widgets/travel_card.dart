import 'package:flutter/material.dart';
import 'package:routecraft_app/shared/widgets/travel_status_chip.dart';

/// Summary card for a travel — used in the Início list and the Roteiro hub.
/// A "dumb" widget: it takes already-resolved strings, it doesn't know
/// about the `Travel` domain entity.
class TravelCard extends StatelessWidget {
  final String travelName;
  final String route;
  final String period;
  final TravelStatusChipVariant status;
  final VoidCallback? onTap;

  const TravelCard({
    super.key,
    required this.travelName,
    required this.route,
    required this.period,
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
                      route,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      period,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
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
