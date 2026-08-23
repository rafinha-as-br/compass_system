import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/gates/gate_auth.dart';
import 'package:routecraft_app/features/auth/presentation/controllers/login_controller.dart';
import 'package:routecraft_app/features/auth/presentation/pages/forgot_password_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

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
        // Trigger re-render of Auth Gate
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const GateAuth()),
        );
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
                      state.errorMessage!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                  ],
                  TextFormField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: l10n.loginEmailLabel,
                      labelStyle: const TextStyle(color: TravelAppColors.textSecondary),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: TravelAppColors.border),
                      ),
                    ),
                    validator: (v) => v!.isEmpty ? l10n.loginEmailRequired : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: l10n.loginPasswordLabel,
                      labelStyle: const TextStyle(color: TravelAppColors.textSecondary),
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: TravelAppColors.border),
                      ),
                    ),
                    obscureText: true,
                    validator: (v) => v!.isEmpty ? l10n.loginPasswordRequired : null,
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const ForgotPasswordPage()),
                      ),
                      child: Text(l10n.forgotPasswordLink),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.secondary,
                        foregroundColor: Theme.of(context).colorScheme.onSecondary,
                      ),
                      child: state.isLoading
                          ? const CircularProgressIndicator()
                          : Text(
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
