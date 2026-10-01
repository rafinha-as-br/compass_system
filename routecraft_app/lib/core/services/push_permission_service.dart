import 'package:permission_handler/permission_handler.dart';

/// Thin wrapper over `permission_handler`'s static API — its own class
/// (rather than calling `Permission.notification` inline in a controller) so
/// callers can inject a fake in tests, matching the rest of the app's
/// "static default, injectable override" convention.
class PushPermissionService {
  const PushPermissionService._();

  /// Requests the OS notification permission (Android 13+; a no-op grant on
  /// older versions) unless it's already granted or permanently denied — a
  /// soft denial can still be re-prompted, matching normal Android UX.
  static Future<void> requestIfNeeded() async {
    final status = await Permission.notification.status;
    if (status.isDenied) {
      await Permission.notification.request();
    }
  }
}
