import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/auth/presentation/controllers/login_controller.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/forgot_password_panel.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/login_panel.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/reset_password_panel.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/welcome_panel.dart';

/// Padding and logo width for the landing page's left banner, computed from
/// the space available to it so it never overflows on narrow windows.
({EdgeInsets padding, double logoWidth}) computeBannerLayout(Size availableSize) {
  final horizontalPadding = (availableSize.width * 0.18).clamp(24.0, 230.0);
  final verticalPadding = (availableSize.height * 0.18).clamp(24.0, 230.0);
  final logoWidth = (availableSize.width - horizontalPadding * 2).clamp(120.0, 400.0);
  return (
    padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: verticalPadding),
    logoWidth: logoWidth,
  );
}

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
                  color: Theme.of(context).colorScheme.surface,
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final layout = computeBannerLayout(
                        Size(constraints.maxWidth, constraints.maxHeight),
                      );
                      return Center(
                        child: Padding(
                          padding: layout.padding,
                          child: Image.asset('assets/images/logo.png', width: layout.logoWidth),
                        ),
                      );
                    },
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
