
import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/editor/itinerary_editor_controller.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/interest_points_panel.dart';


/// This page is responsible for creating and editing itineraries, having an
/// controller [ItineraryEditorController] that lives with this page.
///
/// The build model entity determines what type of action will be executed:
/// - If [ItineraryStepsBuildModel] is null, then the Page will be in create mode.
/// With the controller already creating a start and finish Step.
/// - If [ItineraryStepsBuildModel] is not null, then the Page will be in edit mode.
///
/// This page has a fix layout of 3 main parts: [InterestPointsPanel],
/// [StepsListPanel] and [StepFormPanel].
///
///
class ItineraryBuildPage extends StatefulWidget {
  const ItineraryBuildPage({super.key, required this.itineraryBuildModel});

  final ItineraryBuildModel itineraryBuildModel;

  @override
  State<ItineraryBuildPage> createState() => _ItineraryBuildPageState();
}

class _ItineraryBuildPageState extends State<ItineraryBuildPage> {

  /// Edit/Create mode checker method
  bool get isEditMode => widget.itineraryBuildModel.steps != null;


  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }




}
