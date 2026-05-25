import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/step_card_view_models.dart';

import '../../../expandable_section.dart';

/// Card for displaying a Hosting step in the itinerary.
///
/// Consumes a [HostingViewCardModel] to show place name, address,
/// and check-in/check-out dates.
///
/// Layout: Expandable card with a header (icon, place name, title) and content (details).
class HostingCard extends StatefulWidget {
  final HostingViewCardModel hosting;
  final bool isInitialExpanded;

  const HostingCard({
    super.key,
    required this.hosting,
    this.isInitialExpanded = false,
  });

  @override
  State<HostingCard> createState() => _HostingCardState();
}

class _HostingCardState extends State<HostingCard> {
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
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.hotel, color: theme.colorScheme.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.hosting.placeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      widget.hosting.title,
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
            children: [
              const Divider(),
              const SizedBox(height: 8),
              _DetailRow(icon: Icons.location_on_outlined, label: 'Address', value: widget.hosting.address),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(child: _DetailRow(icon: Icons.login, label: 'Check-in', value: '${widget.hosting.checkIn.day}/${widget.hosting.checkIn.month}')),
                  Expanded(child: _DetailRow(icon: Icons.logout, label: 'Check-out', value: '${widget.hosting.checkOut.day}/${widget.hosting.checkOut.month}')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            Text(value, style: theme.textTheme.bodySmall),
          ],
        ),
      ],
    );
  }
}
