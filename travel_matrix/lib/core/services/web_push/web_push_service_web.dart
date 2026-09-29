import 'dart:convert';
import 'dart:js_interop';
import 'dart:js_interop_unsafe';
import 'dart:typed_data';

import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/clients/push_target_api_client.dart';
import 'package:web/web.dart' as web;

/// Owns the Web Push (VAPID) lifecycle for the browser's native `Push API`
/// (CPS-149) — no Firebase/vendor SDK involved. Registration happens after
/// login, removal before logout; an incoming push is shown and relayed by
/// `web/push/push_worker.js` (a plain JS service worker), which this class
/// only talks to via `postMessage`.
///
/// Selected only for web builds (see `../web_push_service.dart`'s
/// conditional export) — [web_push_service_stub.dart] backs every other
/// platform, since `dart:js_interop`'s browser bindings don't compile for a
/// native VM/AOT target.
class WebPushService {
  /// Registered at its own scope (`/push/`), deliberately separate from
  /// Flutter's own root-scoped (`/`) asset-caching worker — two workers
  /// registered at the identical scope replace each other, which would
  /// silently drop this one's `push`/`notificationclick` handlers.
  static const _swPath = 'push/push_worker.js';
  static const _swScope = '/push/';

  static WebPushService? _instance;
  static WebPushService get instance => _instance ??= WebPushService._();

  final PushTargetApiClient _apiClient;
  final AuthStorageService _storage;
  web.ServiceWorkerRegistration? _registration;
  bool _messageListenerAttached = false;

  /// Called when a push arrives while a tab is open, foreground or not, so
  /// the sidebar's unread badge can refresh from the server immediately
  /// instead of waiting for the next navigation.
  void Function()? onMessage;

  WebPushService._()
      : _apiClient = PushTargetApiClient.instance,
        _storage = AuthStorageService.instance;

  bool get _supported => web.window.navigator.has('serviceWorker');

  /// Fire-and-forget by design — call after a successful login/app boot with
  /// an existing session. No distributor/permission/subscription failure
  /// ever surfaces to the caller.
  Future<void> registerForPush() async {
    if (!_supported) return;
    try {
      // Checked first — everything below is either a user-facing permission
      // prompt or a network round trip, both wasted without a token to
      // register against.
      final token = await _storage.getToken();
      if (token == null || token.isEmpty) return;

      final registration = await _ensureServiceWorker();
      _listenForMessages();

      final permission = (await web.Notification.requestPermission().toDart).toDart;
      if (permission != 'granted') return;

      final vapidResult = await _apiClient.getVapidPublicKey(token);
      final publicKey = vapidResult['publicKey'] as String?;
      if (publicKey == null || publicKey.isEmpty) return;

      final subscription = await registration.pushManager
          .subscribe(
            web.PushSubscriptionOptionsInit(
              userVisibleOnly: true,
              applicationServerKey: _urlBase64ToUint8Array(publicKey).toJS,
            ),
          )
          .toDart;

      final json = subscription.toJSON();
      final keys = json.keys;
      final p256dh = keys.getProperty<JSString?>('p256dh'.toJS)?.toDart;
      final auth = keys.getProperty<JSString?>('auth'.toJS)?.toDart;
      if (p256dh == null || auth == null) return;

      final result = await _apiClient.registerWeb(token, endpoint: subscription.endpoint, p256dh: p256dh, auth: auth);
      final id = result['id'] as String?;
      if (id != null) {
        await _storage.saveWebPushTargetId(id);
      }
    } catch (_) {
      // Best-effort — nothing else in the app depends on push working.
    }
  }

  /// Call at logout, before the JWT is cleared — the DELETE call needs a
  /// still-valid Bearer token.
  Future<void> unregisterFromPush() async {
    if (!_supported) return;

    final token = await _storage.getToken();
    final targetId = await _storage.getWebPushTargetId();
    if (token != null && targetId != null) {
      try {
        await _apiClient.unregister(token, targetId);
      } catch (_) {
        // Best-effort — never blocks logout.
      }
    }
    await _storage.clearWebPushTargetId();

    try {
      final registration =
          _registration ?? await web.window.navigator.serviceWorker.getRegistration(_swScope).toDart;
      final subscription = await registration?.pushManager.getSubscription().toDart;
      await subscription?.unsubscribe().toDart;
    } catch (_) {
      // Subscription may already be gone — nothing else to clean up.
    }
  }

  Future<web.ServiceWorkerRegistration> _ensureServiceWorker() async {
    final existing = _registration;
    if (existing != null) return existing;
    final registration =
        await web.window.navigator.serviceWorker.register(_swPath.toJS, web.RegistrationOptions(scope: _swScope)).toDart;
    _registration = registration;
    return registration;
  }

  /// Relays `push_worker.js`'s `postMessage` calls — the only way a
  /// background push (tab not focused) can reach this already-running page.
  void _listenForMessages() {
    if (_messageListenerAttached) return;
    _messageListenerAttached = true;
    web.window.navigator.serviceWorker.addEventListener('message', _onServiceWorkerMessage.toJS);
  }

  void _onServiceWorkerMessage(web.Event event) {
    final data = (event as web.MessageEvent).data;
    if (data == null) return;
    onMessage?.call();
  }

  /// The VAPID public key arrives base64url-encoded (RFC 4648 §5); the Push
  /// API's `applicationServerKey` wants the raw bytes.
  Uint8List _urlBase64ToUint8Array(String base64String) {
    return base64Url.decode(base64Url.normalize(base64String));
  }
}
