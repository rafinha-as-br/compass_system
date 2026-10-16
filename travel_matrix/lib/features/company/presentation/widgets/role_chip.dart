import 'package:flutter/material.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

/// Chip OWNER/MEMBER usado na tabela e no diálogo do agente.
class RoleChip extends StatelessWidget {
  final String roleLabel;
  final bool isOwner;

  const RoleChip({super.key, required this.roleLabel, required this.isOwner});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isOwner ? theme.colorScheme.secondary : theme.semanticColors.success;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        roleLabel,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: isOwner ? theme.colorScheme.onSurface : color,
        ),
      ),
    );
  }
}
