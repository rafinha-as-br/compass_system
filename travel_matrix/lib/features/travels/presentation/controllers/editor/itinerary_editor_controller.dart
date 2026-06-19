import 'package:flutter/cupertino.dart';
import 'package:travel_matrix/features/travels/domain/usecases/timeline_analyzer.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/timeline_problem_view_model.dart';
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
  }) {
    // Null verificator to activate the first and last steps creation
    if (steps != null) {
      _stepsList = steps;
      _selectedStepIndex = steps.length - 1;
    } else {
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
          isChecked: _checkedInterestPointIds.contains(element.id),
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

  /// Ordered list of steps as currently edited in the UI.
  List<ItineraryStepViewModel> get stepsList => List.unmodifiable(_stepsList);

  /// Getter for [ItineraryStepsBuildModel] list for [StepsBuilderPanel]
  ItineraryStepsBuildModel get stepsBuildModel {
    final startStep = _stepsList.firstWhere(
      (e) => e.position == StepPosition.start,
    );

    final finishStep = _stepsList.firstWhere(
      (e) => e.position == StepPosition.finish,
    );

    final normalSteps = _stepsList
        .where((e) => e.position == StepPosition.middle)
        .toList();

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
  void createFirstAndLastSteps() {
    final firstStep = ItineraryStepViewModel.newPlaceHolder(
      position: StepPosition.start,
      currentIndex: _selectedStepIndex,
    );
    final lastStep = ItineraryStepViewModel.newPlaceHolder(
      position: StepPosition.finish,
      currentIndex: _selectedStepIndex,
    );
    addStep(newStep: firstStep);
    addStep(newStep: lastStep);
  }

  /// Add a new step on the Steps list, guarantees the first and last step are pinned to 0 and last index respectively
  void addStep({required ItineraryStepViewModel newStep}) {
    switch (newStep.position) {
      case StepPosition.start:
        _stepsList.insert(0, newStep);
        break;

      case StepPosition.middle:
        final finishIndex = _stepsList.indexWhere(
          (e) => e.position == StepPosition.finish,
        );

        if (finishIndex == -1) {
          _stepsList.add(newStep);
        } else {
          _stepsList.insert(finishIndex, newStep);
        }

        break;

      case StepPosition.finish:
        _stepsList.add(newStep);
        break;
    }

    /// Verifies the timeline problems
    _commitTimelineChanges();

    notifyListeners();
  }

  /// Update step method, it safely protects against invalid change of step position.
  /// This method works as a auto-save method.
  void updateStep(int index, ItineraryStepViewModel updatedStep) {
    if (index < 0 || index >= _stepsList.length) return;

    final currentStep = _stepsList[index];

    if (currentStep.position != updatedStep.position) {
      throw Exception('Cannot change step structural position.');
    }

    _stepsList[index] = updatedStep;

    /// Verifies the timeline problems
    _commitTimelineChanges();

    notifyListeners();
  }

  /// Delete step method, safely protects against invalid operations like delete first and last steps
  bool deleteStep(int index) {
    // Invalid indexes are ignored
    // TODO: In future, add a warning UI to the user
    if (index < 0 || index >= _stepsList.length) {
      return false;
    }

    final step = _stepsList[index];

    // First and last steps are pinned, cannot be deleted
    if (step.position == StepPosition.start ||
        step.position == StepPosition.finish) {
      return false;
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

    // Verifies the timeline problems
    _commitTimelineChanges();

    notifyListeners();
    return true;
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
  /// Returns false if the operation was invalid (e.g. moving a boundary step).
  bool reorderSteps(int oldIndex, int newIndex) {
    // Flutter's ReorderableListView sends newIndex that needs adjustment
    // when moving an item downward (newIndex is offset by +1)
    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    // No-op if the position didn't change
    if (oldIndex == newIndex) return true;

    // Bounds check
    if (oldIndex < 0 || oldIndex >= _stepsList.length ||
        newIndex < 0 || newIndex >= _stepsList.length) {
      return false;
    }

    final step = _stepsList[oldIndex];

    // Only middle steps can be moved
    if (step.position != StepPosition.middle) {
      return false;
    }

    // Cannot move to a position occupied by a boundary step
    final targetStep = _stepsList[newIndex];
    if (targetStep.position == StepPosition.start ||
        targetStep.position == StepPosition.finish) {
      return false;
    }

    final item = _stepsList.removeAt(oldIndex);
    _stepsList.insert(newIndex, item);

    // keeping the selection
    if (_selectedStepIndex == oldIndex) {
      _selectedStepIndex = newIndex;
    } else if (_selectedStepIndex > oldIndex &&
        _selectedStepIndex <= newIndex) {
      _selectedStepIndex--;
    } else if (_selectedStepIndex < oldIndex &&
        _selectedStepIndex >= newIndex) {
      _selectedStepIndex++;
    }

    // Verifies the timeline problems
    _commitTimelineChanges();

    notifyListeners();
    return true;
  }

  /// Update the steps in the list with the TimelineProblems
  void _commitTimelineChanges() {
    final List<TimelineProblem> timelineProblems = [];

    // making the itinerary analysis
    final itineraryNodes = [
      for (int i = 0; i < _stepsList.length; i++)
        _stepsList[i].toTimelineNode(sequenceIndex: i),
    ];
    final itineraryAnalysis = timelineAnalyzer(itineraryNodes);
    timelineProblems.addAll(itineraryAnalysis);

    // making the steps analysis
    for (var step in _stepsList) {
      final stepNodes = step.buildInternalTimeline();
      if (stepNodes != null) {
        final stepAnalysis = timelineAnalyzer(stepNodes);
        timelineProblems.addAll(stepAnalysis);
      }
    }

    // updating the steps list
    for (int i = 0; i < _stepsList.length; i++) {
      final step = _stepsList[i];
      final List<TimelineProblemViewModel> problemsViewModel = [];
      for (var problem in timelineProblems) {
        if (problem.involves(step.localId)) {
          // Find step1 and step2 from the list, default to the current step if not found
          // (e.g. if the node is an internal transport node that shares the step's localId)
          final step1 = _stepsList.firstWhere(
            (s) => s.localId == problem.nodeId1,
            orElse: () => step,
          );
          final step2 = _stepsList.firstWhere(
            (s) => s.localId == problem.nodeId2,
            orElse: () => step,
          );

          final problemViewModel = TimelineProblemViewModel.fromTimelineProblem(
            problem,
            step1,
            step2,
          );
          problemsViewModel.add(problemViewModel);
        }
      }
      // assign back to the list (using the empty list to clear previous problems)
      _stepsList[i] = step.copyWith(problems: problemsViewModel);
    }
  }

  /// Is itinerary without any errors checker
}
