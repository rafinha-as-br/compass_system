import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';
import '../../shared/expandable_section.dart';

class StopCard extends StatefulWidget {
  final Stop stop;
  final bool isInitialExpanded;

  const StopCard({
    super.key,
    required this.stop,
    this.isInitialExpanded = false,
  });

  @override
  State<StopCard> createState() => _StopCardState();
}

class _StopCardState extends State<StopCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: _isExpanded ? 2 : 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: ExpandableSection(
        isExpanded: _isExpanded,
        onTap: () => setState(() => _isExpanded = !_isExpanded),
        header: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Image or Icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.location_city, color: Colors.orange),
              ),
              const SizedBox(width: 16),
              // Name and Location
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.stop.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.stop.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
        content: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(),
              const SizedBox(height: 8),
              if (widget.stop.description.isNotEmpty) ...[
                Text(
                  widget.stop.description,
                  style: theme.textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),
              ],
              if (widget.stop.experiences.isNotEmpty) ...[
                Text(
                  'Experiences',
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: widget.stop.experiences.map((exp) => Chip(
                    label: Text(exp, style: const TextStyle(fontSize: 11)),
                    backgroundColor: theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  )).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
