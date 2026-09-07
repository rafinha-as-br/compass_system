import 'dart:async';

import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/features/travels/data/datasources/travel_data_source.dart';
import 'package:routecraft_app/features/travels/data/dtos/travel_dto.dart';
import 'package:routecraft_app/features/travels/data/services/travel_cache_service.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';

class TravelRepositoryImpl implements TravelRepository {
  final TravelDataSource _dataSource;
  final TravelCacheService _cache;

  TravelRepositoryImpl({TravelDataSource? dataSource, TravelCacheService? cache})
      : _dataSource = dataSource ?? TravelDataSource(),
        _cache = cache ?? const TravelCacheService();

  @override
  Future<Result<Travel>> getTravel(String id) async {
    try {
      final dto = await _dataSource.getTravel(id);
      return Result.success(dto.toDomain());
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível carregar a viagem.', isConnectivityError: true);
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
