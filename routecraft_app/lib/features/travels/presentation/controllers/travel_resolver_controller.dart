import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

/// One-shot fetch of a single [Travel] by id — backs [TravelResolver] for
/// the case where the route's `extra` didn't carry the object (deep link,
/// state restoration, or a reload of the route).
class TravelResolverState {
  final bool isLoading;
  final bool isError;
  final Travel? travel;

  const TravelResolverState({this.isLoading = true, this.isError = false, this.travel});
}

class TravelResolverController extends ChangeNotifier {
  TravelResolverState _state = const TravelResolverState();
  TravelResolverState get state => _state;

  final String _travelId;
  final TravelUseCases? _travelUseCasesOverride;

  /// [travelUseCases] is injectable for tests, without depending on the
  /// real network/singleton wiring.
  TravelResolverController({required String travelId, TravelUseCases? travelUseCases})
      : _travelId = travelId,
        _travelUseCasesOverride = travelUseCases {
    _fetch();
  }

  /// Test-only: starts from a fixed state instead of hitting the real
  /// network/singleton wiring.
  @visibleForTesting
  TravelResolverController.withState(this._state)
      : _travelId = '',
        _travelUseCasesOverride = null;

  TravelUseCases get _travelUseCases => _travelUseCasesOverride ?? TravelUseCases(TravelRepositoryImpl());

  /// Re-runs the fetch — the retry action on the error state.
  Future<void> retry() => _fetch();

  Future<void> _fetch() async {
    _state = const TravelResolverState(isLoading: true);
    notifyListeners();

    try {
      final result = await _travelUseCases.getTravel(_travelId);
      _state = switch (result) {
        Success<Travel>(data: final travel) => TravelResolverState(isLoading: false, travel: travel),
        Failure<Travel>() => const TravelResolverState(isLoading: false, isError: true),
      };
    } catch (error) {
      debugPrint('TravelResolverController: failed to load travel $_travelId: $error');
      _state = const TravelResolverState(isLoading: false, isError: true);
    }
    notifyListeners();
  }
}
