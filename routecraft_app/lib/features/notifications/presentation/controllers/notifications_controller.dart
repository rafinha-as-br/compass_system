import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/notifications/data/repositories/notification_repository_impl.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/usecases/notification_usecases.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

class NotificationsState {
  final bool isLoading;
  final bool isLoadingMore;
  final bool isError;
  final bool hasMore;
  final int page;
  final List<TravelNotification> notifications;

  const NotificationsState({
    this.isLoading = true,
    this.isLoadingMore = false,
    this.isError = false,
    this.hasMore = false,
    this.page = 0,
    this.notifications = const [],
  });

  NotificationsState copyWith({
    bool? isLoading,
    bool? isLoadingMore,
    bool? isError,
    bool? hasMore,
    int? page,
    List<TravelNotification>? notifications,
  }) =>
      NotificationsState(
        isLoading: isLoading ?? this.isLoading,
        isLoadingMore: isLoadingMore ?? this.isLoadingMore,
        isError: isError ?? this.isError,
        hasMore: hasMore ?? this.hasMore,
        page: page ?? this.page,
        notifications: notifications ?? this.notifications,
      );
}

class NotificationsController extends ChangeNotifier {
  static const _pageSize = 20;

  NotificationsState _state = const NotificationsState();
  NotificationsState get state => _state;

  final NotificationUseCases? _notificationUseCasesOverride;
  final TravelUseCases? _travelUseCasesOverride;

  /// [notificationUseCases]/[travelUseCases] are injectable for tests,
  /// without depending on the real network/singleton wiring.
  NotificationsController({NotificationUseCases? notificationUseCases, TravelUseCases? travelUseCases})
      : _notificationUseCasesOverride = notificationUseCases,
        _travelUseCasesOverride = travelUseCases {
    _load();
  }

  /// Test-only: starts from a fixed state instead of hitting the real
  /// network/singleton wiring.
  @visibleForTesting
  NotificationsController.withState(this._state)
      : _notificationUseCasesOverride = null,
        _travelUseCasesOverride = null;

  NotificationUseCases get _notificationUseCases =>
      _notificationUseCasesOverride ?? NotificationUseCases(NotificationRepositoryImpl());
  TravelUseCases get _travelUseCases => _travelUseCasesOverride ?? TravelUseCases(TravelRepositoryImpl());

  /// Resolves a notification's `travelId` into the full [Travel] the
  /// itinerary hub needs — only the lightweight id survives the round trip,
  /// so this re-fetches rather than trying to keep a stale `Travel` around.
  Future<Travel?> resolveTravel(String travelId) async {
    final result = await _travelUseCases.getTravel(travelId);
    return switch (result) {
      Success<Travel>(data: final travel) => travel,
      Failure<Travel>() => null,
    };
  }

  Future<void> _load() async {
    _state = const NotificationsState(isLoading: true);
    notifyListeners();

    final result = await _notificationUseCases.getNotifications(page: 0, size: _pageSize);
    switch (result) {
      case Success<(List<TravelNotification>, bool)>(data: final data):
        final (items, hasMore) = data;
        _state = NotificationsState(isLoading: false, notifications: items, hasMore: hasMore);
      case Failure<(List<TravelNotification>, bool)>():
        _state = const NotificationsState(isLoading: false, isError: true);
    }
    notifyListeners();
  }

  /// Re-runs the initial fetch — the retry action on the network-error state.
  Future<void> retry() => _load();

  /// Fetches the next page and appends it — called by the list as the user
  /// scrolls near the bottom.
  Future<void> loadMore() async {
    if (_state.isLoading || _state.isLoadingMore || !_state.hasMore) return;

    _state = _state.copyWith(isLoadingMore: true);
    notifyListeners();

    final nextPage = _state.page + 1;
    final result = await _notificationUseCases.getNotifications(page: nextPage, size: _pageSize);
    switch (result) {
      case Success<(List<TravelNotification>, bool)>(data: final data):
        final (items, hasMore) = data;
        _state = _state.copyWith(
          isLoadingMore: false,
          notifications: [..._state.notifications, ...items],
          hasMore: hasMore,
          page: nextPage,
        );
      case Failure<(List<TravelNotification>, bool)>():
        // A failed "load more" keeps the page already on screen — just stop
        // spinning, the next scroll attempt retries naturally.
        _state = _state.copyWith(isLoadingMore: false);
    }
    notifyListeners();
  }

  Future<void> markAllRead() async {
    if (_state.notifications.every((n) => n.read)) return;

    final updated = _state.notifications.map((n) => n.copyWith(read: true)).toList();
    _state = _state.copyWith(notifications: updated);
    notifyListeners();
    await _notificationUseCases.markAllAsRead();
  }
}
