import 'package:flutter/foundation.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/core/services/web_push_service.dart';
import 'package:travel_matrix/features/notifications/data/repository_impl/notification_repository_impl.dart';
import 'package:travel_matrix/features/notifications/domain/usecases/notification_usecases.dart';

/// Backs the unread-count badge on the sidebar's bell icon (CPS-149) — the
/// single source of truth every read-state change reports back to
/// ([onAuthChanged] for session start/end, [NotificationsController] for a
/// mark-as-read write, [WebPushService.onMessage] for a live push), instead
/// of each one keeping its own copy of the count.
class NotificationsBadgeController extends ChangeNotifier {
  final NotificationUseCases _useCases;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  NotificationsBadgeController({NotificationUseCases? useCases})
      : _useCases = useCases ?? NotificationUseCases(NotificationRepositoryImpl()) {
    WebPushService.instance.onMessage = refresh;
  }

  /// Always re-fetches from the server — RN: the indicator must never be a
  /// local optimistic-only counter without sync.
  Future<void> refresh() async {
    final result = await _useCases.getUnreadCount();
    if (result.isSuccess) {
      _unreadCount = result.data ?? 0;
      notifyListeners();
    }
  }

  void reset() {
    if (_unreadCount == 0) return;
    _unreadCount = 0;
    notifyListeners();
  }

  /// Wired to [AuthController] via `ChangeNotifierProxyProvider` — refreshes
  /// on login/app boot with an existing session, resets on logout so a
  /// different account signing in on the same tab never briefly shows the
  /// previous agent's count.
  void onAuthChanged(AuthController auth) {
    if (auth.isAuthenticated) {
      refresh();
    } else {
      reset();
    }
  }
}
