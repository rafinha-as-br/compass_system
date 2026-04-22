import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';
import 'step_icon.dart';
import 'expandable_step_card.dart';
import 'timeline_step_item.dart';

class ItineraryTimeline extends StatelessWidget {
  final List<ItineraryStep> steps;

  const ItineraryTimeline({
    super.key,
    required this.steps,
  });

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text('No steps in the itinerary.'),
        ),
      );
    }

    return Column(
      children: steps.asMap().entries.map((entry) {
        final index = entry.key;
        final step = entry.value;

        return TimelineStepItem(
          isFirst: index == 0,
          isLast: index == steps.length - 1,
          icon: _buildStepIcon(step),
          content: _buildStepCard(context, step, index),
        );
      }).toList(),
    );
  }

  Widget _buildStepIcon(ItineraryStep step) {
    IconData iconData = Icons.help_outline;
    Color? color;

    if (step is Stop) {
      iconData = Icons.place;
      color = Colors.orange;
    } else if (step is Hosting) {
      iconData = Icons.hotel;
      color = Colors.blue;
    } else if (step is TravelSegment) {
      iconData = Icons.flight;
      color = Colors.green;
    } else if (step is PlaceholderStep) {
      iconData = Icons.edit_note;
      color = Colors.grey;
    }

    return StepIcon(
      icon: iconData,
      color: color,
      isCompleted: step.finished,
    );
  }

  Widget _buildStepCard(BuildContext context, ItineraryStep step, int index) {
    String title = step.title.isNotEmpty ? step.title : 'Step ${index + 1}';
    String? subtitle;
    Widget? details;

    if (step is Stop) {
      subtitle = step.name;
      details = _buildStopDetails(step);
    } else if (step is Hosting) {
      subtitle = step.name;
      details = _buildHostingDetails(step);
    } else if (step is TravelSegment) {
      subtitle = '${step.startPoint} ➔ ${step.finishPoint}';
      details = _buildTravelSegmentDetails(step);
    } else if (step is PlaceholderStep) {
      subtitle = 'Draft Step';
    }

    return ExpandableStepCard(
      title: title,
      subtitle: subtitle,
      content: details,
    );
  }

  Widget _buildStopDetails(Stop stop) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (stop.description.isNotEmpty) ...[
          Text(stop.description),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Widget _buildHostingDetails(Hosting hosting) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailItem(icon: Icons.location_on, label: 'Address', value: hosting.address),
      ],
    );
  }

  Widget _buildTravelSegmentDetails(TravelSegment segment) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DetailItem(icon: Icons.compare_arrows, label: 'Route', value: '${segment.startPoint} to ${segment.finishPoint}'),
        const SizedBox(height: 8),
        _DetailItem(icon: Icons.directions_bus, label: 'Transport', value: segment.transport.runtimeType.toString()),
      ],
    );
  }
}

class _DetailItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _DetailItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 16, color: theme.colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
}
