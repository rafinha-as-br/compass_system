import 'package:flutter/material.dart';

/// Breadcrumb-style navigation indicator displayed at the top of screen content.
/// Reflects the current navigation hierarchy dynamically.
class BreadcrumbBar extends StatelessWidget {
  final List<String> items;

  const BreadcrumbBar({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(color: theme.dividerColor, width: 1),
        ),
      ),
      child: Row(
        children: _buildBreadcrumbs(context),
      ),
    );
  }

  List<Widget> _buildBreadcrumbs(BuildContext context) {
    final theme = Theme.of(context);
    final widgets = <Widget>[];

    for (int i = 0; i < items.length; i++) {
      final isLast = i == items.length - 1;

      widgets.add(
        Text(
          items[i],
          style: TextStyle(
            fontSize: 13,
            fontWeight: isLast ? FontWeight.w600 : FontWeight.w400,
            color: isLast
                ? theme.colorScheme.onSurface
                : theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      );

      if (!isLast) {
        widgets.add(
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Icon(
              Icons.chevron_right,
              size: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
            ),
          ),
        );
      }
    }

    return widgets;
  }
}
