import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/reset_password_controller.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/utils/validators.dart';

class ResetPasswordPage extends StatelessWidget {
  const ResetPasswordPage({super.key, this.controller});

  /// Injectable for widget tests with a fake [AuthRepository], without
  /// depending on the real network/singleton wiring. In production, the
  /// call site (`ResetPasswordPage()`) is unaffected — the default wiring
  /// is used.
  final ResetPasswordController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller ?? ResetPasswordController(),
      child: const _ResetPasswordView(),
    );
  }
}

class _ResetPasswordView extends StatefulWidget {
  const _ResetPasswordView();

  @override
  State<_ResetPasswordView> createState() => _ResetPasswordViewState();
}

class _ResetPasswordViewState extends State<_ResetPasswordView> {
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final controller = context.read<ResetPasswordController>();
    final success = await controller.resetPassword(
      _tokenController.text,
      _newPasswordController.text,
    );

    if (success && mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.resetPasswordSuccess)),
      );
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.resetPasswordTitle),
        centerTitle: true,
      ),
      body: Consumer<ResetPasswordController>(
        builder: (context, controller, child) {
          final state = controller.state;

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.resetPasswordSubtitle,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                  const SizedBox(height: 32),
                  if (state.errorMessage != null) ...[
                    Text(
                      state.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: l10n.resetPasswordTokenLabel,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) =>
                        Validators.required(value, l10n.resetPasswordTokenRequired),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    decoration: InputDecoration(
                      labelText: l10n.resetPasswordNewPasswordLabel,
                      border: const OutlineInputBorder(),
                    ),
                    obscureText: true,
                    validator: (value) =>
                        Validators.required(value, l10n.resetPasswordNewPasswordRequired),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      ),
                      child: state.isLoading
                          ? const CircularProgressIndicator()
                          : Text(
                              l10n.resetPasswordSubmitButton,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
