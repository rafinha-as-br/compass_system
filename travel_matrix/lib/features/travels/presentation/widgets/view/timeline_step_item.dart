import 'package:flutter/material.dart';

class TimelineStepItem extends StatelessWidget {
  final Widget icon;
  final Widget content;
  final bool isFirst;
  final bool isLast;
  final Color? lineColor;
  final DateTime? date;
  final String? typeLabel;

  const TimelineStepItem({
    super.key,
    required this.icon,
    required this.content,
    this.isFirst = false,
    this.isLast = false,
    this.lineColor,
    this.date,
    this.typeLabel,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveLineColor =
        lineColor ?? theme.colorScheme.outlineVariant.withValues(alpha: 0.8);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 600;
        final leftColumnWidth = isDesktop ? 72.0 : 50.0;
        final bottomPadding = isDesktop ? 32.0 : 24.0;
        final fontSize = isDesktop ? 12.0 : 10.0;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Timeline Column
              SizedBox(
                width: leftColumnWidth,
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
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    if (typeLabel != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        typeLabel!.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontSize: fontSize - 1,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: theme.colorScheme.primary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
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
                  padding: EdgeInsets.only(bottom: bottomPadding),
                  child: content,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
