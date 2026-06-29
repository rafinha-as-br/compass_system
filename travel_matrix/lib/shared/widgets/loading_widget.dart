import 'package:flutter/material.dart';

/// Widget used for showing the logo and a progress bar, to represent loading states
class LoadingWidget extends StatelessWidget {
  const LoadingWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

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
    );
  }
}
