import 'package:flutter/material.dart';
import 'package:travel_matrix/features/company/presentation/view_models/agent_row_view_model.dart';
import 'package:travel_matrix/features/company/presentation/widgets/role_chip.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/widgets/app_data_table.dart';

/// Tabela de agentes: NOME · LOGIN GERADO · PAPEL · chevron. Linha inteira
/// clicável (padrão de `UsersDashboardPage`), sem coluna de ações — a
/// diferença OWNER/MEMBER fica dentro do diálogo. Abaixo de ~900px a coluna
/// de login é suprimida.
class AgentsTable extends StatelessWidget {
  static const _compactBreakpoint = 900.0;

  final List<AgentRowViewModel> agents;
  final ValueChanged<AgentRowViewModel> onAgentTap;

  const AgentsTable({
    super.key,
    required this.agents,
    required this.onAgentTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < _compactBreakpoint;
        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          child: SingleChildScrollView(
            child: AppDataTable<AgentRowViewModel>(
              items: agents,
              onRowTap: (_, agent) => onAgentTap(agent),
              columns: [
                AppDataColumn(
                  label: l10n.agentNameColumn,
                  width: const FlexColumnWidth(1.4),
                  cellBuilder: (context, agent) => Text(
                    agent.isCurrentAgent
                        ? '${agent.name}${l10n.youSuffix}'
                        : agent.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                if (!compact)
                  AppDataColumn(
                    label: l10n.generatedLoginColumn,
                    width: const FlexColumnWidth(2.1),
                    cellBuilder: (context, agent) => Text(
                      agent.login,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                AppDataColumn(
                  label: l10n.roleColumn,
                  width: const FlexColumnWidth(1),
                  cellBuilder: (context, agent) => Align(
                    alignment: Alignment.centerLeft,
                    child: RoleChip(
                      roleLabel: agent.roleLabel,
                      isOwner: agent.isOwner,
                    ),
                  ),
                ),
                AppDataColumn(
                  label: '',
                  width: const FixedColumnWidth(48),
                  cellBuilder: (context, agent) => Icon(
                    Icons.chevron_right,
                    size: 26,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
