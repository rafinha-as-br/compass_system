import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/repository/itinerary_repository.dart';
import 'package:travel_matrix/features/travels/data/dtos/itinerary_dto.dart';
import '../data_sources/itinerary_data_source.dart';

class ItineraryRepositoryImpl implements ItineraryRepository {
  final ItineraryDataSource _dataSource = ItineraryDataSource();

  @override
  Future<Result<Itinerary>> upsertItinerary(String travelId, Itinerary itinerary) async {
    try {
      final dto = ItineraryDTO.fromDomain(itinerary: itinerary);
      final updatedDto = await _dataSource.upsertItinerary(travelId, dto);
      return Result.success(updatedDto.toDomain());
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}