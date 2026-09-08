import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:routecraft_app/features/travels/data/dtos/travel_dto.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';

/// A client's travels as last read from a successful fetch, plus when that
/// fetch happened — read back when a later fetch fails for lack of
/// connection (CPS-98).
class CachedTravels {
  final List<Travel> travels;
  final DateTime syncedAt;

  const CachedTravels({required this.travels, required this.syncedAt});
}

/// Persists the raw API JSON for a client's travels (not a domain
/// round-trip — `TravelDTO.fromJson`/`toJson` already cover every field,
/// including `itinerary`) so the roteiro stays legible without a network
/// connection. Keyed by client name: only one client is ever logged in on a
/// device at a time, but this avoids stale data leaking across accounts.
class TravelCacheService {
  final FlutterSecureStorage _storage;

  const TravelCacheService({FlutterSecureStorage storage = const FlutterSecureStorage()}) : _storage = storage;

  Future<void> saveTravels(String clientName, List<Map<String, dynamic>> travelsJson) async {
    await _storage.write(key: _travelsKey(clientName), value: jsonEncode(travelsJson));
    await _storage.write(key: _syncedAtKey(clientName), value: DateTime.now().toIso8601String());
  }

  Future<CachedTravels?> readTravels(String clientName) async {
    final rawTravels = await _storage.read(key: _travelsKey(clientName));
    final rawSyncedAt = await _storage.read(key: _syncedAtKey(clientName));
    if (rawTravels == null || rawSyncedAt == null) return null;

    final travels = (jsonDecode(rawTravels) as List<dynamic>)
        .map((json) => TravelDTO.fromJson(json as Map<String, dynamic>).toDomain())
        .toList();
    return CachedTravels(travels: travels, syncedAt: DateTime.parse(rawSyncedAt));
  }

  static String _travelsKey(String clientName) => 'cached_travels_$clientName';
  static String _syncedAtKey(String clientName) => 'cached_travels_synced_at_$clientName';
}
