import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';

/// Left panel displaying interest points from the route with checklist behavior.
class InterestPointsPanel extends StatelessWidget {
  final List<InterestPoint> interestPoints;
  final Set<String> checkedIds;
  final ValueChanged<String> onToggle;

  const InterestPointsPanel({
    super.key,
    required this.interestPoints,
    required this.checkedIds,
    required this.onToggle,
  });

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
                      final isChecked = checkedIds.contains(poi.id);

                      return ListTile(
                        dense: true,
                        leading: Icon(
                          isChecked
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: 20,
                          color: isChecked
                              ? const Color(0xFF2E7D5B)
                              : theme.colorScheme.secondary,
                        ),
                        title: Text(
                          poi.name,
                          style: TextStyle(
                            fontSize: 13,
                            decoration: isChecked
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        subtitle: Text(
                          poi.description,
                          style: const TextStyle(fontSize: 11),
                        ),
                        onTap: () => onToggle(poi.id),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
