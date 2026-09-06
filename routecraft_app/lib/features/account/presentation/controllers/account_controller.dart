import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

class AccountState {
  final bool isLoading;
  final String? clientName;
  final String? clientEmail;

  /// Name of the agent who built the itinerary for one of the client's
  /// travels — there is no client-level "assigned agent" independent of a
  /// travel, so this is `null` until at least one travel has an itinerary.
  final String? agentName;

  const AccountState({
    this.isLoading = true,
    this.clientName,
    this.clientEmail,
    this.agentName,
  });
}

class AccountController extends ChangeNotifier {
  AccountState _state = const AccountState();
  AccountState get state => _state;

  final TravelUseCases? _travelUseCasesOverride;
  final Future<String?> Function()? _getClientNameOverride;
  final Future<String?> Function()? _getClientEmailOverride;

  /// [travelUseCases]/[getClientName]/[getClientEmail] are injectable for
  /// tests, without depending on the real network/singleton wiring
  /// (`AuthService.instance` is only touched when no override is given).
  AccountController({
    TravelUseCases? travelUseCases,
    Future<String?> Function()? getClientName,
    Future<String?> Function()? getClientEmail,
  })  : _travelUseCasesOverride = travelUseCases,
        _getClientNameOverride = getClientName,
        _getClientEmailOverride = getClientEmail {
    _fetchData();
  }

  /// Test-only: starts from a fixed state instead of hitting the real
  /// network/singleton wiring.
  @visibleForTesting
  AccountController.withState(this._state)
      : _travelUseCasesOverride = null,
        _getClientNameOverride = null,
        _getClientEmailOverride = null;

  TravelUseCases get _travelUseCases => _travelUseCasesOverride ?? TravelUseCases(TravelRepositoryImpl());

  Future<String?> _getClientName() =>
      (_getClientNameOverride ?? AuthService.instance.getClientName)();

  Future<String?> _getClientEmail() =>
      (_getClientEmailOverride ?? AuthService.instance.getClientEmail)();

  Future<void> _fetchData() async {
    _state = const AccountState(isLoading: true);
    notifyListeners();

    try {
      final name = await _getClientName();
      final email = await _getClientEmail();
      final agentName = name == null || name.isEmpty ? null : await _findAgentName(name);

      _state = AccountState(isLoading: false, clientName: name, clientEmail: email, agentName: agentName);
    } catch (error) {
      // Degrades to an empty (but non-loading) account view rather than
      // crashing the screen — mirrors HomeController's same defense.
      debugPrint('AccountController: failed to load account data: $error');
      _state = const AccountState(isLoading: false);
    }
    notifyListeners();
  }

  Future<String?> _findAgentName(String clientName) async {
    final result = await _travelUseCases.getTravelsForClient(clientName);
    return switch (result) {
      Success<List<Travel>>(data: final travels) => _agentFromTravels(travels),
      Failure<List<Travel>>() => null,
    };
  }

  String? _agentFromTravels(List<Travel> travels) {
    for (final travel in travels) {
      final itinerary = travel.itinerary;
      if (itinerary != null) return itinerary.agentName;
    }
    return null;
  }
}
