import 'package:flutter/material.dart';
import 'package:travel_matrix/app/gates/gate_auth.dart';

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

            /// logo
            Image.asset('assets/images/logo.png', width: 700),
            Column(
              children: [
                Text(
                  'Travel Matrix App',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 48),
                CircularProgressIndicator(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
