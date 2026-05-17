import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:uuid/uuid.dart';

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
  final void Function(ItineraryStepViewModel newStep) addStep;
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
  /// Next step
  final void Function() goToNextStep;
  /// Add step
  final void Function(ItineraryStepViewModel newStep) addStep;

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
          'Step — ${step.title.isNotEmpty ? step.title : '#${selectedIndex + 1}'}',
          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),

        /// Next step or add step navigator button
        isLastStep ?
          IconButton(
            onPressed: (){

              // add a placeholder step
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
  });

  /// step for render the form
  final ItineraryStepViewModel step;
  /// Callback to change the step type
  final void Function(ItineraryStepViewModel newStep) onStepTypeChanged;

  Future<void> _handleTypeChange(BuildContext context, Type newType) async {
    if (step.runtimeType == newType) return;

    // Show dialog if not a PlaceHolderStepViewModel
    if (step is! PlaceHolderStepViewModel) {
      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Change Step Type?'),
          content: const Text('Changing the step type will result in the loss of specific data entered for the current step. Do you wish to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Proceed'),
            ),
          ],
        ),
      );

      if (confirm != true) return;
    }

    ItineraryStepViewModel newStep;
    final title = step.title;
    final startDate = step.startDate;
    final finishDate = step.finishDate;
    final position = step.position;

    if (newType == PlaceHolderStepViewModel) {
      newStep = ItineraryStepViewModel.newPlaceHolder(title, startDate, finishDate, position);
    } else if (newType == StopStepViewModel) {
      newStep = ItineraryStepViewModel.newStop(title, startDate, finishDate, position, '', '', []);
    } else if (newType == HostingStepViewModel) {
      newStep = ItineraryStepViewModel.newHosting(title, startDate, finishDate, position, '', '', startDate, finishDate);
    } else if (newType == TravelSegmentStepViewModel) {
      final defaultTransport = RentalCarViewModel(
        id: const Uuid().v4(),
        vehicleModelName: '',
        vehicleLicensePlate: '',
        companyName: '',
        checkInDate: startDate,
        checkOutDate: finishDate,
      );
      newStep = ItineraryStepViewModel.newTravelSegment(title, startDate, finishDate, position, '', '', defaultTransport);
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
