import 'package:flutter/material.dart';

class TimelineStepItem extends StatelessWidget {
  final Widget icon;
  final Widget content;
  final bool isFirst;
  final bool isLast;
  final Color? lineColor;

  const TimelineStepItem({
    super.key,
    required this.icon,
    required this.content,
    this.isFirst = false,
    this.isLast = false,
    this.lineColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLineColor =
        lineColor ?? theme.colorScheme.outlineVariant.withValues(alpha: 0.5);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline Column
          SizedBox(
            width: 40,
            child: Column(
              children: [
                // Top line
                Container(
                  width: 2,
                  height: 16, // Top padding for icon
                  color: isFirst ? Colors.transparent : effectiveLineColor,
                ),
                // Icon
                icon,
                // Bottom line
                Expanded(
                  child: Container(
                    width: 2,
                    color: isLast ? Colors.transparent : effectiveLineColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Content Column
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24), // Spacing between steps
              child: content,
            ),
          ),
        ],
      ),
    );
  }
}
