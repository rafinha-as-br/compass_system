import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/route_repository_impl.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/travel_repository_impl.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';

import '../models/view_models/travel_view_model.dart';

class TravelsState {
  final bool isLoading;
  final List<TravelViewModel> travels;
  final String? errorMessage;

  const TravelsState({
    this.isLoading = true,
    this.travels = const [],
    this.errorMessage,
  });

  TravelsState copyWith({
    bool? isLoading,
    List<TravelViewModel>? travels,
    String? errorMessage,
  }) {
    return TravelsState(
      isLoading: isLoading ?? this.isLoading,
      travels: travels ?? this.travels,
      errorMessage: errorMessage,
    );
  }
}

class TravelsController extends ChangeNotifier {
  final CrudTravelUseCases _travelUseCases;
  final CrudRoute _routeUseCases;

  TravelsState _state = const TravelsState();
  TravelsState get state => _state;

  TravelsController({
    CrudTravelUseCases? travelUseCases,
    CrudRoute? routeUseCases,
  })  : _travelUseCases = travelUseCases ?? CrudTravelUseCases(TravelRepositoryImpl()),
        _routeUseCases = routeUseCases ?? CrudRoute(RouteRepositoryImpl()) {
    fetchTravels();
  }

  Future<void> fetchTravels() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final result = await _travelUseCases.readAll();

      if (result.isSuccess && result.data != null) {
        final travels = result.data!.map((t) => TravelViewModel.fromDomain(t)).toList();
        _state = TravelsState(isLoading: false, travels: travels);
      } else {
        _state = _state.copyWith(isLoading: false, errorMessage: result.error);
      }
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        errorMessage: 'Failed to fetch travels: $e',
      );
      notifyListeners();
    }
  }

  /// Creates a travel from a raw creation-request payload (as built by
  /// [TravelCreationPage]: `clientId`, `agentId`, `travelName`, and a nested
  /// `routePlan` map) — see [CrudTravelUseCases.createFromRequest].
  Future<bool> createTravel(Map<String, dynamic> travelData) async {
    try {
      final result = await _travelUseCases.createFromRequest(travelData);
      if (result.isSuccess) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTravel(String travelId) async {
    try {
      final result = await _travelUseCases.delete(travelId);
      if (result.isSuccess) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Updates the route of an existing travel from the raw form data built by
  /// [RouteCreationPage] (`startDate`, `endDate`, `startLocation`,
  /// `destination`, `interestsList`) — kept separate from [RoutePlanDTO]'s
  /// json mapping since the two use different key names for the same data.
  Future<bool> updateRoute(String travelId, Map<String, dynamic> routeData) async {
    try {
      final interestPoints = ((routeData['interestsList'] as List<dynamic>?) ?? const [])
          .map((raw) {
            final map = raw as Map<String, dynamic>;
            final rawId = map['id']?.toString();
            final isTemporaryId = rawId == null || rawId.startsWith('poi_');
            return InterestPoint(
              domainId: rawId ?? const Uuid().v4(),
              backEndId: isTemporaryId ? null : rawId,
              name: map['name']?.toString() ?? '',
              description: map['description']?.toString() ?? '',
            );
          })
          .toList();

      final routePlan = RoutePlan(
        domainId: const Uuid().v4(),
        backEndId: null,
        startDate: DateTime.parse(routeData['startDate'] as String),
        endDate: DateTime.parse(routeData['endDate'] as String),
        startLocation: routeData['startLocation']?.toString() ?? '',
        destination: routeData['destination']?.toString() ?? '',
        interestsList: interestPoints,
      );

      final result = await _routeUseCases.updateRoute(travelId, routePlan);
      if (result.isSuccess) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markTravelAsReady(String travelId) async {
    try {
      final result = await _travelUseCases.markAsReady(travelId);
      if (result.isSuccess) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }
}
