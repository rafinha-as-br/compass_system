import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/features/auth/presentation/controllers/login_controller.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: const _LandingView(),
    );
  }
}

class _LandingView extends StatefulWidget {
  const _LandingView();

  @override
  State<_LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends State<_LandingView> {
  // false = welcome panel, true = login panel
  bool _showLogin = false;

  final _emailController = TextEditingController(text: 'smith@matrix.com');
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
      final token = await controller.login(
        _emailController.text,
        _passwordController.text,
      );

      if (token != null && mounted) {
        // AuthController will trigger router redirect
        context.read<AuthController>().login(token);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          /// Left Banner
          Expanded(
            flex: 2,
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Padding(
                padding: const EdgeInsets.all(230),
                child: Image.asset('assets/images/logo.png', width: 400),
              ),
            ),
          ),

          /// Right Panel (AnimatedSwitcher)
          Expanded(
            flex: 1,
            child: Container(
              color: Theme.of(context).colorScheme.surface,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return FadeTransition(opacity: animation, child: child);
                },
                child: _showLogin ? _buildLoginForm(context) : _buildWelcomePanel(context),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildWelcomePanel(BuildContext context) {
    return Padding(
      key: const ValueKey('welcome'),
      padding: const EdgeInsets.all(48.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Welcome to Travel Matrix',
            style: Theme.of(context).textTheme.headlineLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'The digital concierge platform for elite travel agents.',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 64),
          SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: () => setState(() => _showLogin = true),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.secondary,
                foregroundColor: Theme.of(context).colorScheme.onSecondary,
              ),
              child: const Text(
                'ENTER THE MATRIX',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm(BuildContext context) {
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
                /// Back button
                Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => setState(() => _showLogin = false),
                  ),
                ),
                const SizedBox(height: 24),

                /// title
                Column(
                  children: [
                    Text(
                      'Agent Login',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please authenticate to continue',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                      ),
                    )
                  ],
                ),

                /// inputs
                Column(
                  children: [
                    const SizedBox(height: 48),
                    if (state.errorMessage != null) ...[
                      Text(
                        state.errorMessage!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                    ],
                    SizedBox(
                      height: 50,
                      child: TextFormField(
                        controller: _emailController,
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
                        controller: _passwordController,
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
                        onPressed: state.isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          foregroundColor: Theme.of(context).colorScheme.onPrimary,
                        ),
                        child: state.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Text(
                                'LOGIN',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
