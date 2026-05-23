
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:uuid/uuid.dart';

import 'itinerary_steps_view_models.dart';

/// Itinerary view model class, used to represent an [Itinerary] on the UI
class ItineraryViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? _backEndId;
  /// Id used for local reference
  final String localId;
  /// Agent id
  final String _agentId;
  /// List of [ItineraryStepViewModel]s that make up the itinerary
  final List<ItineraryStepViewModel> steps;

  /// Private constructor
  ItineraryViewModel._({
    required String? backEndId,
    required this.localId,
    required String agentId,
    required this.steps
  }): _backEndId = backEndId, _agentId = agentId;

  /// Provides the local ID for UI reference
  String get id => localId;

  /// Factory constructor for domain model
  factory ItineraryViewModel.fromDomain(Itinerary itinerary){
    final startStep = itinerary.itinerarySteps.first;
    final finishStep = itinerary.itinerarySteps.last;

    return ItineraryViewModel._(
      backEndId: itinerary.backEndId,
      localId: itinerary.domainId,
      agentId: itinerary.agentId,
      steps: itinerary.itinerarySteps.map((x) => ItineraryStepViewModel.fromDomain(x, startStep == x, finishStep == x)).toList()
    );
  }

  /// Factory constructor for local model
  factory ItineraryViewModel.fromLocal(List<ItineraryStepViewModel> steps, String agentId){
    return ItineraryViewModel._(
      backEndId: null,
      localId: Uuid().v4(),
      agentId: agentId,
      steps: steps
    );
  }

  /// To domain mapper method
  Itinerary toDomain(){
    return Itinerary(
      domainId: localId,
      backEndId: _backEndId,
      agentId: _agentId,
      itinerarySteps: steps.map((x) => x.toDomain()).toList()
    );
  }

}



