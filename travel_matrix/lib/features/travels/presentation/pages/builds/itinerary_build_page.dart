import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/build/itinerary_build_controller.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/editor/itinerary_editor_controller.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/update/itinerary_update_controller.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/interest_points_panel.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/steps_builder_panel.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/steps_list_panel.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/step_type_selector.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/stop_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/hosting_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/forms/travel_segment_form_widget.dart';

import '../../../data/repository_impl/itinerary_repository_impl.dart';
import '../../../domain/repository/itinerary_repository.dart';
import '../../../domain/usecases/crud_itinerary.dart';
import '../../models/build_models/itinerary_build_model.dart';
import '../../models/view_models/itinerary_steps_view_models.dart';
import '../../models/view_models/transports_view_model.dart';

/// Page responsible for creating and editing an [Itinerary] for a travel.
///
/// Receiving a [ItineraryBuildModel] as input for consuming, the consumed entity is used to:
///
/// - Determine the page mode:
///   - [steps] == null → **create mode**: starts with an empty step list.
///   - [steps] != null → **edit mode**: loads existing steps for editing.
/// - Used as the origin data source for the [ItineraryEditorController].
///
/// Layout: three-column fixed structure:
/// - Left  → [InterestPointsPanel] (route interest points checklist)
/// - Center → [StepsBuilderPanel] (type selector / concrete form)
/// - Right  → [StepsListPanel] (ordered, reorderable list)
/// NOTE: The widgets below are presentational widgets, consuming data passed by [ItineraryEditorController].
///
class ItineraryBuildPage extends StatelessWidget {
  const ItineraryBuildPage({
    super.key,
    required this.itineraryBuildModel,
    required this.travelId,
  });

  /// Constructor build model class for [ItineraryBuildPage]
  final ItineraryBuildModel itineraryBuildModel;

  /// travel id for creating the itinerary
  final String travelId;

  /// True when editing an existing itinerary (steps != null).
  bool get isEditMode => itineraryBuildModel.steps != null;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ItineraryRepository dependency injection
        Provider<ItineraryRepository>(create: (_) => ItineraryRepositoryImpl()),

        // CrudItinerary use cases dependency injection
        ProxyProvider<ItineraryRepository, CrudItinerary>(
          update: (_, repo, __) => CrudItinerary(repo),
        ),

        // Editor controller dependency injection
        ChangeNotifierProvider(
            create: (_) => ItineraryEditorController(
              stepsList: isEditMode ? itineraryBuildModel.steps!.normalSteps : null,
              interestPoints: itineraryBuildModel.interestsPoints,
            )
        ),

        // Conditionally provide create or update controller
        if (isEditMode)
          ChangeNotifierProxyProvider<CrudItinerary, UpdateItineraryController>(
            create: (context) => UpdateItineraryController(
              crudItinerary: context.read<CrudItinerary>(),
            ),
            update: (_, crud, controller) => controller!,
          )
        else
          ChangeNotifierProvider(create: (_) => CreateItineraryController()),
      ],
      child: _ItineraryBuildView(
        travelId: travelId,
        buildModel: itineraryBuildModel,
        isEditMode: isEditMode,
      ),
    );
  }
}

/// Internal stateful view that holds the itinerary editing logic.
///
/// Consumes [ItineraryEditorController] for step state and either
/// [CreateItineraryController] or [UpdateItineraryController] for persistence.
class _ItineraryBuildView extends StatelessWidget {
  const _ItineraryBuildView({
    required this.travelId,
    required this.buildModel,
    required this.isEditMode,
  });

  final String travelId;
  final ItineraryBuildModel buildModel;
  final bool isEditMode;

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<ItineraryEditorController>();
    final steps = editor.stepsBuildModel;
    final selectedIndex = editor.selectedStepIndex;


    return Scaffold(
      /// TODO: CREATE AN APP BAR ON A SEPARATED FILE
    appBar: AppBar(
        title: Text(
          '${isEditMode ? 'Edit' : 'Create'} Itinerary'
          ' — ${buildModel.travelName}',
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          /// Save button
          TextButton.icon(
            onPressed: editor.isSubmitting ? null : () => _saveItinerary(),
            icon: Icon(Icons.save, color: theme.colorScheme.onPrimary),
            label: Text(
              'Save',
              style: TextStyle(color: theme.colorScheme.onPrimary),
            ),
          ),
          const SizedBox(width: 8),

          /// Finish itinerary button
          ElevatedButton(
            onPressed: editor.isSubmitting
                ? null
                : () => _saveItinerary(finish: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
            ),
            child: const Text('Finish Itinerary'),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Left: Interest Points ──────────────────────────────
          InterestPointsPanel(
            interestPoints: editor.interestPointPanelModels,
            onToggle: editor.toggleInterestPoint,
          ),
          VerticalDivider(width: 1, color: Theme.of(context).dividerColor),

          // ─── Center: Step workflow ──────────────────────────────
          StepsBuilderPanel(),
          VerticalDivider(width: 1, color: Theme.of(context).dividerColor),

          // ─── Right: Steps list ──────────────────────────────────
          StepsListPanel(
            steps: steps,
            selectedIndex: selectedIndex,
            onAddStep: _addStep,
          ),
        ],
      ),
    );
  }
}
