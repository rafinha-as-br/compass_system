import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/transports_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/change_type_dialog.dart';
import '../../../../models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/shared/widgets/text_fields.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/hosting_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/stop_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/travel_segment_form_widget.dart';

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
            onDelete: () => removeStep(selectedIndex),
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
    required this.onDelete,
    required this.selectedIndex,
  });

  /// step for render the form
  final ItineraryStepViewModel step;
  /// Callback to change the step type
  final void Function(ItineraryStepViewModel newStep) onStepTypeChanged;
  /// Callback to delete the step
  final VoidCallback onDelete;
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
          name: 'Place name',
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
      formContent = HostingFormWidget(
        hosting: step as HostingStepViewModel,
        onChanged: onStepTypeChanged,
        onDelete: onDelete,
      );
    }
    // stop step form
    else if(step is StopStepViewModel){
      formContent = StopFormWidget(
        stop: step as StopStepViewModel,
        onChanged: onStepTypeChanged,
        onDelete: onDelete,
      );
    }
    // travel segment step form
    else if(step is TravelSegmentStepViewModel){
      formContent = TravelSegmentFormWidget(
        segment: step as TravelSegmentStepViewModel,
        onChanged: onStepTypeChanged,
        onDelete: onDelete,
      );
    } else {
      /// Empty state shown when no steps have been added yet.
      formContent = const Placeholder();
    }

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(
            color: step.problems != null ? Colors.yellow
                :
            Colors.transparent
        )
      ),
      child: Column(
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _BasicStepForm(step: step, onChanged: onStepTypeChanged),
                  const SizedBox(height: 16),
                  formContent,
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BasicStepForm extends StatefulWidget {
  final ItineraryStepViewModel step;
  final ValueChanged<ItineraryStepViewModel> onChanged;

  const _BasicStepForm({
    required this.step,
    required this.onChanged,
  });

  @override
  State<_BasicStepForm> createState() => _BasicStepFormState();
}

class _BasicStepFormState extends State<_BasicStepForm> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _startDateCtrl;
  late final TextEditingController _finishDateCtrl;

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.step.title);
    _startDateCtrl = TextEditingController(text: _formatDate(widget.step.startDate));
    _finishDateCtrl = TextEditingController(text: _formatDate(widget.step.finishDate));
  }

  @override
  void didUpdateWidget(covariant _BasicStepForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.step.id != widget.step.id) {
      _titleCtrl.text = widget.step.title;
      _startDateCtrl.text = _formatDate(widget.step.startDate);
      _finishDateCtrl.text = _formatDate(widget.step.finishDate);
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _startDateCtrl.dispose();
    _finishDateCtrl.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) =>
      '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

  Future<void> _pickDate({required bool isStart}) async {
    final initial = isStart ? widget.step.startDate : widget.step.finishDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      if (isStart) {
        _startDateCtrl.text = _formatDate(picked);
        widget.onChanged(widget.step.copyWith(startDate: picked));
      } else {
        _finishDateCtrl.text = _formatDate(picked);
        widget.onChanged(widget.step.copyWith(finishDate: picked));
      }
    }
  }

  void _onTitleChanged(String value) {
    widget.onChanged(widget.step.copyWith(title: value));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomFormField.text(
          label: 'Step Title',
          enabled: true,
          controller: _titleCtrl,
          onChanged: _onTitleChanged,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomFormField.date(
                label: 'Start Date',
                enabled: true,
                controller: _startDateCtrl,
                onTap: () => _pickDate(isStart: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomFormField.date(
                label: 'End Date',
                enabled: true,
                controller: _finishDateCtrl,
                onTap: () => _pickDate(isStart: false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
