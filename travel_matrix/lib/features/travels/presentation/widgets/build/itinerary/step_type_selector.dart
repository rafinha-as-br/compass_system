import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';

/// Renders the UI for selecting a step type.
class StepTypeSelector extends StatelessWidget {
  final Type selectedType;
  final ValueChanged<Type> onTypeSelected;
  final bool allowPlaceholder;

  const StepTypeSelector({
    super.key,
    required this.selectedType,
    required this.onTypeSelected,
    this.allowPlaceholder = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Choose step type:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            if (allowPlaceholder)
              _TypeCard(
                icon: Icons.help_outline,
                title: 'Placeholder',
                subtitle: 'Undecided step',
                isSelected: selectedType == PlaceHolderStepViewModel,
                onTap: () => onTypeSelected(PlaceHolderStepViewModel),
              ),
            _TypeCard(
              icon: Icons.place,
              title: 'Stop',
              subtitle: 'Place to visit',
              isSelected: selectedType == StopStepViewModel,
              onTap: () => onTypeSelected(StopStepViewModel),
            ),
            _TypeCard(
              icon: Icons.hotel,
              title: 'Hosting',
              subtitle: 'Place to stay',
              isSelected: selectedType == HostingStepViewModel,
              onTap: () => onTypeSelected(HostingStepViewModel),
            ),
            _TypeCard(
              icon: Icons.route,
              title: 'Travel Segment',
              subtitle: 'Moving around',
              isSelected: selectedType == TravelSegmentStepViewModel,
              onTap: () => onTypeSelected(TravelSegmentStepViewModel),
            ),
          ],
        ),
      ],
    );
  }
}

class _TypeCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _TypeCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 160,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primary.withValues(alpha: 0.08) : Colors.transparent,
          border: Border.all(
            color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(
                  icon,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
                ),
                if (isSelected)
                  Icon(
                    Icons.check_circle,
                    color: colorScheme.primary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? colorScheme.primary : colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
