import 'package:flutter/material.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

/// The travel's lifecycle stage a status chip can show — mirrors the
/// backend's `travelStatus`, kept independent from the travels feature's own
/// domain enum so this shared widget has no dependency on it.
enum TravelStatusChipVariant {
  routeCreated,
  itineraryCreated,
  travelStarted,
  travelFinished,
}

/// Small colored label for a travel's current status, used on travel cards
/// and detail headers.
class TravelStatusChip extends StatelessWidget {
  final TravelStatusChipVariant status;

  const TravelStatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final (label, color) = switch (status) {
      TravelStatusChipVariant.routeCreated => (l10n.travelStatusRouteCreated, TravelAppColors.warning),
      TravelStatusChipVariant.itineraryCreated => (l10n.travelStatusItineraryCreated, TravelAppColors.info),
      TravelStatusChipVariant.travelStarted => (l10n.travelStatusTravelStarted, theme.colorScheme.primary),
      TravelStatusChipVariant.travelFinished => (l10n.travelStatusTravelFinished, TravelAppColors.success),
    };

    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: TravelAppColors.textOnDark, fontWeight: FontWeight.w600, fontSize: 12),
      ),
      backgroundColor: color,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      visualDensity: VisualDensity.compact,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      side: BorderSide.none,
    );
  }
}
