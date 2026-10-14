import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/core/services/web_push_service.dart';
import 'package:travel_matrix/features/notifications/data/repository_impl/notification_repository_impl.dart';
import 'package:travel_matrix/features/notifications/domain/usecases/notification_usecases.dart';

/// Backs the unread-count badge on the sidebar's bell icon (CPS-149) — the
/// single source of truth every read-state change reports back to
/// ([onAuthChanged] for session start/end, [NotificationsController] for a
/// mark-as-read write, [WebPushService.onMessage] for a live push), instead
/// of each one keeping its own copy of the count.
///
/// Without a granted push permission nothing above fires when a client
/// creates or edits a route, so while a session is active the count is also
/// re-fetched on every navigation ([navigation]), when the tab becomes
/// visible again, and every [pollInterval] while the tab stays visible —
/// no persistent channel, one light request per tick.
class NotificationsBadgeController extends ChangeNotifier with WidgetsBindingObserver {
  static const pollInterval = Duration(seconds: 60);

  final NotificationUseCases _useCases;
  final Listenable? _navigation;

  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  bool _signedIn = false;
  int _latestFetch = 0;
  Timer? _pollTimer;

  NotificationsBadgeController({NotificationUseCases? useCases, Listenable? navigation})
      : _useCases = useCases ?? NotificationUseCases(NotificationRepositoryImpl()),
        _navigation = navigation {
    WebPushService.instance.onMessage = refresh;
    _navigation?.addListener(_onNavigation);
    WidgetsBinding.instance.addObserver(this);
  }

  /// Always re-fetches from the server — RN: the indicator must never be a
  /// local optimistic-only counter without sync.
  Future<void> refresh() async {
    final fetchId = ++_latestFetch;
    final result = await _useCases.getUnreadCount();
    // Only the newest fetch may apply: an older response landing late (or
    // after logout/dispose) must not overwrite a fresher count.
    if (fetchId == _latestFetch && result.isSuccess) {
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
    _signedIn = auth.isAuthenticated;
    if (_signedIn) {
      refresh();
      _startPolling();
    } else {
      _latestFetch++;
      _stopPolling();
      reset();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_signedIn) return;
    if (state == AppLifecycleState.resumed) {
      refresh();
      _startPolling();
    } else {
      _stopPolling();
    }
  }

  void _onNavigation() {
    if (_signedIn) refresh();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(pollInterval, (_) => refresh());
  }

  void _stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  @override
  void dispose() {
    _latestFetch++;
    if (WebPushService.instance.onMessage == refresh) WebPushService.instance.onMessage = null;
    _stopPolling();
    _navigation?.removeListener(_onNavigation);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
