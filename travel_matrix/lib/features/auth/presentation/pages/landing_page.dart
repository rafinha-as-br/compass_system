import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/auth/presentation/controllers/login_controller.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/forgot_password_panel.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/login_panel.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/reset_password_panel.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/welcome_panel.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<LoginController>(
      create: (_) => LoginController(),
      builder: (context, child){
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
                    child: switch (Provider.of<LoginController>(context).state.panel) {
                      AuthPanel.welcome => const WelcomePanel(),
                      AuthPanel.login => const LoginPanel(),
                      AuthPanel.forgotPassword => const ForgotPasswordPanel(),
                      AuthPanel.resetPassword => const ResetPasswordPanel(),
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
