import 'dart:async';

import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/core/services/auth_service.dart';
import 'package:routecraft_app/features/travels/data/datasources/travel_data_source.dart';
import 'package:routecraft_app/features/travels/data/dtos/travel_dto.dart';
import 'package:routecraft_app/features/travels/data/services/travel_cache_service.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';

class TravelRepositoryImpl implements TravelRepository {
  final TravelDataSource _dataSource;
  final TravelCacheService _cache;
  final Future<String?> Function()? _getClientNameOverride;
  final Future<CachedTravels?> Function(String clientName)? _readCacheOverride;

  /// [getClientName]/[readCache] are injectable for tests, without depending
  /// on the real `AuthService`/secure storage wiring — the real singletons
  /// are only touched when no override is given. Used to key the offline
  /// cache lookup in [getTravel] (CPS-98/CPS-129): the cache is keyed by
  /// client name, not by travel id, since it's populated from
  /// [getTravelsForClient].
  TravelRepositoryImpl({
    TravelDataSource? dataSource,
    TravelCacheService? cache,
    Future<String?> Function()? getClientName,
    Future<CachedTravels?> Function(String clientName)? readCache,
  })  : _dataSource = dataSource ?? TravelDataSource(),
        _cache = cache ?? const TravelCacheService(),
        _getClientNameOverride = getClientName,
        _readCacheOverride = readCache;

  Future<String?> _getClientName() => (_getClientNameOverride ?? AuthService.instance.getClientName)();

  Future<CachedTravels?> _readCache(String clientName) => (_readCacheOverride ?? _cache.readTravels)(clientName);

  @override
  Future<Result<Travel>> getTravel(String id) async {
    try {
      final dto = await _dataSource.getTravel(id);
      return Result.success(dto.toDomain());
    } on ApiException catch (e) {
      if (e.isConnectivityError) {
        final cached = await _cachedTravel(id);
        if (cached != null) return Result.success(cached);
      }
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      final cached = await _cachedTravel(id);
      if (cached != null) return Result.success(cached);
      return const Result.failure('Não foi possível carregar a viagem.', isConnectivityError: true);
    }
  }

  /// Looks up [id] among the requesting client's cached travels — the same
  /// cache `getTravelsForClient` writes to on success. A cache-read failure
  /// (missing client name, storage error, no cache yet) just means no
  /// fallback is available, never a crash.
  Future<Travel?> _cachedTravel(String id) async {
    try {
      final clientName = await _getClientName();
      if (clientName == null || clientName.isEmpty) return null;
      final cached = await _readCache(clientName);
      if (cached == null) return null;
      for (final travel in cached.travels) {
        if (travel.backEndId == id) return travel;
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  @override
  Future<Result<List<Travel>>> getTravelsForClient(String clientName) async {
    try {
      final dtos = await _dataSource.getTravelsForClient(clientName);
      // A cache-write failure (e.g. disk/keychain issue) must never turn an
      // otherwise-successful fetch into an apparent failure — offline
      // support is a bonus on top of the live result, not a precondition
      // for it.
      unawaited(_cacheSafely(clientName, dtos.map((dto) => dto.toJson()).toList()));
      return Result.success(dtos.map((dto) => dto.toDomain()).toList());
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível carregar as viagens.', isConnectivityError: true);
    }
  }

  Future<void> _cacheSafely(String clientName, List<Map<String, dynamic>> travelsJson) async {
    try {
      await _cache.saveTravels(clientName, travelsJson);
    } catch (_) {
      // Best-effort — see the comment at the call site.
    }
  }

  @override
  Future<Result<Travel>> createTravel(Travel travel) async {
    try {
      final created = await _dataSource.createTravel(TravelDTO.fromDomain(travel));
      return Result.success(created.toDomain());
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível criar a viagem.', isConnectivityError: true);
    }
  }
}
