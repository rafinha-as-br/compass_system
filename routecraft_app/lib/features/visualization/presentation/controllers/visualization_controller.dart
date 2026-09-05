import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

class VisualizationState {
  final bool isLoading;
  final List<Travel> travels;

  const VisualizationState({
    this.isLoading = true,
    this.travels = const [],
  });
}

class VisualizationController extends ChangeNotifier {
  VisualizationState _state = const VisualizationState();
  VisualizationState get state => _state;

  final TravelUseCases? _travelUseCasesOverride;
  final Future<String?> Function()? _getClientNameOverride;

  /// [travelUseCases]/[getClientName] are injectable for tests, without
  /// depending on the real network/singleton wiring (`AuthService.instance`
  /// is only touched when no override is given).
  VisualizationController({
    TravelUseCases? travelUseCases,
    Future<String?> Function()? getClientName,
  })  : _travelUseCasesOverride = travelUseCases,
        _getClientNameOverride = getClientName {
    _fetchData();
  }

  /// Test-only: starts from a fixed state instead of hitting the real
  /// network/singleton wiring.
  @visibleForTesting
  VisualizationController.withState(this._state)
      : _travelUseCasesOverride = null,
        _getClientNameOverride = null;

  TravelUseCases get _travelUseCases => _travelUseCasesOverride ?? TravelUseCases(TravelRepositoryImpl());

  Future<String?> _getClientName() =>
      (_getClientNameOverride ?? AuthService.instance.getClientName)();

  Future<void> _fetchData() async {
    _state = const VisualizationState(isLoading: true);
    notifyListeners();

    final clientName = await _getClientName();
    if (clientName == null || clientName.isEmpty) {
      _state = const VisualizationState(isLoading: false);
      notifyListeners();
      return;
    }

    final result = await _travelUseCases.getTravelsForClient(clientName);
    switch (result) {
      case Success<List<Travel>>(data: final travels):
        _state = VisualizationState(isLoading: false, travels: travels);
      case Failure<List<Travel>>():
        _state = const VisualizationState(isLoading: false);
    }
    notifyListeners();
  }
}
