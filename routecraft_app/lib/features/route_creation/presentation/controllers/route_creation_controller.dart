import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/person.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

/// Number of guided data-entry steps (name, dates, locations, interests,
/// participants) before the review screen —
/// [RouteCreationState.currentStep] `5` is the review, one past this count.
const routeCreationStepCount = 5;

class RouteCreationState {
  final int currentStep;
  final bool isSubmitting;
  final bool hasNoSession;
  final String? submitErrorMessage;
  final bool isSuccess;

  const RouteCreationState({
    this.currentStep = 0,
    this.isSubmitting = false,
    this.hasNoSession = false,
    this.submitErrorMessage,
    this.isSuccess = false,
  });

  bool get isReviewStep => currentStep == routeCreationStepCount;

  RouteCreationState copyWith({
    int? currentStep,
    bool? isSubmitting,
    bool? hasNoSession,
    String? submitErrorMessage,
    bool? isSuccess,
  }) {
    return RouteCreationState(
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      hasNoSession: hasNoSession ?? this.hasNoSession,
      // No `?? this.submitErrorMessage` fallback: a passed `null` must clear
      // a stale message from a previous attempt (same fix as LoginState).
      submitErrorMessage: submitErrorMessage,
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
        _getClientNameOverride = getClientName {
    tripNameController.addListener(notifyListeners);
    startLocationController.addListener(notifyListeners);
    destinationController.addListener(notifyListeners);
    _addClientAsParticipant();
  }

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

  // Step 1 — name.
  final tripNameController = TextEditingController();
  bool get isNameValid => tripNameController.text.trim().isNotEmpty;

  // Step 2 — dates.
  DateTime? startDate;
  DateTime? endDate;

  int? get nights => (startDate != null && endDate != null) ? endDate!.difference(startDate!).inDays : null;
  bool get isDatesValid => startDate != null && endDate != null && endDate!.isAfter(startDate!);

  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void applyWeekendShortcut() {
    final now = DateTime.now();
    final daysUntilSaturday = (DateTime.saturday - now.weekday) % 7;
    final saturday = DateTime(now.year, now.month, now.day).add(Duration(days: daysUntilSaturday == 0 ? 7 : daysUntilSaturday));
    startDate = saturday;
    endDate = saturday.add(const Duration(days: 1));
    notifyListeners();
  }

  void applyWeekShortcut() {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    startDate = DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    endDate = startDate!.add(const Duration(days: 7));
    notifyListeners();
  }

  void applyFlexibleShortcut() {
    final now = DateTime.now();
    startDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 30));
    endDate = startDate!.add(const Duration(days: 7));
    notifyListeners();
  }

  // Step 3 — locations.
  final startLocationController = TextEditingController();
  final destinationController = TextEditingController();
  bool get isLocationsValid =>
      startLocationController.text.trim().isNotEmpty && destinationController.text.trim().isNotEmpty;

  // Step 4 — interests (optional: always valid to continue).
  final List<InterestPoint> interestPoints = [];

  void addInterestPoint(String name, String description) {
    interestPoints.add(InterestPoint(
      domainId: const Uuid().v4(),
      backEndId: null,
      name: name,
      description: description,
    ));
    notifyListeners();
  }

  void removeInterestPoint(String domainId) {
    interestPoints.removeWhere((point) => point.domainId == domainId);
    notifyListeners();
  }

  // Step 5 — participants. The client is added automatically and can't be
  // removed — [isClientParticipant] tracks which entry that is without
  // adding an "isClient" field to the shared [Person] contract.
  final List<Person> participants = [];
  String? _clientParticipantId;

  bool isClientParticipant(Person person) => person.domainId == _clientParticipantId;

  bool get isParticipantsValid =>
      participants.isNotEmpty &&
      participants.every((p) => p.name.trim().isNotEmpty && p.age.trim().isNotEmpty && p.sex.trim().isNotEmpty);

  Future<void> _addClientAsParticipant() async {
    final clientName = await _getClientName();
    final client = Person(domainId: const Uuid().v4(), backEndId: null, name: clientName ?? '', age: '', sex: '');
    _clientParticipantId = client.domainId;
    participants.insert(0, client);
    notifyListeners();
  }

  void addParticipant({required String name, required String age, required String sex}) {
    participants.add(Person(domainId: const Uuid().v4(), backEndId: null, name: name, age: age, sex: sex));
    notifyListeners();
  }

  /// No-op for the client's own entry — the UI never offers a way to
  /// trigger this for it (no remove button on that row), but guarding here
  /// too keeps the invariant enforced at the controller, not just the view.
  void removeParticipant(String domainId) {
    if (domainId == _clientParticipantId) return;
    participants.removeWhere((p) => p.domainId == domainId);
    notifyListeners();
  }

  void updateParticipant(String domainId, {String? name, String? age, String? sex}) {
    final index = participants.indexWhere((p) => p.domainId == domainId);
    if (index == -1) return;
    final current = participants[index];
    participants[index] = Person(
      domainId: current.domainId,
      backEndId: current.backEndId,
      name: name ?? current.name,
      age: age ?? current.age,
      sex: sex ?? current.sex,
    );
    notifyListeners();
  }

  bool _isStepValid(int step) => switch (step) {
        0 => isNameValid,
        1 => isDatesValid,
        2 => isLocationsValid,
        3 => true,
        4 => isParticipantsValid,
        _ => false,
      };

  void nextStep() {
    if (_state.currentStep >= routeCreationStepCount || !_isStepValid(_state.currentStep)) return;
    _state = _state.copyWith(currentStep: _state.currentStep + 1);
    notifyListeners();
  }

  void previousStep() {
    if (_state.currentStep > 0) {
      _state = _state.copyWith(currentStep: _state.currentStep - 1);
      notifyListeners();
    }
  }

  /// Jumps back from the review screen to a given step to edit it.
  void editStep(int step) {
    _state = _state.copyWith(currentStep: step);
    notifyListeners();
  }

  Future<void> submitRoute() async {
    _state = _state.copyWith(isSubmitting: true, hasNoSession: false, submitErrorMessage: null);
    notifyListeners();

    final clientName = await _getClientName();
    if (clientName == null || clientName.isEmpty) {
      _state = _state.copyWith(isSubmitting: false, hasNoSession: true);
      notifyListeners();
      return;
    }

    final routePlan = RoutePlan(
      domainId: const Uuid().v4(),
      backEndId: null,
      startDate: startDate!,
      endDate: endDate!,
      startLocation: startLocationController.text.trim(),
      destination: destinationController.text.trim(),
      interestsList: interestPoints,
    );

    final travel = Travel(
      domainId: const Uuid().v4(),
      backEndId: null,
      clientName: clientName,
      travelName: tripNameController.text.trim(),
      travelStatus: TravelStatus.routeCreated,
      participantsList: participants,
      routePlan: routePlan,
    );

    final result = await _travelUseCases.createTravel(travel);
    switch (result) {
      case Success<Travel>():
        _state = _state.copyWith(isSubmitting: false, isSuccess: true);
      case Failure<Travel>(message: final message):
        _state = _state.copyWith(isSubmitting: false, submitErrorMessage: message);
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
