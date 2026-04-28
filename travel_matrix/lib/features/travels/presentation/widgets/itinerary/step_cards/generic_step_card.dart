import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';
import '../../shared/expandable_section.dart';

class GenericStepCard extends StatefulWidget {
  final ItineraryStep step;
  final bool isInitialExpanded;

  const GenericStepCard({
    super.key,
    required this.step,
    this.isInitialExpanded = false,
  });

  @override
  State<GenericStepCard> createState() => _GenericStepCardState();
}

class _GenericStepCardState extends State<GenericStepCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isInitialExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPlaceholder = widget.step is PlaceholderStep;

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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isPlaceholder ? Colors.grey.shade200 : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaceholder ? Icons.edit_note : Icons.help_outline,
                  color: isPlaceholder ? Colors.grey : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.step.title.isNotEmpty ? widget.step.title : (isPlaceholder ? 'Draft Step' : 'Unknown Step'),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: isPlaceholder ? FontWeight.normal : FontWeight.bold,
                    fontStyle: isPlaceholder ? FontStyle.italic : null,
                  ),
                ),
              ),
              Icon(
                _isExpanded ? Icons.expand_less : Icons.expand_more,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
        content: const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              Divider(),
              SizedBox(height: 8),
              Text('Additional details for this step are not yet available.'),
            ],
          ),
        ),
      ),
    );
  }
}
