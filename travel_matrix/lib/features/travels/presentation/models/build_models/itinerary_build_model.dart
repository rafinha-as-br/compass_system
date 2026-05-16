import '../view_models/route_view_model.dart';
import '../view_models/itinerary_steps_view_models.dart';

/// Presentation model used to pass data into [ItineraryBuildPage].
///
/// [steps] is null in create mode and populated in edit mode.
class ItineraryBuildModel {
  final String travelName;
  final ItineraryStepsBuildModel? steps;
  final List<InterestPointViewModel> interestsPoints;

  ItineraryBuildModel({
    required this.travelName,
    required this.steps,
    required this.interestsPoints,
  });
}

/// Groups the itinerary steps into pinned start/finish and the editable middle steps.
class ItineraryStepsBuildModel {
  final List<ItineraryStepViewModel> normalSteps;
  final ItineraryStepViewModel startStep;
  final ItineraryStepViewModel finishStep;

  ItineraryStepsBuildModel({
    required this.normalSteps,
    required this.startStep,
    required this.finishStep,
  }){
    if(startStep.position != StepPosition.start){
      throw ArgumentError('Start step must be the first step');
    }
    if(finishStep.position != StepPosition.finish){
      throw ArgumentError('Finish step must be the last step');
    }
    if(normalSteps.isEmpty){
      throw ArgumentError('Normal steps must not be empty');
    }
    for(var step in normalSteps){
      if(step.position != StepPosition.middle){
        throw ArgumentError('Normal steps must be in the middle');
      }
    }

  }

  /// getter for the full list of steps, including start and finish steps.
  List<ItineraryStepViewModel> get stepsList => [startStep, ...normalSteps, finishStep];
}

