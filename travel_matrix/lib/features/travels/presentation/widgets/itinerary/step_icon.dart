import 'package:flutter/material.dart';

class StepIcon extends StatelessWidget {
  final IconData icon;
  final Color? color;
  final bool isCompleted;

  const StepIcon({
    super.key,
    required this.icon,
    this.color,
    this.isCompleted = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconColor = color ?? theme.colorScheme.primary;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isCompleted ? iconColor : theme.colorScheme.surface,
        shape: BoxShape.circle,
        border: Border.all(
          color: iconColor,
          width: 2,
        ),
        boxShadow: [
          if (isCompleted)
            BoxShadow(
              color: iconColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
        ],
      ),
      child: Icon(
        icon,
        size: 20,
        color: isCompleted ? theme.colorScheme.onPrimary : iconColor,
      ),
    );
  }
}
