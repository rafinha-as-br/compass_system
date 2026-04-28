import 'package:flutter/material.dart';

class TimelineStepItem extends StatelessWidget {
  final Widget icon;
  final Widget content;
  final bool isFirst;
  final bool isLast;
  final Color? lineColor;
  final DateTime? date;

  const TimelineStepItem({
    super.key,
    required this.icon,
    required this.content,
    this.isFirst = false,
    this.isLast = false,
    this.lineColor,
    this.date,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLineColor =
        lineColor ?? theme.colorScheme.outlineVariant.withValues(alpha: 0.8);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Column
          SizedBox(
            width: 50, // Slightly wider for date alignment
            child: Column(
              children: [
                // Top line
                Container(
                  width: 3, // Slightly thicker
                  height: 12, // Top padding for icon
                  decoration: BoxDecoration(
                    color: isFirst ? Colors.transparent : effectiveLineColor,
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(2)),
                  ),
                ),
                // Icon
                icon,
                const SizedBox(height: 4),
                // Date
                if (date != null)
                  Text(
                    '${date!.day.toString().padLeft(2, '0')}/${date!.month.toString().padLeft(2, '0')}',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                    ),
                  ),
                const SizedBox(height: 4),
                // Bottom line
                Expanded(
                  child: Container(
                    width: 3, // Slightly thicker
                    decoration: BoxDecoration(
                      color: isLast ? Colors.transparent : effectiveLineColor,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Content Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32), // More spacing between steps
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
