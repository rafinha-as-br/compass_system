import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

/// All of the client's travels — including finished ones — with an
/// in-memory name search and status filter applied on top.
class TravelsState {
  final bool isLoading;
  final bool isError;
  final String? clientName;
  final List<Travel> travels;
  final String searchQuery;
  final TravelStatus? statusFilter;

  const TravelsState({
    this.isLoading = true,
    this.isError = false,
    this.clientName,
    this.travels = const [],
    this.searchQuery = '',
    this.statusFilter,
  });

  TravelsState copyWith({String? searchQuery, TravelStatus? Function()? statusFilter}) => TravelsState(
        isLoading: isLoading,
        isError: isError,
        clientName: clientName,
        travels: travels,
        searchQuery: searchQuery ?? this.searchQuery,
        statusFilter: statusFilter != null ? statusFilter() : this.statusFilter,
      );

  /// True only when the client has no travels at all — distinct from
  /// [hasNoResults], where travels exist but none match the current
  /// search/filter.
  bool get isEmpty => travels.isEmpty;

  List<Travel> get filteredTravels {
    final query = searchQuery.trim().toLowerCase();
    final filtered = travels.where((travel) {
      final matchesQuery = query.isEmpty || travel.travelName.toLowerCase().contains(query);
      final matchesStatus = statusFilter == null || travel.travelStatus == statusFilter;
      return matchesQuery && matchesStatus;
    }).toList();
    filtered.sort((a, b) => b.routePlan.startDate.compareTo(a.routePlan.startDate));
    return filtered;
  }

  bool get hasNoResults => !isLoading && !isError && travels.isNotEmpty && filteredTravels.isEmpty;
}

class TravelsController extends ChangeNotifier {
  TravelsState _state = const TravelsState();
  TravelsState get state => _state;

  final TravelUseCases? _travelUseCasesOverride;
  final Future<String?> Function()? _getClientNameOverride;

  /// [travelUseCases]/[getClientName] are injectable for tests, without
  /// depending on the real network/singleton wiring.
  TravelsController({
    TravelUseCases? travelUseCases,
    Future<String?> Function()? getClientName,
  })  : _travelUseCasesOverride = travelUseCases,
        _getClientNameOverride = getClientName {
    _fetchData();
  }

  /// Test-only: starts from a fixed state instead of hitting the real
  /// network/singleton wiring.
  @visibleForTesting
  TravelsController.withState(this._state)
      : _travelUseCasesOverride = null,
        _getClientNameOverride = null;

  TravelUseCases get _travelUseCases => _travelUseCasesOverride ?? TravelUseCases(TravelRepositoryImpl());

  Future<String?> _getClientName() => (_getClientNameOverride ?? AuthService.instance.getClientName)();

  /// Re-runs the fetch. `StatefulShellRoute.indexedStack` keeps this
  /// controller alive for the whole app session, so returning from a child
  /// route (e.g. after creating a route) never re-triggers the constructor's
  /// fetch on its own — callers must invoke this explicitly.
  Future<void> refresh() => _fetchData();

  /// Re-runs the fetch — the retry action on the network-error state.
  Future<void> retry() => _fetchData();

  void setSearchQuery(String query) {
    _state = _state.copyWith(searchQuery: query);
    notifyListeners();
  }

  void setStatusFilter(TravelStatus? status) {
    _state = _state.copyWith(statusFilter: () => status);
    notifyListeners();
  }

  Future<void> _fetchData() async {
    _state = TravelsState(isLoading: true, searchQuery: _state.searchQuery, statusFilter: _state.statusFilter);
    notifyListeners();

    try {
      final clientName = await _getClientName();
      if (clientName == null || clientName.isEmpty) {
        _state = TravelsState(isLoading: false, searchQuery: _state.searchQuery, statusFilter: _state.statusFilter);
        notifyListeners();
        return;
      }

      final result = await _travelUseCases.getTravelsForClient(clientName);
      switch (result) {
        case Success<List<Travel>>(data: final travels):
          _state = TravelsState(
            isLoading: false,
            clientName: clientName,
            travels: travels,
            searchQuery: _state.searchQuery,
            statusFilter: _state.statusFilter,
          );
        case Failure<List<Travel>>():
          _state = TravelsState(
            isLoading: false,
            isError: true,
            clientName: clientName,
            searchQuery: _state.searchQuery,
            statusFilter: _state.statusFilter,
          );
      }
    } catch (error) {
      debugPrint('TravelsController: failed to load travels: $error');
      _state = TravelsState(isLoading: false, isError: true, searchQuery: _state.searchQuery, statusFilter: _state.statusFilter);
    }
    notifyListeners();
  }
}
