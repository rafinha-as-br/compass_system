import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:routecraft_app/app/router/app_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/core/network/clients/push_target_api_client.dart';
import 'package:routecraft_app/core/network/http_api_client.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:unifiedpush/unifiedpush.dart';

/// Owns the whole push-notification lifecycle for Android (UnifiedPush): one-
/// time setup at app start, kicking off registration after login, finishing
/// that registration with the backend once the distributor hands back an
/// endpoint, unregistering at logout, and turning an incoming push into a
/// local system notification — skipped while the app is in the foreground
/// (RN: never a redundant system banner on top of the in-app UI updating on
/// its own).
class PushService {
  static const _instanceId = 'default';
  static const _pushTargetIdKey = 'push_target_id';
  static const _androidChannelId = 'compass_notifications';

  static PushService? _instance;
  static PushService get instance {
    assert(_instance != null, 'PushService not initialized!');
    return _instance!;
  }

  final FlutterSecureStorage _storage;
  final PushTargetApiClient _apiClient;
  final FlutterLocalNotificationsPlugin _localNotifications;

  PushService._()
      : _storage = const FlutterSecureStorage(),
        _apiClient = PushTargetApiClient(HttpApiClient.instance),
        _localNotifications = FlutterLocalNotificationsPlugin();

  static String? _pendingLaunchTravelId;

  /// Call once at app startup — wires the UnifiedPush callbacks and the local
  /// notification plugin. Safe before the user is authenticated: nothing
  /// here talks to the backend until a push actually arrives or
  /// [registerForPush] is called. Idempotent, and never throws: push is a
  /// non-critical feature and must never prevent the app from booting.
  static Future<PushService> init() async {
    if (_instance != null) return _instance!;
    final service = PushService._();
    try {
      final launchDetails = await service._initLocalNotifications();
      if (launchDetails?.didNotificationLaunchApp ?? false) {
        _pendingLaunchTravelId = launchDetails?.notificationResponse?.payload;
      }
      await UnifiedPush.initialize(
        onNewEndpoint: service._onNewEndpoint,
        onUnregistered: service._onUnregistered,
        onMessage: service._onMessage,
      );
    } catch (_) {
      // Best-effort — a broken plugin never blocks app boot.
    }
    _instance = service;
    return service;
  }

  /// Consumes (clears) the deep-link target from a cold-start notification
  /// tap, if any. `_onNotificationTap` can't navigate directly in that case —
  /// it runs before `AppRouter.instance` exists — so `AppBootstrap` calls
  /// this once the router is actually built (CPS-148).
  static String? consumePendingLaunchTravelId() {
    final id = _pendingLaunchTravelId;
    _pendingLaunchTravelId = null;
    return id;
  }

  Future<NotificationAppLaunchDetails?> _initLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(settings, onDidReceiveNotificationResponse: _onNotificationTap);
    return _localNotifications.getNotificationAppLaunchDetails();
  }

  /// Kicks off UnifiedPush registration — call after a successful login, and
  /// at app start when a session is already active (the plugin's own
  /// contract expects registration to be (re-)requested on every launch).
  /// Fire-and-forget by design: no distributor installed, or a failed
  /// registration, never blocks or fails the caller — the user just won't
  /// get push.
  Future<void> registerForPush() async {
    try {
      final hasDistributor = await UnifiedPush.tryUseCurrentOrDefaultDistributor();
      if (!hasDistributor) return;
      await UnifiedPush.register(instance: _instanceId);
    } catch (_) {
      // Nothing else in the app depends on push actually working.
    }
  }

  /// Unregisters this device's push target — call at logout, before the JWT
  /// is cleared, since the DELETE call needs a still-valid Bearer token.
  Future<void> unregisterFromPush() async {
    final token = await AuthService.instance.getToken();
    final targetId = await _storage.read(key: _pushTargetIdKey);
    if (token != null && targetId != null) {
      try {
        await _apiClient.unregister(token, targetId);
      } catch (_) {
        // Best-effort — never blocks logout.
      }
    }
    await _clearStoredTargetId();
    try {
      await UnifiedPush.unregister(_instanceId);
    } catch (_) {
      // Distributor may already be gone — nothing to clean up on its side then.
    }
  }

  /// Best-effort — a secure-storage failure here must never block a caller
  /// (logout, in particular) that's counting on this to always complete.
  Future<void> _clearStoredTargetId() async {
    try {
      await _storage.delete(key: _pushTargetIdKey);
    } catch (_) {
      // Nothing else in the app depends on this succeeding.
    }
  }

  Future<void> _onNewEndpoint(PushEndpoint endpoint, String instance) async {
    final token = await AuthService.instance.getToken();
    if (token == null) return; // not signed in yet — nothing to register against
    try {
      final result = await _apiClient.registerAndroid(token, endpoint.url);
      final id = result['id'] as String?;
      if (id != null) {
        await _storage.write(key: _pushTargetIdKey, value: id);
      }
    } catch (_) {
      // RN (CPS-146/148): a failed registration never surfaces to the user.
    }
  }

  /// The distributor cancelled this registration on its own (e.g. the user
  /// revoked it there) — the stored id is now stale; the next
  /// [registerForPush] mints a fresh one and overwrites it.
  void _onUnregistered(String instance) {
    unawaited(_clearStoredTargetId());
  }

  Future<void> _onMessage(PushMessage message, String instance) async {
    if (WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed) {
      return;
    }

    final payload = _decodePayload(message.content);
    final travelId = payload?['travelId'] as String?;
    final body = payload?['message'] as String? ?? utf8.decode(message.content, allowMalformed: true);

    final l10n = await _loadLocalizations();
    await _showLocalNotification(title: l10n.pushNotificationTitle, body: body, travelId: travelId);
  }

  Map<String, dynamic>? _decodePayload(Uint8List bytes) {
    try {
      return jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  /// No `BuildContext` exists here (this runs from a plugin callback, not
  /// the widget tree) — `AppLocalizations.delegate` is the same object the
  /// framework uses internally, just loaded directly for the device's locale.
  Future<AppLocalizations> _loadLocalizations() async {
    final languageCode = WidgetsBinding.instance.platformDispatcher.locale.languageCode;
    final supported = AppLocalizations.supportedLocales.firstWhere(
      (locale) => locale.languageCode == languageCode,
      orElse: () => AppLocalizations.supportedLocales.first,
    );
    return AppLocalizations.delegate.load(supported);
  }

  Future<void> _showLocalNotification({required String title, required String body, String? travelId}) async {
    const androidDetails = AndroidNotificationDetails(
      _androidChannelId,
      'Notificações',
      importance: Importance.high,
      priority: Priority.high,
    );
    const details = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
      DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: travelId,
    );
  }

  /// `push` would risk the same shell-branch trap CPS-121 already fixed for
  /// in-app navigation — a tap can land here from any branch, or from no
  /// branch at all (app was fully closed), so `go` is the only correct verb.
  void _onNotificationTap(NotificationResponse response) {
    final travelId = response.payload;
    if (travelId == null) return;
    AppRouter.instance?.router.go('${AppRoutes.homeFollowTravel}?${AppRoutes.travelIdQuery(travelId)}');
  }
}
