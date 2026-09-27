import 'package:flutter/material.dart';
import 'package:travel_matrix/features/company/presentation/view_models/invited_credentials_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

/// Confirmação pós-criação que substitui o formulário na mesma rota. A senha
/// temporária só aparece aqui — por isso não navega para fora sozinho.
class InviteSuccessPanel extends StatelessWidget {
  final InvitedCredentialsViewModel credentials;
  final VoidCallback onCopyCredentials;
  final VoidCallback onBackToPanel;

  const InviteSuccessPanel({
    super.key,
    required this.credentials,
    required this.onCopyCredentials,
    required this.onBackToPanel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.check_circle_outline, size: 56, color: theme.semanticColors.success),
        const SizedBox(height: 16),
        Text(
          l10n.agentCreatedTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.agentCreatedBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outlineVariant),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _CredentialLine(label: l10n.loginLabelCaps, value: credentials.login),
              const SizedBox(height: 12),
              _CredentialLine(
                label: l10n.temporaryPasswordLabel,
                value: credentials.temporaryPassword,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: onCopyCredentials,
          icon: const Icon(Icons.copy_outlined),
          label: Text(l10n.copyCredentialsButton),
        ),
        const SizedBox(height: 8),
        ElevatedButton(
          onPressed: onBackToPanel,
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
            foregroundColor: theme.colorScheme.onSecondary,
          ),
          child: Text(l10n.backToPanelButton),
        ),
      ],
    );
  }
}

class _CredentialLine extends StatelessWidget {
  final String label;
  final String value;

  const _CredentialLine({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 4),
        SelectableText(
          value,
          style: const TextStyle(fontFamily: 'monospace', fontSize: 15),
        ),
      ],
    );
  }
}
