import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

import '../../../../app/global_controllers/auth_controller.dart';
import '../controllers/login_controller.dart';

class LoginPanel extends StatelessWidget {
  const LoginPanel({super.key});

  @override
  Widget build(BuildContext context){

    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return Consumer<LoginController>(
      key: const ValueKey('login'),
      builder: (context, controller, child) {
        final state = controller.state;

        Future<void> handleLogin() async {
          if (formKey.currentState!.validate()) {
            final controller = context.read<LoginController>();
            final token = await controller.login(
              emailController.text,
              passwordController.text,
            );

            if (token != null && context.mounted) {
              // AuthController will trigger router redirect
              context.read<AuthController>().login(token);
            }
          }
        }

        return Padding(
          padding: const EdgeInsets.all(48.0),
          child: Form(
            key: state.formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                /// Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => controller.showLogin(),
                  ),
                ),
                const SizedBox(height: 24),

                /// title
                Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.loginTitle,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.loginSubtitlePanel,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(
                          context,
                        ).colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),

                /// inputs
                Column(
                  children: [
                    const SizedBox(height: 48),
                    if (state.errorMessage != null) ...[
                      Text(
                        state.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      height: 50,
                      child: TextFormField(
                        controller: emailController,
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v!.isEmpty ? 'Enter email' : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 50,
                      child: TextFormField(
                        controller: passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                        validator: (v) => v!.isEmpty ? 'Enter password' : null,
                      ),
                    ),
                    const SizedBox(height: 48),
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.isLoading ? null : handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          foregroundColor: Theme.of(
                            context,
                          ).colorScheme.onPrimary,
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                            : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }


}
