
import 'package:travel_matrix/features/travels/data/data_sources/travel_data_source.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/itinerary_repository_impl.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/route_repository.dart';
import 'package:travel_matrix/features/travels/domain/repository/itinerary_repository.dart';
import 'package:travel_matrix/features/travels/domain/repository/route_repository.dart';
import 'package:travel_matrix/features/travels/domain/repository/travel_repository.dart';

import '../../../../core/entities/result.dart';
import '../../domain/entities/travel.dart';

class TravelRepositoryImpl implements TravelRepository{
  final TravelDataSource _travelDataSource = TravelDataSource();
  final RouteRepository _routeRepository = RouteRepositoryImpl();
  final ItineraryRepository _itineraryRepository = ItineraryRepositoryImpl();

  @override
  Future<Result<Travel>> getTravel(String id) async{
    try{
      final travelDto = await _travelDataSource.getTravel(id);
      final routeDomain = await _routeRepository.getRoute(travelDto.routePlan);
      final personsDTO = await _travelDataSource.getPersons(travelDto.participants);

      if(travelDto.this.itinerary != null){
        final itineraryDomain = await _itineraryRepository.getItinerary(
            travelDto.this.itinerary!
        );

        final travel = travelDto.toDomain(
            routeDomain.data!,
            personsDTO.map((e) => e.toDomain()).toList(),
            itinerary: itineraryDomain.data
        );

        return Result.success(travel);
      } else{

        final travel = travelDto.toDomain(
          routeDomain.data!,
          personsDTO.map((e) => e.toDomain()).toList()
        );

        return Result.success(travel);
      }


    } catch(e){
      return Result.failure(e.toString());
    }
  }

  @override
  Future<Result<Travel>> createTravel(Map<String, dynamic> data) {
    // TODO: implement createTravel
    throw UnimplementedError();
  }

  @override
  Future<Result<bool>> deleteTravel(String id) {
    // TODO: implement deleteTravel
    throw UnimplementedError();
  }

  @override
  Future<Result<Travel>> updateTravel(Map<String, dynamic> data) {
    // TODO: implement updateTravel
    throw UnimplementedError();
  }




}