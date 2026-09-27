import 'package:flutter/material.dart';
import 'package:travel_matrix/features/company/presentation/view_models/company_header_view_model.dart';
import 'package:travel_matrix/features/company/presentation/widgets/plan_badge.dart';
import 'package:travel_matrix/shared/widgets/card_shell.dart';

/// Cabeçalho do Painel: avatar com iniciais, nome, CNPJ e badge do plano.
/// Adaptação de `ProfileHeaderCard`; abaixo de ~900px o badge empilha.
class CompanyHeaderCard extends StatelessWidget {
  static const _stackBreakpoint = 900.0;

  final CompanyHeaderViewModel company;

  const CompanyHeaderCard({super.key, required this.company});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final identity = Row(
      children: [
        CircleAvatar(
          radius: 26,
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            company.initials,
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                company.name,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                company.cnpj,
                style: TextStyle(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ),
      ],
    );

    return CardShell(
      padding: const EdgeInsets.all(20),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < _stackBreakpoint) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                identity,
                const SizedBox(height: 12),
                PlanBadge(planLabel: company.planLabel),
              ],
            );
          }
          return Row(
            children: [
              Expanded(child: identity),
              const SizedBox(width: 16),
              PlanBadge(planLabel: company.planLabel),
            ],
          );
        },
      ),
    );
  }
}
