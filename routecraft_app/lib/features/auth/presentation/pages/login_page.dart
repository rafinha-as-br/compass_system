import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/global_controllers/auth_controller.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/widgets/app_button.dart';
import 'package:routecraft_app/shared/widgets/app_text_field.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key, this.controller});

  /// Injectable for widget tests with a fake use case, without depending on
  /// the real network/singleton wiring. In production, the call site
  /// (`LoginPage()`) is unaffected — the default wiring is used.
  final LoginController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller ?? LoginController(),
      child: const _LoginView(),
    );
  }
}

class _LoginView extends StatefulWidget {
  const _LoginView();

  @override
  State<_LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<_LoginView> {
  final _emailController = TextEditingController(text: 'john@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  final _formKey = GlobalKey<FormState>();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      final controller = context.read<LoginController>();
      final success = await controller.login(
        _emailController.text,
        _passwordController.text,
      );

      if (success && mounted) {
        // Refreshes AuthController so AppRouter's redirect leaves /login.
        await context.read<AuthController>().refresh();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _LoginHeader(title: l10n.loginTitle),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Consumer<LoginController>(
                  builder: (context, controller, child) {
                    final state = controller.state;

                    return Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _emailController,
                            labelText: l10n.loginEmailLabel,
                            hintText: l10n.loginEmailHint,
                            textInputAction: TextInputAction.next,
                            validator: (v) => v!.isEmpty ? l10n.loginEmailRequired : null,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            controller: _passwordController,
                            labelText: l10n.loginPasswordLabel,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                              tooltip: _obscurePassword ? l10n.loginShowPassword : l10n.loginHidePassword,
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (v) => v!.isEmpty ? l10n.loginPasswordRequired : null,
                          ),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => context.push(AppRoutes.forgotPassword),
                              child: Text(l10n.forgotPasswordLink),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 50,
                            child: AppButton(
                              onPressed: _handleLogin,
                              isLoading: state.isLoading,
                              child: Text(
                                l10n.loginButton,
                                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ),
                          if (state.errorMessage != null) ...[
                            const SizedBox(height: 16),
                            _InlineErrorBox(
                              message: state.isConnectivityError ? l10n.loginError : state.errorMessage!,
                            ),
                          ],
                          const SizedBox(height: 32),
                          Center(
                            child: Text(
                              l10n.loginNoAccountFooter,
                              style: TextStyle(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Curved brand header at the top of the login screen — replaces the plain
/// [AppBar] used before the wireframe 2a redesign.
class _LoginHeader extends StatelessWidget {
  const _LoginHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Text('✦', style: TextStyle(fontSize: 32, color: colorScheme.onPrimary)),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: colorScheme.onPrimary),
          ),
        ],
      ),
    );
  }
}

/// Inline error presentation for a failed login attempt — wireframe 2a calls
/// for a box below the CTA, not a snackbar or dialog.
class _InlineErrorBox extends StatelessWidget {
  const _InlineErrorBox({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final errorColor = Theme.of(context).colorScheme.error;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: errorColor),
      ),
      child: Row(
        children: [
          Icon(Icons.close, color: errorColor, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: errorColor)),
          ),
        ],
      ),
    );
  }
}
