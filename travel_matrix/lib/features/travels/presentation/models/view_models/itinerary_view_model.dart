
import 'package:travel_matrix/features/travels/domain/entities/itinerary.dart';
import 'package:uuid/uuid.dart';

import 'itinerary_steps_view_models.dart';

/// Itinerary view model class, used to represent an [Itinerary] on the UI
class ItineraryViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? _backEndId;
  /// Id used for local reference
  final String localId;
  /// Agent name that created the itinerary
  final String agentName;
  /// List of [ItineraryStepViewModel]s that make up the itinerary
  final List<ItineraryStepViewModel> steps;

  /// Private constructor
  ItineraryViewModel._({
    required String? backEndId,
    required this.localId,
    required this.agentName,
    required this.steps
  }): _backEndId = backEndId;

  /// Provides the local ID for UI reference
  String get id => localId;

  /// Factory constructor for domain model
  factory ItineraryViewModel.fromDomain(Itinerary itinerary){
    if (itinerary.itinerarySteps.isEmpty) {
      return ItineraryViewModel._(
        backEndId: itinerary.backEndId,
        localId: itinerary.domainId,
        agentName: itinerary.agentName,
        steps: [],
      );
    }

    final startStep = itinerary.itinerarySteps.first;
    final finishStep = itinerary.itinerarySteps.last;

    return ItineraryViewModel._(
      backEndId: itinerary.backEndId,
      localId: itinerary.domainId,
      agentName: itinerary.agentName,
      steps: itinerary.itinerarySteps.map((x) => ItineraryStepViewModel.fromDomain(x, startStep == x, finishStep == x)).toList()
    );
  }

  /// Factory constructor for local model
  factory ItineraryViewModel.fromLocal(List<ItineraryStepViewModel> steps, String agentName){
    return ItineraryViewModel._(
      backEndId: null,
      localId: Uuid().v4(),
      agentName: agentName,
      steps: steps
    );
  }

  /// To domain mapper method
  Itinerary toDomain(){
    return Itinerary(
      domainId: localId,
      backEndId: _backEndId,
      agentName: agentName,
      itinerarySteps: steps.map((x) => x.toDomain()).toList()
    );
  }

}



