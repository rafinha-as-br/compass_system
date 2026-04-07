import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:routecraft_app/core/services/compass_service.dart';
import 'package:routecraft_app/core/services/local_db_service.dart';
import 'package:routecraft_app/core/services/auth_service.dart';

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
  final List<InterestPoint> interestPoints = [];

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

  void addInterestPoint(String name, String description) {
    interestPoints.add(InterestPoint(
      id: 'poi_${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      description: description,
    ));
    notifyListeners();
  }

  Future<void> submitRoute() async {
    _state = _state.copyWith(isSubmitting: true, errorMessage: null);
    notifyListeners();

    try {
      final newRoute = RoutePlan(
        startDate: startDate ?? DateTime.now(),
        endDate: endDate ?? DateTime.now().add(const Duration(days: 7)),
        startLocation: startLocationController.text,
        destination: destinationController.text,
        interestsList: interestPoints,
      );

      final localId = DateTime.now().millisecondsSinceEpoch.toString();

      // Save locally
      await LocalDbService.instance.saveRouteLocally(localId, newRoute);

      // Send to server as a Travel (mock API)
      final token = await AuthService.instance.getToken();
      if (token != null) {
        await CompassService.instance.createTravel(token, {
          'clientId': 'client_1', // Will be resolved from logged-in user
          'agentId': 'agent_1',
          'travelName': tripNameController.text.isEmpty
              ? 'My Trip'
              : tripNameController.text,
          'routePlan': newRoute.toMap(),
        });
      }

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
