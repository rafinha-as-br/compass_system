import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/utils/validators.dart';
import 'package:travel_matrix/shared/widgets/back_icon_button.dart';
import 'package:travel_matrix/shared/widgets/form_error_message.dart';
import 'package:travel_matrix/shared/widgets/primary_submit_button.dart';

import '../controllers/login_controller.dart';

/// Asks for the token received by e-mail and a new password to complete
/// the password reset flow.
class ResetPasswordPanel extends StatefulWidget {
  const ResetPasswordPanel({super.key});

  @override
  State<ResetPasswordPanel> createState() => _ResetPasswordPanelState();
}

class _ResetPasswordPanelState extends State<ResetPasswordPanel> {
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(LoginController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await controller.resetPassword(
      _tokenController.text,
      _newPasswordController.text,
    );

    if (result.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.resetPasswordSuccess)),
      );
      controller.showLoginPanel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      key: const ValueKey('resetPassword'),
      builder: (context, controller, child) {
        final state = controller.state;
        final l10n = AppLocalizations.of(context)!;

        return Padding(
          padding: const EdgeInsets.all(48.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                BackIconButton(onPressed: controller.showLoginPanel),
                const SizedBox(height: 24),
                const _ResetPasswordHeader(),
                const SizedBox(height: 48),
                if (state.errorMessage != null) ...[
                  FormErrorMessage(message: state.errorMessage!),
                  const SizedBox(height: 16),
                ],
                _ResetPasswordFormFields(
                  tokenController: _tokenController,
                  newPasswordController: _newPasswordController,
                ),
                const SizedBox(height: 32),
                PrimarySubmitButton(
                  label: l10n.resetPasswordSubmitButton,
                  isLoading: state.isLoading,
                  onPressed: () => _handleSubmit(controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ResetPasswordHeader extends StatelessWidget {
  const _ResetPasswordHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          l10n.resetPasswordTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.resetPasswordSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ResetPasswordFormFields extends StatelessWidget {
  const _ResetPasswordFormFields({
    required this.tokenController,
    required this.newPasswordController,
  });

  final TextEditingController tokenController;
  final TextEditingController newPasswordController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: tokenController,
            decoration: InputDecoration(
              labelText: l10n.resetPasswordTokenLabel,
              border: const OutlineInputBorder(),
            ),
            validator: (value) => Validators.required(value, l10n.resetPasswordTokenRequired),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: newPasswordController,
            decoration: InputDecoration(
              labelText: l10n.resetPasswordNewPasswordLabel,
              border: const OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) =>
                Validators.required(value, l10n.resetPasswordNewPasswordRequired),
          ),
        ),
      ],
    );
  }
}
