import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/utils/validators.dart';
import 'package:travel_matrix/shared/widgets/back_icon_button.dart';
import 'package:travel_matrix/shared/widgets/form_error_message.dart';
import 'package:travel_matrix/shared/widgets/primary_submit_button.dart';

import '../controllers/login_controller.dart';

/// Asks for the account e-mail to start the password reset flow.
class ForgotPasswordPanel extends StatefulWidget {
  const ForgotPasswordPanel({super.key});

  @override
  State<ForgotPasswordPanel> createState() => _ForgotPasswordPanelState();
}

class _ForgotPasswordPanelState extends State<ForgotPasswordPanel> {
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit(LoginController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await controller.requestPasswordReset(_emailController.text);

    if (result.isSuccess && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.forgotPasswordConfirmation)),
      );
      controller.showResetPassword();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      key: const ValueKey('forgotPassword'),
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
                const _ForgotPasswordHeader(),
                const SizedBox(height: 48),
                if (state.errorMessage != null) ...[
                  FormErrorMessage(message: state.errorMessage!),
                  const SizedBox(height: 16),
                ],
                _ForgotPasswordFormFields(emailController: _emailController),
                const SizedBox(height: 32),
                PrimarySubmitButton(
                  label: l10n.forgotPasswordSubmitButton,
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

class _ForgotPasswordHeader extends StatelessWidget {
  const _ForgotPasswordHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          l10n.forgotPasswordTitle,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          l10n.forgotPasswordSubtitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _ForgotPasswordFormFields extends StatelessWidget {
  const _ForgotPasswordFormFields({required this.emailController});

  final TextEditingController emailController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      height: 50,
      child: TextFormField(
        controller: emailController,
        decoration: InputDecoration(
          labelText: l10n.loginEmailLabel,
          border: const OutlineInputBorder(),
        ),
        validator: (value) => Validators.required(value, l10n.loginEmailRequired),
      ),
    );
  }
}
