/// No-op stand-in for every non-web platform (native VM tests, desktop AOT
/// builds) — `dart:js_interop`'s browser bindings only compile for a web
/// target, so [web_push_service_web.dart] (the real Web Push/VAPID
/// implementation) is selected instead via a conditional export in
/// `../web_push_service.dart`, and this file backs everything else.
class WebPushService {
  static WebPushService? _instance;
  static WebPushService get instance => _instance ??= WebPushService._();

  WebPushService._();

  /// Never invoked outside a web build — kept so callers don't need to know
  /// which implementation they got.
  void Function()? onMessage;

  Future<void> registerForPush() async {}

  Future<void> unregisterFromPush() async {}
}
