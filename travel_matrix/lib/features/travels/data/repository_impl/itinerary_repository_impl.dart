
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/repository/itinerary_repository.dart';

import '../data_sources/itinerary_data_source.dart';

class ItineraryRepositoryImpl implements ItineraryRepository{

  @override
  Future<Result> createItinerary(Itinerary itinerary) async{
    try{
      final data = itinerary.toJson();
      await ItineraryDataSource().createItinerary(data);
      return Result.success();
    } catch(e){
      return Result.failure(e.toString());
    }

  }

  @override
  Future<Result> deleteItinerary(String id) async {
    try{
      ItineraryDataSource().deleteItinerary(id);
      return Result.success();
    } catch(e){
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Itinerary>> getItinerary(String id) async{
    try{
      final itineraryDto = await ItineraryDataSource().getItinerary(id);
      final steps = await ItineraryDataSource().getItinerarySteps(id);
      return Result.success(
          itineraryDto.toDomain(steps.map((e) => e.toDomain()).toList())
      );

    } catch(e){
      return Result.failure(e.toString());
    }

  }

  @override
  Future<Result<Itinerary>> updateItinerary(Map<String, dynamic> data) {
    // TODO: implement updateItinerary
    throw UnimplementedError();
  }



}