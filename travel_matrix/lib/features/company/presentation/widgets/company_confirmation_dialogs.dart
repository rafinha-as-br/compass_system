import 'package:flutter/material.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

/// Diálogos de confirmação do módulo company, no padrão de
/// `DeactivateUserDialog`: ícone circular, corpo explicando a consequência,
/// ação principal e ação neutra em `TextButton`.

/// "Remover {nome}?" — ação destrutiva em `error`. Retorna true se confirmou.
Future<bool> showRemoveAgentDialog(BuildContext context, {required String agentName}) async {
  final l10n = AppLocalizations.of(context)!;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return _ConfirmationDialog(
        icon: Icons.person_remove_outlined,
        iconColor: theme.colorScheme.error,
        title: l10n.removeAgentDialogTitle(agentName),
        body: l10n.removeAgentDialogBody,
        confirmLabel: l10n.removeConfirmButton,
        confirmBackground: theme.colorScheme.error,
        confirmForeground: theme.colorScheme.onError,
        cancelLabel: l10n.cancelActionButton,
      );
    },
  );
  return confirmed ?? false;
}

/// Promover → OWNER ou rebaixar → MEMBER. Decisão da CPS-163: rebaixar um
/// OWNER que não é o único também pede confirmação (consequência invertida).
Future<bool> showChangeRoleDialog(
  BuildContext context, {
  required String agentName,
  required AgentRole newRole,
}) async {
  final l10n = AppLocalizations.of(context)!;
  final promoting = newRole == AgentRole.owner;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return _ConfirmationDialog(
        icon: promoting ? Icons.workspace_premium_outlined : Icons.arrow_downward,
        iconColor: theme.colorScheme.primary,
        title: promoting
            ? l10n.promoteDialogTitle(agentName)
            : l10n.demoteDialogTitle(agentName),
        body: promoting ? l10n.promoteDialogBody : l10n.demoteDialogBody,
        confirmLabel: promoting ? l10n.promoteConfirmButton : l10n.demoteConfirmButton,
        confirmBackground: theme.colorScheme.secondary,
        confirmForeground: theme.colorScheme.onSecondary,
        cancelLabel: l10n.cancelActionButton,
      );
    },
  );
  return confirmed ?? false;
}

/// Fallback "Ação bloqueada": só aparece se o backend recusar a operação do
/// único OWNER (corrida entre abas) — a UI normalmente já desabilita antes.
Future<void> showBlockedActionDialog(BuildContext context, {required String companyName}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<void>(
    context: context,
    builder: (context) {
      final theme = Theme.of(context);
      return _ConfirmationDialog(
        icon: Icons.warning_amber_rounded,
        iconColor: theme.semanticColors.warning,
        title: l10n.blockedActionTitle,
        body: l10n.blockedActionBody(companyName),
        confirmLabel: l10n.understoodButton,
        confirmBackground: theme.colorScheme.primary,
        confirmForeground: theme.colorScheme.onPrimary,
        cancelLabel: null,
      );
    },
  );
}

class _ConfirmationDialog extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String body;
  final String confirmLabel;
  final Color confirmBackground;
  final Color confirmForeground;
  final String? cancelLabel;

  const _ConfirmationDialog({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.body,
    required this.confirmLabel,
    required this.confirmBackground,
    required this.confirmForeground,
    required this.cancelLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      title: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: iconColor.withValues(alpha: 0.12),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(title)),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Text(body, style: theme.textTheme.bodyMedium),
      ),
      actions: [
        if (cancelLabel != null)
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelLabel!),
          ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          style: ElevatedButton.styleFrom(
            backgroundColor: confirmBackground,
            foregroundColor: confirmForeground,
          ),
          child: Text(confirmLabel),
        ),
      ],
    );
  }
}

