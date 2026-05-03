
import 'package:travel_matrix/features/travels/presentation/view_models/itinerary_steps_view_models.dart';

import '../view_models/route_view_model.dart';

class ItineraryBuildModel{
  final String travelName;
  final List<ItineraryStepViewModel> normalSteps;
  final ItineraryStepViewModel startStep;
  final ItineraryStepViewModel finishStep;
  final List<InterestPointViewModel> interestsPoints;

  ItineraryBuildModel({
    required this.travelName,
    required this.normalSteps,
    required this.startStep,
    required this.finishStep,
    required this.interestsPoints
  });

}