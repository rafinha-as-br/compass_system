import 'package:flutter/material.dart';

/// Centered error text styled with the theme's error color. Shared across
/// forms so each screen doesn't restyle its own error banner.
class FormErrorMessage extends StatelessWidget {
  const FormErrorMessage({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: TextStyle(color: Theme.of(context).colorScheme.error),
      textAlign: TextAlign.center,
    );
  }
}
