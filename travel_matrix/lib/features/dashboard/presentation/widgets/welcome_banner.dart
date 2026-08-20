import 'package:flutter/material.dart';

import 'package:travel_matrix/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class WelcomeBanner extends StatelessWidget {
  final String agentName;
  final DashboardViewModel dashboard;
  final AppLocalizations l10n;

  const WelcomeBanner({
    super.key,
    required this.agentName,
    required this.dashboard,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dashboardWelcome(agentName),
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l10n.dashboardWelcomeSubtitle(
              dashboard.pendingItineraries,
              dashboard.completedItineraries,
            ),
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimary.withValues(alpha: 0.78),
            ),
          ),
        ],
      ),
    );
  }
}
