import 'package:flutter/foundation.dart';
import 'package:travel_matrix/features/notifications/data/repository_impl/notification_repository_impl.dart';
import 'package:travel_matrix/features/notifications/domain/entities/travel_notification.dart';
import 'package:travel_matrix/features/notifications/domain/usecases/notification_usecases.dart';

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

  /// `late` (not assigned by `.withState`) — a widget test using `.withState`
  /// never touches this, so it never needs the real singleton wiring.
  late final NotificationUseCases _useCases;

  /// Called after a successful `markAsRead`/`markAllRead` write — lets the
  /// sidebar's unread badge (a separate controller/provider scope) stay in
  /// sync without this controller knowing it exists.
  final void Function()? onReadStateChanged;

  /// [notificationUseCases] is injectable for tests, without depending on
  /// the real network/singleton wiring.
  NotificationsController({NotificationUseCases? notificationUseCases, this.onReadStateChanged}) {
    _useCases = notificationUseCases ?? NotificationUseCases(NotificationRepositoryImpl());
    _load();
  }

  /// Test-only: starts from a fixed state instead of hitting the real
  /// network/singleton wiring.
  @visibleForTesting
  NotificationsController.withState(this._state) : onReadStateChanged = null;

  Future<void> _load() async {
    _state = const NotificationsState(isLoading: true);
    notifyListeners();

    final result = await _useCases.getNotifications(page: 0, size: _pageSize);
    if (result.isSuccess && result.data != null) {
      final (items, hasMore) = result.data!;
      _state = NotificationsState(isLoading: false, notifications: items, hasMore: hasMore);
    } else {
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
    final result = await _useCases.getNotifications(page: nextPage, size: _pageSize);
    if (result.isSuccess && result.data != null) {
      final (items, hasMore) = result.data!;
      _state = _state.copyWith(
        isLoadingMore: false,
        notifications: [..._state.notifications, ...items],
        hasMore: hasMore,
        page: nextPage,
      );
    } else {
      // A failed "load more" keeps the page already on screen — just stop
      // spinning, the next scroll attempt retries naturally.
      _state = _state.copyWith(isLoadingMore: false);
    }
    notifyListeners();
  }

  /// Marks a single notification as read (optimistic) — tapping an item
  /// both reads it and navigates to its travel.
  Future<void> markAsRead(String id) async {
    final index = _state.notifications.indexWhere((n) => n.id == id);
    if (index == -1 || _state.notifications[index].read) return;

    _state = _state.copyWith(
      notifications: [
        for (final n in _state.notifications) n.id == id ? n.copyWith(read: true) : n,
      ],
    );
    notifyListeners();
    await _useCases.markAsRead(id);
    onReadStateChanged?.call();
  }

  Future<void> markAllRead() async {
    if (_state.notifications.every((n) => n.read)) return;

    final updated = _state.notifications.map((n) => n.copyWith(read: true)).toList();
    _state = _state.copyWith(notifications: updated);
    notifyListeners();
    await _useCases.markAllAsRead();
    onReadStateChanged?.call();
  }
}
