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

  /// Marks one notification as read when the user opens it. Optimistic, but
  /// the server is the source of truth: if the write fails the notification
  /// goes back to unread, so the list never claims a state that was not
  /// persisted (and the unread badge, re-fetched from the server, agrees).
  Future<void> markRead(String id) async {
    final target = _state.notifications.where((n) => n.id == id).firstOrNull;
    if (target == null || target.read) return;

    _setRead((n) => n.id == id, true);
    final result = await _notificationUseCases.markAsRead(id);
    if (result is Failure<void>) _setRead((n) => n.id == id, false);
  }

  Future<void> markAllRead() async {
    final previouslyUnread = _state.notifications.where((n) => !n.read).map((n) => n.id).toSet();
    if (previouslyUnread.isEmpty) return;

    _setRead((n) => true, true);
    final result = await _notificationUseCases.markAllAsRead();
    if (result is Failure<void>) _setRead((n) => previouslyUnread.contains(n.id), false);
  }

  bool _disposed = false;

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// A write can finish after the user left the screen (controller disposed).
  void _setRead(bool Function(TravelNotification) matches, bool read) {
    if (_disposed) return;
    _state = _state.copyWith(
      notifications: [for (final n in _state.notifications) matches(n) ? n.copyWith(read: read) : n],
    );
    notifyListeners();
  }
}
