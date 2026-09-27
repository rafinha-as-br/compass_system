import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/presentation/controllers/company_dashboard_controller.dart';
import 'package:travel_matrix/features/company/presentation/view_models/agent_row_view_model.dart';
import 'package:travel_matrix/features/company/presentation/widgets/agent_detail_dialog.dart';
import 'package:travel_matrix/features/company/presentation/widgets/agents_table.dart';
import 'package:travel_matrix/features/company/presentation/widgets/company_confirmation_dialogs.dart';
import 'package:travel_matrix/features/company/presentation/widgets/company_header_card.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/widgets/breadcrumb_bar.dart';

/// Painel da Empresa (`/company`) — visível para OWNER e MEMBER. Convidar,
/// remover e alterar papel só aparecem para OWNER.
class CompanyDashboardPage extends StatelessWidget {
  final CompanyDashboardController? controller;

  const CompanyDashboardPage({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final providedController = controller;
    return providedController != null
        ? ChangeNotifierProvider.value(
            value: providedController,
            child: const _CompanyDashboardView(),
          )
        : ChangeNotifierProvider(
            create: (_) => CompanyDashboardController(),
            child: const _CompanyDashboardView(),
          );
  }
}

class _CompanyDashboardView extends StatelessWidget {
  const _CompanyDashboardView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CompanyDashboardController>();
    final state = controller.state;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final company = state.company;
    if (state.hasLoadError || company == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.failedToLoadCompany,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: controller.load,
              child: Text(l10n.retryButton),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        BreadcrumbBar(items: [l10n.companyBreadcrumbRoot, l10n.companyTitle]),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.companyTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                CompanyHeaderCard(company: company),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      l10n.agentsCountLabel(state.agents.length),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // Só OWNER convida — MEMBER não vê o botão nem espaço vazio.
                    if (state.isOwner)
                      ElevatedButton.icon(
                        onPressed: () => _goToInvite(context, controller),
                        icon: const Icon(Icons.add),
                        label: Text(l10n.inviteAgentButton),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.secondary,
                          foregroundColor: theme.colorScheme.onSecondary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 16,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: state.agents.isEmpty
                      ? Center(
                          child: Text(
                            l10n.noAgentsMessage,
                            style: TextStyle(
                              color: theme.colorScheme.onSurface
                                  .withValues(alpha: 0.6),
                            ),
                          ),
                        )
                      : AgentsTable(
                          agents: state.agents,
                          onAgentTap: (agent) =>
                              _openAgent(context, controller, agent),
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  void _goToInvite(BuildContext context, CompanyDashboardController controller) {
    context.go(
      '${AppRoutes.company}/${AppRoutes.companyInvite}',
      extra: {'controller': controller},
    );
  }

  /// Diálogo do agente → confirmação → chamada → recarrega lista → SnackBar.
  /// O controller decide sucesso/falha; a reação de UI fica toda aqui.
  Future<void> _openAgent(
    BuildContext context,
    CompanyDashboardController controller,
    AgentRowViewModel agent,
  ) async {
    final state = controller.state;
    final action = await showAgentDetailDialog(
      context,
      agent: agent,
      canManage: state.isOwner,
      isSoleOwner: state.isSoleOwner(agent),
    );
    if (action == null || !context.mounted) return;

    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.of(context);
    final companyName = state.company?.name ?? '';

    switch (action) {
      case AgentDetailAction.remove:
        final confirmed = await showRemoveAgentDialog(context, agentName: agent.name);
        if (!confirmed || !context.mounted) return;
        final ok = await controller.removeAgent(agent.id);
        if (!context.mounted) return;
        if (ok) {
          messenger.showSnackBar(
            SnackBar(content: Text(l10n.agentRemovedSnack(agent.name))),
          );
        } else {
          await _showFailure(context, controller, agent, messenger, companyName);
        }
      case AgentDetailAction.promote:
      case AgentDetailAction.demote:
        final newRole =
            action == AgentDetailAction.promote ? AgentRole.owner : AgentRole.member;
        final confirmed = await showChangeRoleDialog(
          context,
          agentName: agent.name,
          newRole: newRole,
        );
        if (!confirmed || !context.mounted) return;
        final ok = await controller.changeRole(agent.id, newRole);
        if (!context.mounted) return;
        if (ok) {
          messenger.showSnackBar(
            SnackBar(
              content: Text(
                l10n.roleChangedSnack(agent.name, newRole.name.toUpperCase()),
              ),
            ),
          );
        } else {
          await _showFailure(context, controller, agent, messenger, companyName);
        }
    }
  }

  /// Remover/rebaixar um OWNER só falha no backend pela regra do único OWNER
  /// (corrida entre abas) → diálogo "Ação bloqueada". Qualquer outra falha
  /// mostra a mensagem do backend em SnackBar.
  Future<void> _showFailure(
    BuildContext context,
    CompanyDashboardController controller,
    AgentRowViewModel agent,
    ScaffoldMessengerState messenger,
    String companyName,
  ) async {
    final message = controller.takeErrorMessage();
    if (agent.isOwner) {
      await showBlockedActionDialog(context, companyName: companyName);
      return;
    }
    if (message != null) {
      messenger.showSnackBar(SnackBar(content: Text(message)));
    }
  }
}
