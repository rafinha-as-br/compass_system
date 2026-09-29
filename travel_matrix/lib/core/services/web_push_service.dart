// `WebPushService.instance` — see `web_push/web_push_service_web.dart` for
// the real Web Push (VAPID) implementation, used on web builds (dart2js,
// DDC, and dart2wasm — `dart.library.js_interop` covers all three, unlike
// the legacy `dart.library.html`, which dart2wasm doesn't provide). Every
// other target (native VM tests, desktop AOT builds) gets
// `web_push/web_push_service_stub.dart`'s no-op instead, since
// `dart:js_interop`'s browser bindings don't compile outside a web target.
export 'web_push/web_push_service_stub.dart'
    if (dart.library.js_interop) 'web_push/web_push_service_web.dart';
