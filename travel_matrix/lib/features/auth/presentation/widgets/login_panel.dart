import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

import '../../../../app/global_controllers/auth_controller.dart';
import '../controllers/login_controller.dart';

/// Responsible for displaying login forms
class LoginPanel extends StatefulWidget {
  const LoginPanel({super.key});

  @override
  State<LoginPanel> createState() => _LoginPanelState();
}

class _LoginPanelState extends State<LoginPanel> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin(LoginController controller) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final result = await controller.login(
      _emailController.text,
      _passwordController.text,
    );

    if (result.isSuccess && mounted) {
      // AuthController will trigger router redirect
      context.read<AuthController>().login(result.data!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LoginController>(
      key: const ValueKey('login'),
      builder: (context, controller, child) {
        final state = controller.state;

        return Padding(
          padding: const EdgeInsets.all(48.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _LoginBackButton(onPressed: controller.showLogin),
                const SizedBox(height: 24),
                const _LoginHeader(),
                const SizedBox(height: 48),
                if (state.errorMessage != null) ...[
                  _LoginErrorMessage(message: state.errorMessage!),
                  const SizedBox(height: 16),
                ],
                _LoginFormFields(
                  emailController: _emailController,
                  passwordController: _passwordController,
                ),
                const SizedBox(height: 48),
                _LoginSubmitButton(
                  isLoading: state.isLoading,
                  onPressed: () => _handleLogin(controller),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoginBackButton extends StatelessWidget {
  const _LoginBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onPressed,
      ),
    );
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        Text(
          l10n.loginTitlePanel,
          style: Theme.of(
            context,
          ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.loginSubtitlePanel,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _LoginErrorMessage extends StatelessWidget {
  const _LoginErrorMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
      textAlign: TextAlign.center,
    );
  }
}

class _LoginFormFields extends StatelessWidget {
  const _LoginFormFields({
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      children: [
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: emailController,
            decoration: InputDecoration(
              labelText: l10n.loginEmailLabel,
              border: const OutlineInputBorder(),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? l10n.loginEmailRequired : null,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 50,
          child: TextFormField(
            controller: passwordController,
            decoration: InputDecoration(
              labelText: l10n.loginPasswordLabel,
              border: const OutlineInputBorder(),
            ),
            obscureText: true,
            validator: (value) =>
                (value == null || value.isEmpty) ? l10n.loginPasswordRequired : null,
          ),
        ),
      ],
    );
  }
}

class _LoginSubmitButton extends StatelessWidget {
  const _LoginSubmitButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
        child: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                AppLocalizations.of(context)!.loginButton,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
