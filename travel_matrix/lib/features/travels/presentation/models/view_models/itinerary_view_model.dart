
import 'package:uuid/uuid.dart';

import 'itinerary_steps_view_models.dart';

/// Itinerary view model class, used to represent an itinerary on the UI
class ItineraryViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  final List<ItineraryStepViewModel> steps;

  /// Private constructor
  ItineraryViewModel._({
    required this.backEndId,
    required this.localId,
    required this.steps
  });

  /// Provides the local ID for UI reference
  String get id => localId;

  /// Factory constructor for domain model
  factory ItineraryViewModel.fromDomain(String backEndId, List<ItineraryStepViewModel> steps){
    return ItineraryViewModel._(
      backEndId: backEndId,
      localId: Uuid().v4(),
      steps: steps
    );
  }

  /// Factory constructor for local model
  factory ItineraryViewModel.fromLocal(List<ItineraryStepViewModel> steps){
    return ItineraryViewModel._(
      backEndId: null,
      localId: Uuid().v4(),
      steps: steps
    );
  }

}



