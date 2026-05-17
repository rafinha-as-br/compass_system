import 'package:flutter/cupertino.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/itinerary_build_page.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/interest_points_panel.dart';

import '../../models/view_models/itinerary_steps_view_models.dart';
import '../../models/view_models/route_view_model.dart';

/// Controller responsible for controlling the [ItineraryBuildPage] UI, and its children.
class ItineraryEditorController extends ChangeNotifier {

  /// Editor controller constructor.
  /// It automatically creates the first and last steps if the [steps] list is null.
  ItineraryEditorController({
    required this.interestPoints,
    required List<ItineraryStepViewModel>? steps,
  }){

    // Null verificator to activate the first and last steps creation
    if(steps != null){
      _stepsList = steps;
      _selectedStepIndex = steps.length - 1;
    }else{
      createFirstAndLastSteps();
    }

  }

  /// Public interests points list
  final List<InterestPointViewModel> interestPoints;
  /// private interests points checklist id list,
  /// used for filtering the checked state of interest points on [InterestPointsPanel].
  /// The ID used for filtering is the
  final Set<String> _checkedInterestPointIds = {};
  /// Getter for interest points build model for [InterestPointsPanel]
  List<InterestPointPanelBuildModel> get interestPointPanelModels {
    return List.unmodifiable(
      interestPoints.map(
            (element) => InterestPointPanelBuildModel(
          interestPoint: element,
          isChecked: _checkedInterestPointIds.contains(
            element.id,
          ),
        ),
      ),
    );
  }
  /// toggle interest point check state
  void toggleInterestPoint(String id) {
    if (_checkedInterestPointIds.contains(id)) {
      _checkedInterestPointIds.remove(id);
    } else {
      _checkedInterestPointIds.add(id);
    }
    notifyListeners();
  }


  /// Steps list, used to build the steps list panel, can be null in case of creating a new itinerary.
  List<ItineraryStepViewModel> _stepsList = [];
  /// Private selected index value
  int _selectedStepIndex = 0;
  /// Getter for selected Step index
  int get selectedStepIndex => _selectedStepIndex;
  /// Getter for [ItineraryStepsBuildModel] list for [StepsBuilderPanel]
  ItineraryStepsBuildModel get stepsBuildModel {

    final startStep = _stepsList.firstWhere(
          (e) => e.position == StepPosition.start,
    );

    final finishStep = _stepsList.firstWhere(
          (e) => e.position == StepPosition.finish,
    );

    final normalSteps = _stepsList.where(
          (e) => e.position == StepPosition.middle,
    ).toList();

    return ItineraryStepsBuildModel(
      normalSteps: normalSteps,
      startStep: startStep,
      finishStep: finishStep,
    );
  }
  /// Select a step from the list method
  void selectStep(int index) {
    if (index >= 0 && index < _stepsList.length) {
      _selectedStepIndex = index;
      notifyListeners();
    }
  }
  /// Create first and last steps method, used only when creating a new itinerary.
  /// It creates a placeholder step for the first and last step, allowing the user to
  /// edit them before proceeding into normal steps creation
  void createFirstAndLastSteps(){
    final firstStep = ItineraryStepViewModel.newPlaceHolder(
      position: StepPosition.start,
      currentIndex: _selectedStepIndex
    );
    final lastStep = ItineraryStepViewModel.newPlaceHolder(
      position: StepPosition.finish,
      currentIndex: _selectedStepIndex
    );
    addStep(firstStep);
    addStep(lastStep);
  }
  /// Add a new step on the Steps list, guarantees the first and last step are pinned to 0 and last index respectively
  /// TODO: Every widget that comes here, must be already validated!
  void addStep(ItineraryStepViewModel step) {

    switch(step.position){

      case StepPosition.start:
        _stepsList.insert(0, step);
        break;

      case StepPosition.middle:

        final finishIndex = _stepsList.indexWhere(
              (e) => e.position == StepPosition.finish,
        );

        if (finishIndex == -1) {
          _stepsList.add(step);
        } else {
          _stepsList.insert(finishIndex, step);
        }

        break;

      case StepPosition.finish:
        _stepsList.add(step);
        break;
    }

    notifyListeners();
  }
  /// Update step method, it safely protects against invalid change of step position.
  void updateStep(int index, ItineraryStepViewModel updatedStep) {

    if (index < 0 || index >= _stepsList.length) return;

    final currentStep = _stepsList[index];

    if (currentStep.position != updatedStep.position) {
      throw Exception(
        'Cannot change step structural position.',
      );
    }

    _stepsList[index] = updatedStep;

    notifyListeners();
  }
  /// Delete step method, safely protects against invalid operations like delete first and last steps
  void deleteStep(int index) {

    // Invalid indexes are ignored
    // TODO: In future, add a warning UI to the user
    if (index < 0 || index >= _stepsList.length) {
      return;
    }

    final step = _stepsList[index];

    // First and last steps are pinned, cannot be deleted
    // TODO: In future, add a warning UI to the user
    if (
    step.position == StepPosition.start ||
        step.position == StepPosition.finish
    ) {
      return;
    }

    _stepsList.removeAt(index);

    // updating the index value
    if (_selectedStepIndex > index) {
      _selectedStepIndex--;
    } else if (_selectedStepIndex == index) {
      if (_selectedStepIndex >= _stepsList.length) {
        _selectedStepIndex = _stepsList.length - 1;
      }
    }

    notifyListeners();
  }
  /// Go to previous step method
  void goToPreviousStep() {
    if (_selectedStepIndex > 0) {
      _selectedStepIndex--;
      notifyListeners();
    }
  }
  /// To to next step method
  void goToNextStep() {
    if (_selectedStepIndex < _stepsList.length - 1) {
      _selectedStepIndex++;
      notifyListeners();
    }
  }
  /// Reorder Steps method, used in [StepsListPanel] to reorder the steps list.
  void reorderSteps(int oldIndex, int newIndex) {

    final step = _stepsList[oldIndex];

    // Does not allow to move first and last steps
    if (
    step.position == StepPosition.start ||
        step.position == StepPosition.finish
    ) {
      return;
    }

    // Does not allow to move to start position
    if (newIndex == 0) {
      return;
    }

    // Does not allow to move to finish position
    if (newIndex >= _stepsList.length) {
      return;
    }

    /// Does not allow to move to the same position
    if (_stepsList[newIndex - 1].position == StepPosition.finish) {
      return;
    }

    // Updating the index
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = _stepsList.removeAt(oldIndex);

    _stepsList.insert(newIndex, item);

    // keeping the selection
    if (_selectedStepIndex == oldIndex) {
      _selectedStepIndex = newIndex;
    } else if (
    _selectedStepIndex > oldIndex &&
        _selectedStepIndex <= newIndex) {
      _selectedStepIndex--;
    } else if (
    _selectedStepIndex < oldIndex &&
        _selectedStepIndex >= newIndex) {
      _selectedStepIndex++;
    }

    notifyListeners();
  }


}