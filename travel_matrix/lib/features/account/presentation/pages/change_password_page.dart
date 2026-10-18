import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/features/account/presentation/widgets/change_password_form.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/widgets/card_shell.dart';

/// Forced first-login screen for invited agents. Lives outside the private
/// shell: the router keeps the agent here until [AuthController.passwordChanged].
class ChangePasswordPage extends StatelessWidget {
  const ChangePasswordPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: CardShell(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.changePasswordRequiredTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.changePasswordRequiredBody,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 24),
                  ChangePasswordForm(
                    onSuccess: () => context.read<AuthController>().passwordChanged(),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => context.read<AuthController>().logout(),
                    child: Text(l10n.logoutNav),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
