// itinerary_editor_controller.dart
import 'package:flutter/cupertino.dart';
import 'package:travel_matrix/features/travels/presentation/view_models/itinerary_steps_view_models.dart';

class ItineraryEditorController extends ChangeNotifier {
  List<ItineraryStepViewModel> _steps = [];
  int _selectedStepIndex = -1;
  bool _isSubmitting = false;
  final Set<String> _checkedInterestPointIds = {};

  // Getters
  List<ItineraryStepViewModel> get steps => List.unmodifiable(_steps);
  int get selectedStepIndex => _selectedStepIndex;
  bool get isSubmitting => _isSubmitting;
  Set<String> get checkedInterestPointIds => _checkedInterestPointIds;

  // Initialization
  void initializeSteps(List<ItineraryStepViewModel> steps) {
    _steps = List.from(steps);
    if (_steps.isNotEmpty) {
      _selectedStepIndex = 0;
    }
    notifyListeners();
  }

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

  void toggleInterestPoint(String id) {
    if (_checkedInterestPointIds.contains(id)) {
      _checkedInterestPointIds.remove(id);
    } else {
      _checkedInterestPointIds.add(id);
    }
    notifyListeners();
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