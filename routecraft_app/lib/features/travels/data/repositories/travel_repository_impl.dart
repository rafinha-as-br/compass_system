import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/core/network/api_exception.dart';
import 'package:routecraft_app/features/travels/data/datasources/travel_data_source.dart';
import 'package:routecraft_app/features/travels/data/dtos/travel_dto.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/domain/repositories/travel_repository.dart';

class TravelRepositoryImpl implements TravelRepository {
  final TravelDataSource _dataSource;

  TravelRepositoryImpl({TravelDataSource? dataSource}) : _dataSource = dataSource ?? TravelDataSource();

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
      return Result.success(dtos.map((dto) => dto.toDomain()).toList());
    } on ApiException catch (e) {
      return Result.failure(e.message, isConnectivityError: e.isConnectivityError);
    } catch (_) {
      return const Result.failure('Não foi possível carregar as viagens.', isConnectivityError: true);
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
