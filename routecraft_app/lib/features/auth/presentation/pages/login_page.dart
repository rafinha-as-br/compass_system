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
      appBar: AppBar(
        title: Text(l10n.loginTitle),
        centerTitle: true,
      ),
      body: Consumer<LoginController>(
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
                  Image.asset(
                    'assets/images/logo.png',
                    height: 80,
                  ),
                  const SizedBox(height: 32),
                  if (state.errorMessage != null) ...[
                    Text(
                      state.isConnectivityError ? l10n.loginError : state.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  AppTextField(
                    controller: _emailController,
                    labelText: l10n.loginEmailLabel,
                    validator: (v) => v!.isEmpty ? l10n.loginEmailRequired : null,
                  ),
                  const SizedBox(height: 16),
                  AppTextField(
                    controller: _passwordController,
                    labelText: l10n.loginPasswordLabel,
                    obscureText: true,
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
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
