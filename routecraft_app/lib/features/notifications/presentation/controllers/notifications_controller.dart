import 'package:flutter/foundation.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/notifications/data/repositories/secure_notification_storage.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/domain/repositories/notification_storage.dart';
import 'package:routecraft_app/features/travels/data/repositories/travel_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/usecases/travel_usecases.dart';

class NotificationsState {
  final bool isLoading;
  final List<TravelNotification> notifications;

  const NotificationsState({this.isLoading = true, this.notifications = const []});

  NotificationsState copyWith({bool? isLoading, List<TravelNotification>? notifications}) => NotificationsState(
        isLoading: isLoading ?? this.isLoading,
        notifications: notifications ?? this.notifications,
      );
}

class NotificationsController extends ChangeNotifier {
  NotificationsState _state = const NotificationsState();
  NotificationsState get state => _state;

  final NotificationStorage? _storageOverride;
  final TravelUseCases? _travelUseCasesOverride;

  /// [storage]/[travelUseCases] are injectable for tests, without depending
  /// on the real `flutter_secure_storage` platform channel or network.
  NotificationsController({NotificationStorage? storage, TravelUseCases? travelUseCases})
      : _storageOverride = storage,
        _travelUseCasesOverride = travelUseCases {
    _load();
  }

  /// Test-only: starts from a fixed state instead of hitting real storage.
  @visibleForTesting
  NotificationsController.withState(this._state)
      : _storageOverride = null,
        _travelUseCasesOverride = null;

  NotificationStorage get _storage => _storageOverride ?? SecureNotificationStorage();
  TravelUseCases get _travelUseCases => _travelUseCasesOverride ?? TravelUseCases(TravelRepositoryImpl());

  /// Resolves a notification's `travelId` into the full [Travel] the
  /// itinerary hub needs — only the lightweight id survives a restart, so
  /// this re-fetches rather than trying to keep a stale `Travel` around.
  Future<Travel?> resolveTravel(String travelId) async {
    final result = await _travelUseCases.getTravel(travelId);
    return switch (result) {
      Success<Travel>(data: final travel) => travel,
      Failure<Travel>() => null,
    };
  }

  Future<void> _load() async {
    final notifications = await _storage.loadNotifications();
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _state = NotificationsState(isLoading: false, notifications: notifications);
    notifyListeners();
  }

  Future<void> markAllRead() async {
    if (_state.notifications.every((n) => n.read)) return;

    final updated = _state.notifications.map((n) => n.copyWith(read: true)).toList();
    _state = _state.copyWith(notifications: updated);
    notifyListeners();
    await _storage.saveNotifications(updated);
  }
}
