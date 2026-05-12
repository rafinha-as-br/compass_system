
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:travel_matrix/features/travels/domain/repository/itinerary_repository.dart';

import '../entities/itinerary_step.dart';

/// Uses Cases responsible for CRUD operations on Itinerary entity.
class CrudItinerary{
  final ItineraryRepository repository;

  CrudItinerary(this.repository);

  /// Using [ItineraryRepository], creates an Itinerary on the API.
  ///
  /// This method checks the entity for possible data conflicts and applies business rules
  Future<Result> create(String travelId, Itinerary itinerary) async{


    /// business rules


    /// repository call
    return await repository.createItinerary(itinerary);

  }

  /// Using [ItineraryRepository], gets an Itinerary from the API.
  Future<Result<Itinerary>> read(String id) async{
    return await repository.getItinerary(id);
  }

  /// Using [ItineraryRepository], updates an Itinerary on the API.
  Future<Result> update(UpdateParams params) async{
    return await repository.updateItinerary(params.toJson());
  }



  /// Using [ItineraryRepository], deletes an Itinerary from the API.
  Future<Result> delete(String id) async{
    return await repository.deleteItinerary(id);
  }

}

/// Parameters used to update an Itinerary.
class UpdateParams{
  final String travelId;
  final String id;
  final List<ItineraryStep> itinerarySteps;

  UpdateParams({required this.travelId, required this.id, required this.itinerarySteps});

  /// to json method
  Map<String, dynamic> toJson(){
    return {
      'travelId': travelId,
      'id': id,
      'itinerarySteps': itinerarySteps.map((e) => e.toJson()).toList(),
    };
  }

}