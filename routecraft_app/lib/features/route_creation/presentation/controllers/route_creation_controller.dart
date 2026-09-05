import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

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

  final TravelUseCases? _travelUseCasesOverride;
  final Future<String?> Function()? _getClientNameOverride;

  /// [travelUseCases]/[getClientName] are injectable for tests, without
  /// depending on the real network/singleton wiring (`AuthService.instance`
  /// is only touched when no override is given).
  RouteCreationController({
    TravelUseCases? travelUseCases,
    Future<String?> Function()? getClientName,
  })  : _travelUseCasesOverride = travelUseCases,
        _getClientNameOverride = getClientName;

  /// Test-only: starts from a fixed state instead of the default (empty)
  /// one, without going through `submitRoute()`'s real network/singleton
  /// wiring.
  @visibleForTesting
  RouteCreationController.withState(this._state)
      : _travelUseCasesOverride = null,
        _getClientNameOverride = null;

  TravelUseCases get _travelUseCases => _travelUseCasesOverride ?? TravelUseCases(TravelRepositoryImpl());

  Future<String?> _getClientName() =>
      (_getClientNameOverride ?? AuthService.instance.getClientName)();

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
      domainId: const Uuid().v4(),
      backEndId: null,
      name: name,
      description: description,
    ));
    notifyListeners();
  }

  Future<void> submitRoute() async {
    _state = _state.copyWith(isSubmitting: true, errorMessage: null);
    notifyListeners();

    final clientName = await _getClientName();
    if (clientName == null || clientName.isEmpty) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: 'Invalid session. Please log in again.',
      );
      notifyListeners();
      return;
    }

    final routePlan = RoutePlan(
      domainId: const Uuid().v4(),
      backEndId: null,
      startDate: startDate ?? DateTime.now(),
      endDate: endDate ?? DateTime.now().add(const Duration(days: 7)),
      startLocation: startLocationController.text,
      destination: destinationController.text,
      interestsList: interestPoints,
    );

    final travel = Travel(
      domainId: const Uuid().v4(),
      backEndId: null,
      clientName: clientName,
      travelName: tripNameController.text.isEmpty ? 'My Trip' : tripNameController.text,
      travelStatus: TravelStatus.routeCreated,
      participantsList: const [],
      routePlan: routePlan,
    );

    final result = await _travelUseCases.createTravel(travel);
    switch (result) {
      case Success<Travel>():
        _state = _state.copyWith(isSubmitting: false, isSuccess: true);
      case Failure<Travel>(message: final message):
        _state = _state.copyWith(isSubmitting: false, errorMessage: 'Failed to create route: $message');
    }
    notifyListeners();
  }

  @override
  void dispose() {
    tripNameController.dispose();
    startLocationController.dispose();
    destinationController.dispose();
    super.dispose();
  }
}
