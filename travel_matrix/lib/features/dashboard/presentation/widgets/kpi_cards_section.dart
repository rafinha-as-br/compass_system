import 'package:flutter/material.dart';

import 'package:travel_matrix/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';
import 'package:travel_matrix/shared/widgets/responsive_layout_builder.dart';

class KpiCardsSection extends StatelessWidget {
  final DashboardViewModel dashboard;
  final AppLocalizations l10n;

  const KpiCardsSection({super.key, required this.dashboard, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;

    final cards = [
      _KpiCard(
        icon: Icons.route,
        title: l10n.totalTravels,
        value: dashboard.totalTravels.toString(),
        color: theme.colorScheme.secondary,
      ),
      _KpiCard(
        icon: Icons.event_available,
        title: l10n.itinerariesCompleted,
        value: dashboard.completedItineraries.toString(),
        color: semantic.success,
      ),
      _KpiCard(
        icon: Icons.pending_actions,
        title: l10n.pendingItineraries,
        value: dashboard.pendingItineraries.toString(),
        color: semantic.warning,
      ),
      _KpiCard(
        icon: Icons.people_alt_outlined,
        title: l10n.activeClients,
        value: dashboard.activeClients.toString(),
        color: theme.colorScheme.tertiary,
      ),
    ];

    // Grade por largura disponível: 1 coluna (mobile), 2x2 (tablet), 1x4 (desktop).
    return ResponsiveLayoutBuilder(
      mobile: (_) => _KpiGrid(columns: 1, cards: cards),
      tablet: (_) => _KpiGrid(columns: 2, cards: cards),
      desktop: (_) => _KpiGrid(columns: 4, cards: cards),
    );
  }
}

/// Distribui [cards] em linhas de [columns] células de mesma largura e altura
/// (a última linha incompleta é preenchida com espaço vazio).
class _KpiGrid extends StatelessWidget {
  final int columns;
  final List<Widget> cards;

  const _KpiGrid({required this.columns, required this.cards});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var start = 0; start < cards.length; start += columns) ...[
          if (start > 0) const SizedBox(height: 16),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < columns; i++) ...[
                  if (i > 0) const SizedBox(width: 16),
                  Expanded(child: start + i < cards.length ? cards[start + i] : const SizedBox()),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.64),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
