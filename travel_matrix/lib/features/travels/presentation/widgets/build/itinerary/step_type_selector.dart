import 'package:flutter/material.dart';

/// The three concrete step types available.
enum StepType { stop, hosting, travelSegment }

/// TODO: REVIEW THIS HOLE WIDGET
/// - Must be called when there is a Step of PlaceHolder type, must go down below the placeholder data display
/// - With every step type has an icon now, review the implementation of this widget


/// Renders the UI for an untyped placeholder step, allowing the user
/// to set a title and choose which type of step to create.
class StepTypeSelector extends StatelessWidget {
  final String title;
  final ValueChanged<String> onTitleChanged;
  final ValueChanged<StepType> onTypeSelected;
  final VoidCallback onDelete;

  const StepTypeSelector({
    super.key,
    required this.title,
    required this.onTitleChanged,
    required this.onTypeSelected,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'New Step',
          style: theme.textTheme.titleMedium
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: TextEditingController(text: title),
          decoration: const InputDecoration(
            labelText: 'Step Title',
            border: OutlineInputBorder(),
          ),
          onChanged: onTitleChanged,
        ),
        const SizedBox(height: 24),
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
            _TypeButton(
              icon: Icons.place,
              label: 'Add Stop',
              color: theme.colorScheme.primary,
              onPressed: () => onTypeSelected(StepType.stop),
            ),
            _TypeButton(
              icon: Icons.hotel,
              label: 'Add Hosting',
              color: theme.colorScheme.primary,
              onPressed: () => onTypeSelected(StepType.hosting),
            ),
            _TypeButton(
              icon: Icons.flight,
              label: 'Add Travel Segment',
              color: theme.colorScheme.primary,
              onPressed: () => onTypeSelected(StepType.travelSegment),
            ),
          ],
        ),
        const SizedBox(height: 32),
        OutlinedButton.icon(
          onPressed: onDelete,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Delete Step'),
          style: OutlinedButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
            side: BorderSide(color: theme.colorScheme.error),
          ),
        ),
      ],
    );
  }
}

class _TypeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onPressed;

  const _TypeButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    );
  }
}
