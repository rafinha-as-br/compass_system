import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';
import 'package:travel_matrix/features/travels/data/dtos/itinerary_step_dto.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/build/itinerary_build_controller.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/editor/itinerary_editor_controller.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/update/itinerary_update_controller.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/interest_points_panel.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/steps_builder_panel.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/steps_list_panel.dart';

import '../../../data/repository_impl/itinerary_repository_impl.dart';
import '../../../domain/repository/itinerary_repository.dart';
import '../../../domain/usecases/crud_itinerary.dart';
import '../../models/build_models/itinerary_build_model.dart';

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
/// NOTE: The widgets above are presentational widgets, consuming data passed by [ItineraryEditorController].
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
            steps: isEditMode
                ? [
                    itineraryBuildModel.steps!.startStep,
                    ...itineraryBuildModel.steps!.normalSteps,
                    itineraryBuildModel.steps!.finishStep,
                  ]
                : null,
            interestPoints: itineraryBuildModel.interestsPoints,
          ),
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

  Future<String> _resolveAgentName() async {
    final token = await AuthStorageService.instance.getToken();
    if (token == null) return '';

    final response = await CompassService.instance.getUser(token);
    if (response['status'] != 'success') return '';

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data['name']?.toString() ?? data['email']?.toString() ?? '';
    }

    return '';
  }

  Future<void> _saveItinerary(BuildContext context) async {
    final editor = context.read<ItineraryEditorController>();
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final updateController = isEditMode
        ? context.read<UpdateItineraryController>()
        : null;
    final createController = isEditMode
        ? null
        : context.read<CreateItineraryController>();
    final agentName = await _resolveAgentName();

    final itineraryData = {
      'agentName': agentName,
      'steps': editor.stepsList
          .map(
            (step) =>
                ItineraryStepDTO.fromDomain(step: step.toDomain()).toJson(),
          )
          .toList(),
    };

    final bool success;
    String? error;

    if (isEditMode) {
      success = await updateController!.updateItinerary(
        travelId,
        itineraryData,
      );
      error = updateController.error;
    } else {
      success = await createController!.createItinerary(
        travelId,
        itineraryData,
      );
      error = createController.error;
    }

    if (!context.mounted) return;

    if (success) {
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            isEditMode ? 'Itinerary updated.' : 'Itinerary created.',
          ),
        ),
      );
      router.go('${AppRoutes.travels}/$travelId');
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text(error ?? 'Could not save itinerary.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<ItineraryEditorController>();
    final steps = editor.stepsBuildModel;
    final selectedIndex = editor.selectedStepIndex;
    final isSaving = isEditMode
        ? context.watch<UpdateItineraryController>().isLoading
        : context.watch<CreateItineraryController>().isLoading;

    return Scaffold(
      /// TODO: CREATE AN APP BAR ON A SEPARATED FILE
      appBar: AppBar(
        title: const Text('Build Itinerary'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('${AppRoutes.travels}/$travelId');
            }
          },
        ),
        actions: [
          TextButton.icon(
            onPressed: isSaving ? null : () => _saveItinerary(context),
            icon: isSaving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.check),
            label: Text(isEditMode ? 'Update' : 'Save'),
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
          Expanded(
            child: StepsBuilderPanel(
              steps: steps,
              selectedIndex: selectedIndex,
              goToPreviousStep: editor.goToPreviousStep,
              goToNextStep: editor.goToNextStep,
              addStep: editor.addStep,
              updateStep: editor.updateStep,
              removeStep: editor.deleteStep,
            ),
          ),
          VerticalDivider(width: 1, color: Theme.of(context).dividerColor),

          // ─── Right: Steps list ──────────────────────────────────
          StepsListPanel(
            steps: steps,
            selectedIndex: selectedIndex,
            onSelectStep: editor.selectStep,
            addStep: editor.addStep,
            onReorder: (oldIndex, newIndex) {
              final success = editor.reorderSteps(oldIndex, newIndex);
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cannot move this step to that position.'),
                  ),
                );
              }
            },
            onDeleteStep: (index) {
              final success = editor.deleteStep(index);
              if (!success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Cannot delete this step.')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
