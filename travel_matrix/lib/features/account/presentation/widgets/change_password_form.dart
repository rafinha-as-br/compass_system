import 'package:flutter/material.dart';
import 'package:travel_matrix/features/account/presentation/controllers/change_password_controller.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/utils/validators.dart';
import 'package:travel_matrix/shared/widgets/form_error_message.dart';
import 'package:travel_matrix/shared/widgets/primary_submit_button.dart';

/// Current / new / confirmation fields plus submit, shared by the forced
/// first-login screen and the profile dialog. Both hit the same endpoint.
class ChangePasswordForm extends StatefulWidget {
  /// Called after the backend accepted the new password.
  final VoidCallback onSuccess;

  /// Injectable for tests; created (and disposed) here when omitted.
  final ChangePasswordController? controller;

  const ChangePasswordForm({super.key, required this.onSuccess, this.controller});

  @override
  State<ChangePasswordForm> createState() => _ChangePasswordFormState();
}

class _ChangePasswordFormState extends State<ChangePasswordForm> {
  // Mirrors the backend rule (AgentPasswordController.MIN_PASSWORD_LENGTH).
  static const _minLength = 8;

  late final ChangePasswordController _controller =
      widget.controller ?? ChangePasswordController();
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    if (widget.controller == null) _controller.dispose();
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final ok = await _controller.submit(_currentController.text, _newController.text);
    if (ok && mounted) widget.onSuccess();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final error = _controller.errorMessage;
        return Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (error != null) ...[
                FormErrorMessage(message: error),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: _currentController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.currentPassword,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) => Validators.required(v, l10n.passwordRequiredValidation),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _newController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.newPassword,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    Validators.required(v, l10n.passwordRequiredValidation) ??
                    (v!.length < _minLength ? l10n.passwordMinLengthValidation : null),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: l10n.confirmNewPassword,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    v != _newController.text ? l10n.passwordsDoNotMatchValidation : null,
              ),
              const SizedBox(height: 24),
              PrimarySubmitButton(
                label: l10n.updateButton,
                isLoading: _controller.isSubmitting,
                onPressed: _submit,
              ),
            ],
          ),
        );
      },
    );
  }
}
