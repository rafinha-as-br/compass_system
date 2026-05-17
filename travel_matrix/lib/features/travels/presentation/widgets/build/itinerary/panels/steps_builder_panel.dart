import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/change_type_dialog.dart';
import '../../../../models/view_models/itinerary_steps_view_models.dart';

/// This panel is responsible for building/editing an [ItineraryStepViewModel] list,
/// receiving a [ItineraryStepsBuildModel] as input for consuming.
///
/// Layout: one column fixed structure
/// - [_StepNavigator] Responsible for controlling the navigation between steps.
/// - [_StepFormRender] Responsible for step form render
///
/// NOTE: The user can't delete first and last steps, they are always pinned.
class StepsBuilderPanel extends StatelessWidget {
  const StepsBuilderPanel({
    super.key,
    required this.steps,
    required this.selectedIndex,
    required this.goToPreviousStep,
    required this.goToNextStep,
    required this.addStep,
    required this.updateStep,
    required this.removeStep,
  });

  /// Constructor build model class for [StepsBuilderPanel],
  final ItineraryStepsBuildModel steps;

  /// Index value for the current selected step
  final int selectedIndex;

  /// Previous step callback method [_StepNavigator]
  final void Function() goToPreviousStep;
  /// Next step callback method [_StepNavigator]
  final void Function() goToNextStep;
  /// Add step callback method for [_StepNavigator]
  final void Function({required ItineraryStepViewModel newStep}) addStep;
  /// Update step callback method for [_StepFormRender]
  final void Function(int index, ItineraryStepViewModel updatedStep) updateStep;
  /// Remove step callback method for [_StepFormRender]
  final void Function(int index) removeStep;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _StepNavigator(
          goToPreviousStep: goToPreviousStep,
          goToNextStep: goToNextStep,
          addStep: addStep,
          step: steps.stepsList[selectedIndex],
          selectedIndex: selectedIndex,
        ),
        Expanded(
          child: _StepFormRender(
            step: steps.stepsList[selectedIndex],
            onStepTypeChanged: (newStep) => updateStep(selectedIndex, newStep),
            selectedIndex: selectedIndex,
          )
        ),
      ],
    );
  }
}

/// Navigation widget for the [StepsBuilderPanel],
/// responsible for controlling the navigation between steps, with prev/next/add controls
class _StepNavigator extends StatelessWidget {
  const _StepNavigator({
    required this.goToPreviousStep,
    required this.goToNextStep,
    required this.addStep,
    required this.step,
    required this.selectedIndex,
  });

  /// Previous step method
  final void Function() goToPreviousStep;
  /// Next step method
  final void Function() goToNextStep;
  /// Add step method
  final void Function({required ItineraryStepViewModel newStep}) addStep;

  /// Step for render the navigation
  final ItineraryStepViewModel step;

  /// Index value for the current selected step
  final int selectedIndex;

  @override
  Widget build(BuildContext context) {

    final isFirstStep = step.position == StepPosition.start;
    final isLastStep = step.position == StepPosition.finish;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [

        /// Previous step navigator button

        isFirstStep ?
          IconButton(
            onPressed: (){},
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Previous Step',
            disabledColor: Theme.of(context).colorScheme.secondary,
            isSelected: false,
          )
            :
          IconButton(
            onPressed: goToPreviousStep,
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Previous Step',
          ),

        /// Step title
        Text(
          step.title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),

        /// Next step or add step navigator button
        isLastStep ?
          IconButton(
            onPressed: (){
              // add a placeholder step, guarantees that the title is not empty
              addStep(
                newStep: ItineraryStepViewModel.newPlaceHolder(
                  currentIndex: selectedIndex + 1,
                  position:  StepPosition.middle,
                )
              );
            },
            icon: const Icon(Icons.add),
            tooltip: 'Add Step',
            color: Theme.of(context).colorScheme.secondary,
          )
            :
          IconButton(
            onPressed: goToNextStep,
            icon: const Icon(Icons.arrow_forward),
            tooltip: 'Next Step',
          ),
      ],
    );
  }
}

/// Step form render widget, responsible for rendering the correct form widget based on the current step's type.
class _StepFormRender extends StatelessWidget {
  const _StepFormRender({
    required this.step,
    required this.onStepTypeChanged,
    required this.selectedIndex,
  });

  /// step for render the form
  final ItineraryStepViewModel step;
  /// Callback to change the step type
  final void Function(ItineraryStepViewModel newStep) onStepTypeChanged;
  /// Selected index for the current step
  final int selectedIndex;

  /// Type changer handler, called when the user changes the step type, verifying if the change is valid.
  Future<void> _handleTypeChange(BuildContext context, Type newType) async {
    if (step.runtimeType == newType) return;

    // Show dialog if not a PlaceHolderStepViewModel
    if (step is! PlaceHolderStepViewModel) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => ChangeStepTypeDialog(),
      );

      if (confirm != true) return;
    }

    ItineraryStepViewModel newStep;
    final title = step.title;
    final startDate = step.startDate;
    final finishDate = step.finishDate;
    final position = step.position;

    if (newType == PlaceHolderStepViewModel) {
      newStep = ItineraryStepViewModel.newPlaceHolder(currentIndex: selectedIndex, position: position);
    } else if (newType == StopStepViewModel) {
      newStep = ItineraryStepViewModel.newStop(
          title: title,
          startDate: startDate,
          finishDate: finishDate,
          position: position,
          description: '',
          experiences: [],
      );
    } else if (newType == HostingStepViewModel) {
      newStep = ItineraryStepViewModel.newHosting(
          title: title,
          startDate: startDate,
          finishDate: finishDate,
          position: position,
          placeName: 'Place name',
          address: 'Place address',
          checkIn: DateTime.now(),
          checkOut: DateTime.now().add(const Duration(days: 1)),
      );
    } else if (newType == TravelSegmentStepViewModel) {
      final defaultTransport = TransportViewModel.newPlaceHolder();
      newStep = ItineraryStepViewModel.newTravelSegment(
          title: title,
          startDate: startDate,
          finishDate: finishDate,
          position: position,
          startPoint: 'Starting point',
          finishPoint: 'Finish point',
          transport: defaultTransport
      );
    } else {
      return;
    }

    onStepTypeChanged(newStep);
  }

  @override
  Widget build(BuildContext context) {
    Widget formContent;

    // hosting step form
    if(step is HostingStepViewModel){
      formContent = const Placeholder();
    }
    // stop step form
    else if(step is StopStepViewModel){
      formContent = const Placeholder();
    }
    // travel segment step form
    else if(step is TravelSegmentStepViewModel){
      formContent = const Placeholder();
    } else {
      /// Empty state shown when no steps have been added yet.
      formContent = const Placeholder();
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: DropdownButtonFormField<Type>(
            initialValue: step.runtimeType,
            decoration: const InputDecoration(
              labelText: 'Step Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: PlaceHolderStepViewModel,
                child: Text('Placeholder'),
              ),
              DropdownMenuItem(
                value: StopStepViewModel,
                child: Text('Stop'),
              ),
              DropdownMenuItem(
                value: HostingStepViewModel,
                child: Text('Hosting'),
              ),
              DropdownMenuItem(
                value: TravelSegmentStepViewModel,
                child: Text('Travel Segment'),
              ),
            ],
            onChanged: (newType) {
              if (newType != null) {
                _handleTypeChange(context, newType);
              }
            },
          ),
        ),
        Expanded(child: formContent),
      ],
    );
  }

}
