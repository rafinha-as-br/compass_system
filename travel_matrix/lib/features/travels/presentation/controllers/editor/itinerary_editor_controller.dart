import 'package:flutter/cupertino.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/itinerary_build_page.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/interest_points_panel.dart';

import '../../models/view_models/itinerary_steps_view_models.dart';
import '../../models/view_models/route_view_model.dart';

/// Controller responsible for controlling the [ItineraryBuildPage] UI, and its children.
class ItineraryEditorController extends ChangeNotifier {


  int _selectedStepIndex = -1;
  bool _isSubmitting = false;

  // Getters
  List<ItineraryStepViewModel> get steps => List.unmodifiable(_steps);
  int get selectedStepIndex => _selectedStepIndex;
  bool get isSubmitting => _isSubmitting;




  // Initialization
  ItineraryEditorController({
    required this.interestPoints,
    required this.stepsList,
  });

  /// interests points list
  final List<InterestPointViewModel> interestPoints;

  /// interests points checklist id list, used for filtering the checked state of interest points on [InterestPointsPanel].
  final Set<String> _checkedInterestPointIds = {};

  /// getter for interest points build model for [InterestPointsPanel]
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



  /// steps list, used to build the steps list panel, can be null in case of create mode.
  List<ItineraryStepViewModel>? stepsList;




  /// steps list panel




  // Step management
  void addStep(ItineraryStepViewModel step) {
    _steps.add(step);
    _selectedStepIndex = _steps.length - 1;
    notifyListeners();
  }

  void selectStep(int index) {
    if (index >= 0 && index < _steps.length) {
      _selectedStepIndex = index;
      notifyListeners();
    }
  }

  void goToPreviousStep() {
    if (_selectedStepIndex > 0) {
      _selectedStepIndex--;
      notifyListeners();
    }
  }

  void goToNextStep() {
    if (_selectedStepIndex < _steps.length - 1) {
      _selectedStepIndex++;
      notifyListeners();
    }
  }

  void deleteStep(int index) {
    if (index >= 0 && index < _steps.length) {
      _steps.removeAt(index);
      if (_steps.isEmpty) {
        _selectedStepIndex = -1;
      } else if (_selectedStepIndex >= _steps.length) {
        _selectedStepIndex = _steps.length - 1;
      } else if (_selectedStepIndex == index && index > 0) {
        _selectedStepIndex = index - 1;
      } else if (_selectedStepIndex > index) {
        _selectedStepIndex--;
      }
      notifyListeners();
    }
  }

  void reorderSteps(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _steps.removeAt(oldIndex);
    _steps.insert(newIndex, item);

    // Keep selection following the moved item
    if (_selectedStepIndex == oldIndex) {
      _selectedStepIndex = newIndex;
    } else if (_selectedStepIndex > oldIndex && _selectedStepIndex <= newIndex) {
      _selectedStepIndex--;
    } else if (_selectedStepIndex < oldIndex && _selectedStepIndex >= newIndex) {
      _selectedStepIndex++;
    }
    notifyListeners();
  }

  void updateStep(int index, ItineraryStepViewModel updatedStep) {
    if (index >= 0 && index < _steps.length) {
      _steps[index] = updatedStep;
      notifyListeners();
    }
  }

  void setSubmitting(bool value) {
    _isSubmitting = value;
    notifyListeners();
  }

  // Helper to get step types for conversion
  ItineraryStepViewModel getCurrentStep() {
    if (_selectedStepIndex >= 0 && _selectedStepIndex < _steps.length) {
      return _steps[_selectedStepIndex];
    }
    throw Exception('No step selected');
  }

}