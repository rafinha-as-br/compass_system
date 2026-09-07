import 'package:flutter/material.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/utils/date_formatting.dart';

/// Persistent notice that the screen is showing cached data instead of a
/// live fetch — wireframe 2d (CPS-98). Shown on Início, the Roteiro hub and
/// the itinerary timeline whenever `TravelSyncStatusController`/`HomeState`
/// report offline.
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key, required this.syncedAt});

  final DateTime syncedAt;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Container(
      width: double.infinity,
      color: theme.colorScheme.surfaceContainerHighest,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.cloud_off_outlined, size: 16, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              l10n.offlineBannerLabel(formatDate(languageCode, syncedAt)),
              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
        ],
      ),
    );
  }
}
