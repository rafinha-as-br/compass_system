import 'package:flutter/material.dart';

import 'package:travel_matrix/features/account/presentation/view_models/agent_profile_view_model.dart';
import 'package:travel_matrix/features/account/presentation/widgets/change_password_form.dart';
import 'package:travel_matrix/shared/widgets/card_shell.dart';
import 'package:travel_matrix/features/account/presentation/widgets/profile_field.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class ProfileDetailsCard extends StatelessWidget {
  final AgentProfileViewModel profile;
  final AppLocalizations l10n;

  const ProfileDetailsCard({super.key, required this.profile, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CardShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.profileSection,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ProfileField(label: l10n.loginEmailLabel, value: profile.email),
          ProfileField(label: l10n.cpfLabel, value: profile.cpf),
          ProfileField(label: l10n.cnpjLabel, value: profile.cnpj),
          ProfileField(label: l10n.phoneLabel, value: profile.phoneNumber),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showEditProfileDialog(context, l10n, profile),
                icon: const Icon(Icons.edit_outlined),
                label: Text(l10n.editAgentData),
              ),
              OutlinedButton.icon(
                onPressed: () => _showChangePasswordDialog(context, l10n),
                icon: const Icon(Icons.lock_reset),
                label: Text(l10n.changePassword),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(
    BuildContext context,
    AppLocalizations l10n,
    AgentProfileViewModel profile,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.editAgentData),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  initialValue: profile.name,
                  decoration: InputDecoration(labelText: l10n.clientNameColumn),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: profile.email,
                  decoration: InputDecoration(labelText: l10n.loginEmailLabel),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  initialValue: profile.phoneNumber,
                  decoration: InputDecoration(labelText: l10n.phoneLabel),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancelButton),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.saveButton),
            ),
          ],
        );
      },
    );
  }

  void _showChangePasswordDialog(BuildContext context, AppLocalizations l10n) {
    final messenger = ScaffoldMessenger.of(context);
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(l10n.changePassword),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: ChangePasswordForm(
                onSuccess: () {
                  Navigator.of(dialogContext).pop();
                  messenger.showSnackBar(SnackBar(content: Text(l10n.passwordChangedSuccess)));
                },
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(l10n.cancelButton),
            ),
          ],
        );
      },
    );
  }
}
