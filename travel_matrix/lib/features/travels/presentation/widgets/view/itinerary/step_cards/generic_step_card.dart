import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/step_card_view_models.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

import '../../../expandable_section.dart';

/// Card for displaying a generic or placeholder step in the itinerary.
///
/// Consumes a [GenericStepViewCardModel] to show a basic title and whether
/// it is a draft.
///
/// Layout: Expandable card with a simple header and placeholder content.
class GenericStepCard extends StatefulWidget {
  final GenericStepViewCardModel step;
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
    final l10n = AppLocalizations.of(context)!;
    final isPlaceholder = widget.step.isDraft;

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
                  color: isPlaceholder ? theme.colorScheme.surfaceContainer : theme.colorScheme.surfaceContainerHighest,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaceholder ? Icons.edit_note : Icons.help_outline,
                  color: isPlaceholder ? theme.colorScheme.onSurfaceVariant : theme.colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  widget.step.title.isNotEmpty
                      ? widget.step.title
                      : (isPlaceholder ? l10n.draftStepTitle : l10n.unknownStepTitle),
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
        content: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: Column(
            children: [
              const Divider(),
              const SizedBox(height: 8),
              Text(l10n.stepDetailsUnavailable),
            ],
          ),
        ),
      ),
    );
  }
}

