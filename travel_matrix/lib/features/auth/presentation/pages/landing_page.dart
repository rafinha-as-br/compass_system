import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/auth/presentation/controllers/login_controller.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/login_panel.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/welcome_panel.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginController(),
      child: Scaffold(
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
                  child: Provider.of<LoginController>(context).state.showLogin
                      ? WelcomePanel()
                      : LoginPanel(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
