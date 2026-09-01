import 'package:travel_matrix/features/travels/data/data_sources/travel_data_source.dart';
import 'package:travel_matrix/features/travels/domain/repository/travel_repository.dart';
import 'package:travel_matrix/features/travels/data/dtos/travel_dto.dart';
import '../../../../core/entities/result.dart';
import '../../domain/entities/travel.dart';

class TravelRepositoryImpl implements TravelRepository {
  final TravelDataSource _travelDataSource = TravelDataSource();

  @override
  Future<Result<Travel>> getTravel(String id) async {
    try {
      final travelDto = await _travelDataSource.getTravel(id);
      return Result.success(travelDto.toDomain());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<Travel>>> getAllTravels() async {
    try {
      final travelDtos = await _travelDataSource.getAllTravels();
      return Result.success(travelDtos.map((dto) => dto.toDomain()).toList());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Travel>> createTravel(Travel travel) async {
    try {
      final travelDto = TravelDTO.fromDomain(travel: travel);
      final createdDto = await _travelDataSource.createTravel(travelDto);
      return Result.success(createdDto.toDomain());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Travel>> createTravelFromRequest(Map<String, dynamic> request) async {
    try {
      final createdDto = await _travelDataSource.createTravelFromRequest(request);
      return Result.success(createdDto.toDomain());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<bool>> deleteTravel(String id) async {
    try {
      await _travelDataSource.deleteTravel(id);
      return const Result.success(true);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Travel>> updateTravel(Travel travel) async {
    try {
      if (travel.backEndId == null) {
        return const Result.failure("Cannot update travel without an ID");
      }
      final travelDto = TravelDTO.fromDomain(travel: travel);
      final updatedDto = await _travelDataSource.updateTravel(travel.backEndId!, travelDto);
      return Result.success(updatedDto.toDomain());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}