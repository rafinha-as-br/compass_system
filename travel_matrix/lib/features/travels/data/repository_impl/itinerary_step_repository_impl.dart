
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/data/data_sources/itinerary_data_source.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary_step.dart';
import 'package:travel_matrix/features/travels/domain/repository/itinerary_step_repository.dart';

class ItineraryStepRepositoryImpl implements ItineraryStepRepository{
  @override
  Future<Result<ItineraryStep>> createItineraryStep(Map<String, dynamic> data) {
    // TODO: implement createItineraryStep
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> deleteItineraryStep(String id) {
    // TODO: implement deleteItineraryStep
    throw UnimplementedError();
  }

  @override
  Future<Result<ItineraryStep>> getItineraryStep(String id) async{
    try{
      final itineraryStepDto = await ItineraryDataSource().getItineraryStep(id);
      return Result.success(itineraryStepDto.toDomain());
    }catch(e){
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<List<ItineraryStep>>> getAllItineraryStep(String id) async{
    try{
      final itineraryStepDto = await ItineraryDataSource().getItinerarySteps(id);
      return Result.success(itineraryStepDto.map((e) => e.toDomain()).toList());
    } catch(e){
      return Result.failure(e.toString());
    }
  }



  @override
  Future<Result<ItineraryStep>> updateItineraryStep(Map<String, dynamic> data) {
    // TODO: implement updateItineraryStep
    throw UnimplementedError();
  }



}