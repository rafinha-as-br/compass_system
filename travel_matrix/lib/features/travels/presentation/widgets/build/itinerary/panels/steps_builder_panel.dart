import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/editor/itinerary_editor_controller.dart';
import 'package:travel_matrix/features/travels/presentation/view_models/itinerary_steps_view_models.dart';

/// This panel is responsible for building/editing an [ItineraryStepViewModel],
/// consuming [ItineraryEditorController]
class StepsBuilderPanel extends StatefulWidget {
  const StepsBuilderPanel({super.key});

  @override
  State<StepsBuilderPanel> createState() => _StepsBuilderPanelState();
}

class _StepsBuilderPanelState extends State<StepsBuilderPanel> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
