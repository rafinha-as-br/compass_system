import 'package:flutter/material.dart';
import 'package:travel_matrix/features/company/presentation/view_models/agent_row_view_model.dart';
import 'package:travel_matrix/features/company/presentation/widgets/role_chip.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// O que o usuário escolheu no diálogo do agente. A confirmação e a chamada
/// à API acontecem na página, não aqui.
enum AgentDetailAction { promote, demote, remove }

/// Abre o diálogo do agente. Retorna a ação escolhida, ou null se fechou.
Future<AgentDetailAction?> showAgentDetailDialog(
  BuildContext context, {
  required AgentRowViewModel agent,
  required bool canManage,
  required bool isSoleOwner,
}) {
  return showDialog<AgentDetailAction>(
    context: context,
    builder: (context) => AgentDetailDialog(
      agent: agent,
      canManage: canManage,
      isSoleOwner: isSoleOwner,
    ),
  );
}

/// Diálogo inline (sem rota) com os dados do agente. O bloco de ações só
/// renderiza para OWNER ([canManage]); para o único OWNER as ações ficam
/// desabilitadas com o aviso fixo, sem diálogo de erro em cima do diálogo.
class AgentDetailDialog extends StatelessWidget {
  final AgentRowViewModel agent;
  final bool canManage;
  final bool isSoleOwner;

  const AgentDetailDialog({
    super.key,
    required this.agent,
    required this.canManage,
    required this.isSoleOwner,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final memberSince = agent.memberSinceLabel;

    return AlertDialog(
      titlePadding: const EdgeInsets.fromLTRB(24, 20, 12, 0),
      title: Row(
        children: [
          CircleAvatar(
            radius: 23,
            backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
            child: Text(
              agent.initials,
              style: TextStyle(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  agent.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  agent.login,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: l10n.closeButton,
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _DetailRow(
                    label: l10n.roleColumn,
                    value: RoleChip(
                      roleLabel: agent.roleLabel,
                      isOwner: agent.isOwner,
                    ),
                  ),
                  // Linha omitida (sem placeholder) quando o backend não tem
                  // a data — agentes anteriores ao módulo company.
                  if (memberSince != null) ...[
                    const SizedBox(height: 12),
                    _DetailRow(
                      label: l10n.memberSinceLabel,
                      value: Text(memberSince),
                    ),
                  ],
                ],
              ),
            ),
            if (canManage) ...[
              const SizedBox(height: 16),
              if (isSoleOwner)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    l10n.soleOwnerNotice,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
                  ),
                ),
              OutlinedButton(
                onPressed: isSoleOwner
                    ? null
                    : () => Navigator.of(context).pop(
                          agent.isOwner
                              ? AgentDetailAction.demote
                              : AgentDetailAction.promote,
                        ),
                child: Text(
                  agent.isOwner
                      ? l10n.demoteToMemberButton
                      : l10n.promoteToOwnerButton,
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: isSoleOwner
                    ? null
                    : () => Navigator.of(context).pop(AgentDetailAction.remove),
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.error,
                  side: BorderSide(
                    color: isSoleOwner
                        ? theme.disabledColor
                        : theme.colorScheme.error,
                  ),
                ),
                child: Text(l10n.removeFromCompanyButton),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.closeButton),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final Widget value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(width: 12),
        value,
      ],
    );
  }
}
