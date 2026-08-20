import 'package:flutter/material.dart';

/// Reusable top-left back arrow icon button with the platform-localized
/// back tooltip. Used in places that show a custom "back" affordance
/// outside an [AppBar]'s leading slot (which already gets this for free).
class BackIconButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BackIconButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back),
        tooltip: MaterialLocalizations.of(context).backButtonTooltip,
        onPressed: onPressed,
      ),
    );
  }
}
