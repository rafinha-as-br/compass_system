import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/notifications/domain/usecases/travel_notifications_checker.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

/// Travels grouped by urgency for the Início screen — in progress first,
/// then upcoming (route created or itinerary published, but not started),
/// then completed. Each group is sorted by the route's start date.
class HomeState {
  final bool isLoading;
  final String? clientName;
  final List<Travel> inProgress;
  final List<Travel> upcoming;
  final List<Travel> completed;

  const HomeState({
    this.isLoading = true,
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

  /// [travelUseCases]/[getClientName]/[notificationsChecker] are injectable
  /// for tests, without depending on the real network/storage/singleton
  /// wiring (`AuthService.instance` is only touched when no override is
  /// given).
  HomeController({
    TravelUseCases? travelUseCases,
    Future<String?> Function()? getClientName,
    TravelNotificationsChecker? notificationsChecker,
  })  : _travelUseCasesOverride = travelUseCases,
        _getClientNameOverride = getClientName,
        _notificationsCheckerOverride = notificationsChecker {
    _fetchData();
  }

  /// Test-only: starts from a fixed state instead of hitting the real
  /// network/singleton wiring.
  @visibleForTesting
  HomeController.withState(this._state)
      : _travelUseCasesOverride = null,
        _getClientNameOverride = null,
        _notificationsCheckerOverride = null;

  TravelUseCases get _travelUseCases => _travelUseCasesOverride ?? TravelUseCases(TravelRepositoryImpl());
  TravelNotificationsChecker get _notificationsChecker => _notificationsCheckerOverride ?? TravelNotificationsChecker();

  Future<String?> _getClientName() =>
      (_getClientNameOverride ?? AuthService.instance.getClientName)();

  Future<void> _fetchData() async {
    _state = const HomeState(isLoading: true);
    notifyListeners();

    try {
      final clientName = await _getClientName();
      if (clientName == null || clientName.isEmpty) {
        _state = const HomeState(isLoading: false);
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
        case Failure<List<Travel>>():
          _state = HomeState(isLoading: false, clientName: clientName);
      }
    } catch (error) {
      // Degrades to the empty state rather than crashing Início — mirrors
      // how a repository failure above is already treated as "no travels".
      debugPrint('HomeController: failed to load travels: $error');
      _state = const HomeState(isLoading: false);
    }
    notifyListeners();
  }

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
