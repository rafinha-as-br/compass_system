import 'package:flutter/material.dart';
import 'package:travel_matrix/app/gates/gate_auth.dart';

enum AppStatus {
  authenticated,
  unauthenticated,
}

/// Gate responsible for directing for other gates, using [AppStatus] to
/// determine the gate.
class GateSplash extends StatefulWidget {
  const GateSplash({super.key});

  @override
  State<GateSplash> createState() => _GateSplashState();
}

class _GateSplashState extends State<GateSplash> {
  @override
  void initState() {
    super.initState();
    _checkAppStatus();
  }

  Future<void> _checkAppStatus() async {
    // Artificial delay for splash screen
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const GateAuth()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [

            /// Loading widget
            ///

          ],
        ),
      ),
    );
  }
}
