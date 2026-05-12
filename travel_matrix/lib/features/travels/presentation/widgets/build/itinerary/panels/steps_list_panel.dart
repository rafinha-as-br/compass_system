import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/editor/itinerary_editor_controller.dart';
import 'package:travel_matrix/features/travels/presentation/view_models/itinerary_steps_view_models.dart';

/// Right panel displaying the ordered list of itinerary steps with
/// selection, reordering, hover-delete, and add step support.
class StepsListPanel extends StatelessWidget {
  final List<ItineraryStepViewModel> steps;
  final int selectedIndex;
  final VoidCallback onAddStep;

  const StepsListPanel({
    super.key,
    required this.steps,
    required this.selectedIndex,
    required this.onAddStep,
  });

  IconData _iconForStep(ItineraryStepViewModel step) {
    if (step is StopStepViewModel) return Icons.place;
    if (step is HostingStepViewModel) return Icons.hotel;
    if (step is TravelSegmentStepViewModel) return Icons.flight;
    return Icons.edit_note; // PlaceholderStep
  }

  @override
  Widget build(BuildContext context) {
    final itineraryEditorController = Provider.of<ItineraryEditorController>(context);
    final theme = Theme.of(context);

    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: theme.colorScheme.primary.withValues(alpha: 0.05),
            child: Text(
              'Steps (${steps.length})',
              style: theme.textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: steps.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No steps yet'),
                    ),
                  )
                : ReorderableListView.builder(
                    itemCount: steps.length,
                    onReorder: itineraryEditorController.reorderSteps,
                    itemBuilder: (context, index) {
                      final step = steps[index];
                      final isSelected = index == selectedIndex;
                      final displayTitle = step.title.isNotEmpty
                          ? step.title
                          : 'Step #${index + 1}';

                      return _StepListTile(
                        key: ValueKey(step.id),
                        index: index,
                        title: displayTitle,
                        icon: _iconForStep(step),
                        isSelected: isSelected,
                        onTap: () => itineraryEditorController.selectStep(index),
                        onDelete: () => itineraryEditorController.deleteStep(index),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// Single step tile with hover-to-reveal delete icon.
class _StepListTile extends StatefulWidget {
  final int index;
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _StepListTile({
    super.key,
    required this.index,
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
  });

  @override
  State<_StepListTile> createState() => _StepListTileState();
}

class _StepListTileState extends State<_StepListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: ListTile(
        selected: widget.isSelected,
        selectedTileColor:
            theme.colorScheme.secondary.withValues(alpha: 0.1),
        leading: CircleAvatar(
          radius: 14,
          backgroundColor: theme.colorScheme.primary,
          child: Icon(widget.icon,
              size: 14, color: theme.colorScheme.onPrimary),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: _isHovered
            ? IconButton(
                icon: Icon(Icons.delete_outline,
                    size: 18, color: theme.colorScheme.error),
                onPressed: widget.onDelete,
                tooltip: 'Delete step',
              )
            : null,
        onTap: widget.onTap,
      ),
    );
  }
}
