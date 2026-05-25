import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/step_card_view_models.dart';

import '../../../expandable_section.dart';

/// Card for displaying a Flight (Airplane) step in the itinerary.
///
/// Consumes a [FlightViewCardModel] to show departure/arrival airports,
/// flight number, airline, date, and gate details.
///
/// Layout: Expandable card with a header (airports, flight info) and content (date, gate).
class FlightCard extends StatefulWidget {
  final FlightViewCardModel flight;
  final bool isInitialExpanded;

  const FlightCard({
    super.key,
    required this.flight,
    this.isInitialExpanded = false,
  });

  @override
  State<FlightCard> createState() => _FlightCardState();
}

class _FlightCardState extends State<FlightCard> {
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
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _AirportInfo(
                    code: widget.flight.departureAirport,
                    label: 'Departure',
                    align: CrossAxisAlignment.start,
                  ),
                  Column(
                    children: [
                      Icon(Icons.flight_takeoff, color: theme.colorScheme.primary, size: 20),
                      const SizedBox(height: 4),
                      Container(
                        width: 80,
                        height: 1,
                        color: theme.colorScheme.outlineVariant,
                      ),
                    ],
                  ),
                  _AirportInfo(
                    code: widget.flight.arrivalAirport,
                    label: 'Arrival',
                    align: CrossAxisAlignment.end,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetadataItem(
                    icon: Icons.confirmation_number_outlined,
                    label: 'Flight',
                    value: widget.flight.flightNumber,
                  ),
                  _MetadataItem(
                    icon: Icons.business_outlined,
                    label: 'Airline',
                    value: widget.flight.flightCompany,
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: theme.colorScheme.primary,
                  ),
                ],
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _MetadataItem(
                    icon: Icons.door_sliding_outlined,
                    label: 'Gate',
                    value: widget.flight.departureGate,
                  ),
                  _MetadataItem(
                    icon: Icons.calendar_today_outlined,
                    label: 'Date',
                    value: '${widget.flight.flightDate.day}/${widget.flight.flightDate.month}',
                  ),
                  _MetadataItem(
                    icon: Icons.access_time_outlined,
                    label: 'Duration',
                    value: '---', // Could be calculated if arrival time was available
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AirportInfo extends StatelessWidget {
  final String code;
  final String label;
  final CrossAxisAlignment align;

  const _AirportInfo({
    required this.code,
    required this.label,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(
          code,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _MetadataItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _MetadataItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: theme.colorScheme.onSurface.withValues(alpha: 0.5))),
            Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }
}

