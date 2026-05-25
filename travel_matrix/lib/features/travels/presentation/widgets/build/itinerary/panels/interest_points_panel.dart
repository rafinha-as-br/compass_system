import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/route_view_model.dart';

/// build model class for [InterestPointsPanel]
class InterestPointPanelBuildModel{
  final InterestPointViewModel interestPoint;
  final bool isChecked;
  InterestPointPanelBuildModel({
    required this.interestPoint,
    required this.isChecked,
  });
}


/// Left panel displaying interest points from the route with checklist behavior.
class InterestPointsPanel extends StatelessWidget {
  const InterestPointsPanel({
    super.key,
    required this.interestPoints,
    required this.onToggle,
  });

  /// interests points for displaying in the panel
  final List<InterestPointPanelBuildModel> interestPoints;
  /// on toggle callback method used to toggle the check state of an interest point
  final void Function(String id) onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 250,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            child: Text(
              'Interest Points',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: interestPoints.isEmpty
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text('No interest points'),
              ),
            )
                : ListView.builder(
              itemCount: interestPoints.length,
              itemBuilder: (context, index) {
                final poi = interestPoints[index];

                return ListTile(
                  dense: true,
                  leading: Icon(
                    poi.isChecked
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    size: 20,
                    color: poi.isChecked
                        ? const Color(0xFF2E7D5B)
                        : theme.colorScheme.secondary,
                  ),
                  title: Text(
                    poi.interestPoint.name,
                    style: TextStyle(
                      fontSize: 13,
                      decoration: poi.isChecked
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  subtitle: Text(
                    poi.interestPoint.description,
                    style: const TextStyle(fontSize: 11),
                  ),
                  onTap: () => onToggle(poi.interestPoint.id),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}