import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:routecraft_app/core/services/compass_service.dart';
import 'package:routecraft_app/core/services/local_db_service.dart';

class RouteCreationState {
  final int currentStep;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const RouteCreationState({
    this.currentStep = 0,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  RouteCreationState copyWith({
    int? currentStep,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return RouteCreationState(
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class RouteCreationController extends ChangeNotifier {
  RouteCreationState _state = const RouteCreationState();
  RouteCreationState get state => _state;

  // Form Fields
  final tripNameController = TextEditingController();
  final startLocationController = TextEditingController();
  final destinationController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;
  final List<String> interests = [];
  final List<InterestPoint> pointsOfInterest = [];

  void nextStep() {
    if (_state.currentStep < 2) {
      _state = _state.copyWith(currentStep: _state.currentStep + 1);
      notifyListeners();
    }
  }

  void previousStep() {
    if (_state.currentStep > 0) {
      _state = _state.copyWith(currentStep: _state.currentStep - 1);
      notifyListeners();
    }
  }

  void addInterest(String interest) {
    interests.add(interest);
    notifyListeners();
  }

  Future<void> submitRoute() async {
    _state = _state.copyWith(isSubmitting: true, errorMessage: null);
    notifyListeners();

    try {
      final newRoute = RoutePlan(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        clientId: 'client_1', // Mocked client ID
        tripName: tripNameController.text.isEmpty ? 'My Trip' : tripNameController.text,
        startDate: startDate ?? DateTime.now(),
        endDate: endDate ?? DateTime.now().add(const Duration(days: 7)),
        startLocation: startLocationController.text,
        destination: destinationController.text,
        interestsList: interests,
        pointsOfInterest: pointsOfInterest,
      );

      // Save locally
      await LocalDbService.instance.saveRouteLocally(newRoute);

      // Send to server (mock API)
      await CompassService.instance.createRoute(newRoute);

      _state = _state.copyWith(isSubmitting: false, isSuccess: true);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create route: $e',
      );
      notifyListeners();
    }
  }

  @override
  void dispose() {
    tripNameController.dispose();
    startLocationController.dispose();
    destinationController.dispose();
    super.dispose();
  }
}
