import 'package:flutter/material.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

/// Visual style for [AppButton].
enum AppButtonVariant {
  /// Filled, gold background (`TravelAppColors.accentGold`). Default —
  /// used for the main call to action of a screen.
  primary,

  /// Outline style, transparent background. Used for secondary actions.
  secondary,

  /// Filled, error-colored background. Used for destructive actions.
  danger,
}

/// Shared primary/secondary/danger button, styled once with the RouteCraft
/// brand instead of each screen repeating its own `ElevatedButton.styleFrom(...)`.
class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.variant = AppButtonVariant.primary,
    this.isLoading = false,
    this.icon,
  });

  final VoidCallback? onPressed;
  final Widget child;
  final AppButtonVariant variant;
  final bool isLoading;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = switch (variant) {
      AppButtonVariant.primary => ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.secondary,
          foregroundColor: theme.colorScheme.onSecondary,
        ),
      AppButtonVariant.secondary => ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: theme.colorScheme.secondary,
          elevation: 0,
          side: const BorderSide(color: TravelAppColors.border),
        ),
      AppButtonVariant.danger => ElevatedButton.styleFrom(
          backgroundColor: theme.colorScheme.error,
          foregroundColor: theme.colorScheme.onError,
        ),
    };

    final effectiveChild = isLoading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
        : child;
    final effectiveOnPressed = isLoading ? null : onPressed;

    final buttonIcon = icon;
    if (buttonIcon != null) {
      return ElevatedButton.icon(
        onPressed: effectiveOnPressed,
        style: style,
        icon: buttonIcon,
        label: effectiveChild,
      );
    }

    return ElevatedButton(
      onPressed: effectiveOnPressed,
      style: style,
      child: effectiveChild,
    );
  }
}
