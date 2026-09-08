import 'package:flutter/foundation.dart';

/// Whether the travels currently shown came from the local cache instead of
/// a live fetch, and when that cache was last synced. Only Início
/// (`HomeController`) actually fetches from the backend — the hub and
/// timeline pages just render whatever `Travel` they were handed — so this
/// is how those downstream screens know to show the same offline banner
/// (CPS-98) without fetching anything themselves.
class TravelSyncStatusController extends ChangeNotifier {
  bool _isOffline = false;
  DateTime? _syncedAt;

  bool get isOffline => _isOffline;
  DateTime? get syncedAt => _syncedAt;

  void update({required bool isOffline, DateTime? syncedAt}) {
    if (_isOffline == isOffline && _syncedAt == syncedAt) return;
    _isOffline = isOffline;
    _syncedAt = syncedAt;
    notifyListeners();
  }
}
