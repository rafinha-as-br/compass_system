import 'package:flutter/material.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// Chip estático com o plano da empresa (sem onTap/hover — só exibição).
class PlanBadge extends StatelessWidget {
  final String planLabel;

  const PlanBadge({super.key, required this.planLabel});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final base = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: base.withValues(alpha: 0.10),
        border: Border.all(color: base.withValues(alpha: 0.35)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        l10n.planBadgeLabel(planLabel),
        style: theme.textTheme.labelMedium?.copyWith(
          color: base,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
