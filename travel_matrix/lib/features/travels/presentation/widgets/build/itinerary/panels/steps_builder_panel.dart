import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/editor/itinerary_editor_controller.dart';

import '../../../../models/view_models/itinerary_steps_view_models.dart';

/// This panel is responsible for building/editing an [ItineraryStepViewModel],
///
/// Note: If there isn't a first and last step created, the user is forced to create the first and last step.
class StepsBuilderPanel extends StatefulWidget {
  const StepsBuilderPanel({super.key});

  @override
  State<StepsBuilderPanel> createState() => _StepsBuilderPanelState();
}

class _StepsBuilderPanelState extends State<StepsBuilderPanel> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }

}

/// Navigation bar at the top of the center panel showing prev/next/add controls.
class _StepNavigator extends StatelessWidget {
  const _StepNavigator({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ItineraryEditorController>(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: isFirst ? null : editor.goToPreviousStep,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Previous Step',
        ),
        Text(
          'Step — ${step.title.isNotEmpty ? step.title : '#${selectedIndex + 1}'}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        isLast
            ? IconButton(
          onPressed: _addStep,
          icon: const Icon(Icons.add),
          tooltip: 'Add Step',
          color: theme.colorScheme.secondary,
        )
            : IconButton(
          onPressed: editor.goToNextStep,
          icon: const Icon(Icons.arrow_forward),
          tooltip: 'Next Step',
        ),
      ],
    );
  }
}

/// Renders the correct form widget based on the current step's type.
class _StepForm extends StatelessWidget {
  const _StepForm({super.key, required this.step});

  final ItineraryStepViewModel step;

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ItineraryEditorController>(context);

    // hosting step form
    if(step is HostingStepViewModel){
      return const Placeholder();
    }

    // stop step form
    if(step is StopStepViewModel){
      return const Placeholder();
    }

    // travel segment step form
    if(step is TravelSegmentStepViewModel){
      return const Placeholder();
    }

    /// Empty state shown when no steps have been added yet.
    return const Placeholder();
  }


  /// Empty state shown when no steps have been added yet.
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Add your first step to begin building the itinerary.',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addStep,
            icon: const Icon(Icons.add),
            label: const Text('Add Step'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }

}

/// First & last step form widget.
/// Used only when creating a new itinerary
class _FirstLastStepForm extends StatelessWidget {
  const _FirstLastStepForm({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}








