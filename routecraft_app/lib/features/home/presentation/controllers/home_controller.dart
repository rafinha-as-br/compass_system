import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/notifications/domain/usecases/travel_notifications_checker.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/data/services/travel_cache_service.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

/// Travels grouped by urgency for the Início screen — in progress first,
/// then upcoming (route created or itinerary published, but not started),
/// then completed. Each group is sorted by the route's start date.
class HomeState {
  final bool isLoading;
  final bool isError;
  final bool isOffline;
  final DateTime? syncedAt;
  final String? clientName;
  final List<Travel> inProgress;
  final List<Travel> upcoming;
  final List<Travel> completed;

  const HomeState({
    this.isLoading = true,
    this.isError = false,
    this.isOffline = false,
    this.syncedAt,
    this.clientName,
    this.inProgress = const [],
    this.upcoming = const [],
    this.completed = const [],
  });

  bool get isEmpty => inProgress.isEmpty && upcoming.isEmpty && completed.isEmpty;
}

class HomeController extends ChangeNotifier {
  HomeState _state = const HomeState();
  HomeState get state => _state;

  final TravelUseCases? _travelUseCasesOverride;
  final Future<String?> Function()? _getClientNameOverride;
  final TravelNotificationsChecker? _notificationsCheckerOverride;
  final Future<CachedTravels?> Function(String clientName)? _readCacheOverride;
  final void Function({required bool isOffline, DateTime? syncedAt})? _onSyncStatusChanged;

  /// [travelUseCases]/[getClientName]/[notificationsChecker]/[readCache] are
  /// injectable for tests, without depending on the real
  /// network/storage/singleton wiring (`AuthService.instance` is only
  /// touched when no override is given). [onSyncStatusChanged] mirrors the
  /// offline/synced-at state into the app-wide `TravelSyncStatusController`
  /// so the hub/timeline pages — which never fetch on their own — can show
  /// the same offline banner (CPS-98).
  HomeController({
    TravelUseCases? travelUseCases,
    Future<String?> Function()? getClientName,
    TravelNotificationsChecker? notificationsChecker,
    Future<CachedTravels?> Function(String clientName)? readCache,
    void Function({required bool isOffline, DateTime? syncedAt})? onSyncStatusChanged,
  })  : _travelUseCasesOverride = travelUseCases,
        _getClientNameOverride = getClientName,
        _notificationsCheckerOverride = notificationsChecker,
        _readCacheOverride = readCache,
        _onSyncStatusChanged = onSyncStatusChanged {
    _fetchData();
  }

  /// Test-only: starts from a fixed state instead of hitting the real
  /// network/singleton wiring.
  @visibleForTesting
  HomeController.withState(this._state)
      : _travelUseCasesOverride = null,
        _getClientNameOverride = null,
        _notificationsCheckerOverride = null,
        _readCacheOverride = null,
        _onSyncStatusChanged = null;

  TravelUseCases get _travelUseCases => _travelUseCasesOverride ?? TravelUseCases(TravelRepositoryImpl());
  TravelNotificationsChecker get _notificationsChecker => _notificationsCheckerOverride ?? TravelNotificationsChecker();

  Future<String?> _getClientName() =>
      (_getClientNameOverride ?? AuthService.instance.getClientName)();

  Future<CachedTravels?> _readCache(String clientName) =>
      (_readCacheOverride ?? const TravelCacheService().readTravels)(clientName);

  /// Re-runs the fetch. `StatefulShellRoute.indexedStack` keeps this
  /// controller alive for the whole app session, so returning from a child
  /// route (e.g. after creating a route) never re-triggers the constructor's
  /// fetch on its own — callers must invoke this explicitly.
  Future<void> refresh() => _fetchData();

  Future<void> _fetchData() async {
    _state = const HomeState(isLoading: true);
    notifyListeners();

    try {
      final clientName = await _getClientName();
      if (clientName == null || clientName.isEmpty) {
        _state = const HomeState(isLoading: false);
        _onSyncStatusChanged?.call(isOffline: false, syncedAt: null);
        notifyListeners();
        return;
      }

      final result = await _travelUseCases.getTravelsForClient(clientName);
      switch (result) {
        case Success<List<Travel>>(data: final travels):
          final (inProgress, upcoming, completed) = _group(travels);
          _state = HomeState(
            isLoading: false,
            clientName: clientName,
            inProgress: inProgress,
            upcoming: upcoming,
            completed: completed,
          );
          // Fire-and-forget: notification generation is a side effect of
          // this fetch, never something Início's own loading state waits on
          // or fails because of.
          unawaited(_checkForNotifications(travels));
        case Failure<List<Travel>>(isConnectivityError: final isConnectivityError):
          _state = isConnectivityError
              ? await _offlineOrErrorState(clientName)
              : HomeState(isLoading: false, isError: true, clientName: clientName);
      }
    } catch (error) {
      // A network/storage failure is a distinct, retry-worthy state — it no
      // longer degrades silently to "no travels" (that used to hide real
      // outages behind an empty-state screen).
      debugPrint('HomeController: failed to load travels: $error');
      _state = const HomeState(isLoading: false, isError: true);
    }
    _onSyncStatusChanged?.call(isOffline: _state.isOffline, syncedAt: _state.syncedAt);
    notifyListeners();
  }

  /// Falls back to the local cache when the live fetch failed for lack of
  /// connection — the CPS-96 network-error state is reserved for when
  /// there's no cache to fall back to.
  Future<HomeState> _offlineOrErrorState(String clientName) async {
    final cached = await _readCache(clientName);
    if (cached == null) {
      return HomeState(isLoading: false, isError: true, clientName: clientName);
    }
    final (inProgress, upcoming, completed) = _group(cached.travels);
    return HomeState(
      isLoading: false,
      clientName: clientName,
      inProgress: inProgress,
      upcoming: upcoming,
      completed: completed,
      isOffline: true,
      syncedAt: cached.syncedAt,
    );
  }

  /// Re-runs the fetch — the retry action on the network-error state.
  Future<void> retry() => _fetchData();

  Future<void> _checkForNotifications(List<Travel> travels) async {
    try {
      await _notificationsChecker.checkForChanges(travels);
    } catch (error) {
      debugPrint('HomeController: failed to check for travel notifications: $error');
    }
  }

  static (List<Travel>, List<Travel>, List<Travel>) _group(List<Travel> travels) {
    int byStartDate(Travel a, Travel b) => a.routePlan.startDate.compareTo(b.routePlan.startDate);

    final inProgress = travels.where((t) => t.travelStatus == TravelStatus.travelStarted).toList()
      ..sort(byStartDate);
    final upcoming = travels
        .where((t) =>
            t.travelStatus == TravelStatus.routeCreated || t.travelStatus == TravelStatus.itineraryCreated)
        .toList()
      ..sort(byStartDate);
    final completed = travels.where((t) => t.travelStatus == TravelStatus.travelFinished).toList()
      ..sort((a, b) => b.routePlan.startDate.compareTo(a.routePlan.startDate));

    return (inProgress, upcoming, completed);
  }
}
