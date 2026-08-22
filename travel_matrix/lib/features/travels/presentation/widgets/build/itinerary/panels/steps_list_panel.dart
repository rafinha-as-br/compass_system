import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import '../../../../models/view_models/itinerary_steps_view_models.dart';

/// Right panel displaying the ordered list of itinerary steps with
/// selection, reordering, delete, and add step support.
/// Receives [ItineraryStepsBuildModel] as input for consuming.
class StepsListPanel extends StatelessWidget {
  /// Constructor build model class for [StepsListPanel]
  final ItineraryStepsBuildModel steps;
  /// Index value for the current selected step
  final int selectedIndex;
  /// Select [step] callback method
  final void Function(int index) onSelectStep;
  /// Add [step] callback method
  final void Function({required ItineraryStepViewModel newStep}) addStep;
  /// Reorder [steps] callback method
  final void Function(int oldIndex, int newIndex) onReorder;
  /// Delete [step] callback method
  final void Function(int index) onDeleteStep;

  const StepsListPanel({
    super.key,
    required this.steps,
    required this.selectedIndex,
    required this.onSelectStep,
    required this.addStep,
    required this.onReorder,
    required this.onDeleteStep,
  });


  @override
  Widget build(BuildContext context) {
    final stepsList = steps.stepsList;
    final l10n = AppLocalizations.of(context)!;

    return SizedBox(
      width: 280,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Steps list header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
            child: Text(
              l10n.stepsCountLabel(stepsList.length),
              style: Theme.of(context).textTheme.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
          ),

          // Reorderable list of steps
          Expanded(
            child: stepsList.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(l10n.noStepsYet),
                    ),
                  )
                : ReorderableListView.builder(
                    buildDefaultDragHandles: false,
                    itemCount: stepsList.length,
                    onReorder: onReorder,
                    itemBuilder: (context, index) {
                      final step = stepsList[index];
                      final isSelected = index == selectedIndex;
                      final isDraggable = step.position == StepPosition.middle;
                      return _StepListTile(
                        key: ValueKey(step.localId),
                        step: step,
                        isSelected: isSelected,
                        index: index,
                        isDraggable: isDraggable,
                        onSelectStep: onSelectStep,
                        onDeleteStep: () => onDeleteStep(index)
                      );
                    },
                  ),
          ),

          // Add step button
          ElevatedButton(
            onPressed: (){
              // add a placeholder step, guarantees that the title is not empty
              addStep(
                newStep: ItineraryStepViewModel.newPlaceHolder(
                  currentIndex: stepsList.length,
                  position: StepPosition.middle,
                )
              );
            },
            child: Text(l10n.addStep),
          ),

        ],
      ),
    );
  }
}

/// List tile to display a [step] on the [StepsListPanel].
class _StepListTile extends StatelessWidget {
  /// Step to be displayed on the list tile
  final ItineraryStepViewModel step;
  /// Boolean to indicate if the [step] is selected
  final bool isSelected;
  /// Step index value
  final int index;
  /// Whether this step can be dragged to reorder
  final bool isDraggable;
  /// Select [step] callback method
  final void Function(int index) onSelectStep;
  /// Delete [step] callback method
  final VoidCallback onDeleteStep;

  const _StepListTile({
    super.key,
    required this.step,
    required this.isSelected,
    required this.index,
    required this.isDraggable,
    required this.onSelectStep,
    required this.onDeleteStep,
  });

  @override
  Widget build(BuildContext context) {

    final hasProblems = step.problems != null && step.problems!.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        border: hasProblems
            ? Border(
                left: BorderSide(color: Colors.amber.shade700, width: 4.0),
              )
            : null,
      ),
      child: ListTile(
        selected: isSelected,
        selectedTileColor: Theme.of(context).colorScheme.secondary.withValues(alpha: 0.1),
        leading: isDraggable
            ? ReorderableDragStartListener(
                index: index,
                child: const Icon(Icons.drag_handle, size: 20),
              )
            : CircleAvatar(
                radius: 14,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Icon(
                  step.icon,
                  size: 14,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                step.title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (hasProblems) ...[
              const SizedBox(width: 6),
              Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amber.shade700),
            ],
          ],
        ),
        trailing: IconButton(
          icon: Icon(
            Icons.delete_outline,
            size: 18,
            color: Theme.of(context).colorScheme.error,
          ),
          onPressed: onDeleteStep,
          tooltip: 'Delete step',
        ),
        onTap: () => onSelectStep(index),
      ),
    );
  }

}
