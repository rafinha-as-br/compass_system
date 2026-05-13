import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:travel_matrix/features/travels/presentation/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/build/itinerary_build_controller.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/editor/itinerary_editor_controller.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/update/itinerary_update_controller.dart';
import 'package:travel_matrix/features/travels/presentation/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/features/travels/presentation/view_models/transports_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/interest_points_panel.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/steps_list_panel.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/step_type_selector.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/stop_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/hosting_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/travel_segment_form_widget.dart';

import '../../../data/repository_impl/itinerary_repository_impl.dart';
import '../../../domain/repository/itinerary_repository.dart';
import '../../../domain/usecases/crud_itinerary.dart';
import '../../models/build_models/itinerary_build_model.dart';

/// Page responsible for creating and editing an [Itinerary] for a travel.
///
/// Determines its mode from [ItineraryBuildModel]:
/// - [steps] == null → **create mode**: starts with an empty step list.
/// - [steps] != null → **edit mode**: loads existing steps for editing.
///
/// Layout: three-column fixed structure:
/// - Left  → [InterestPointsPanel] (route interest points checklist)
/// - Center → step workflow form (type selector / concrete form)
/// - Right  → [StepsListPanel] (ordered, reorderable list)
///
/// NOTE: Start and Finish steps are always pinned to index 0 and last index.
class ItineraryBuildPage extends StatefulWidget {
  const ItineraryBuildPage({
    super.key,
    required this.itineraryBuildModel,
    required this.travelId,
  });

  final ItineraryBuildModel itineraryBuildModel;
  final String travelId;

  @override
  State<ItineraryBuildPage> createState() => _ItineraryBuildPageState();
}

class _ItineraryBuildPageState extends State<ItineraryBuildPage> {
  /// True when editing an existing itinerary (steps != null).
  bool get isEditMode => widget.itineraryBuildModel.steps != null;

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

        // Editor controller — owns the mutable step list and selection state
        ChangeNotifierProvider(create: (_) => ItineraryEditorController()),

        // Conditionally provide create or update controller
        if (isEditMode)
          ChangeNotifierProxyProvider<CrudItinerary, UpdateItineraryController>(
            create: (_) => UpdateItineraryController(
              crudItinerary: CrudItinerary(ItineraryRepositoryImpl()),
            ),
            update: (_, crud, controller) => controller!,
          )
        else
          ChangeNotifierProvider(create: (_) => CreateItineraryController()),
      ],
      child: _ItineraryBuildView(
        travelId: widget.travelId,
        buildModel: widget.itineraryBuildModel,
        isEditMode: isEditMode,
      ),
    );
  }
}

/// Internal stateful view that holds the itinerary editing logic.
///
/// Consumes [ItineraryEditorController] for step state and either
/// [CreateItineraryController] or [UpdateItineraryController] for persistence.
class _ItineraryBuildView extends StatefulWidget {
  const _ItineraryBuildView({
    required this.travelId,
    required this.buildModel,
    required this.isEditMode,
  });

  final String travelId;
  final ItineraryBuildModel buildModel;
  final bool isEditMode;

  @override
  State<_ItineraryBuildView> createState() => _ItineraryBuildViewState();
}

class _ItineraryBuildViewState extends State<_ItineraryBuildView> {
  @override
  void initState() {
    super.initState();
    // In edit mode, populate the editor with existing steps
    if (widget.isEditMode) {
      final allSteps = <ItineraryStepViewModel>[];
      final s = widget.buildModel.steps!;
      if (s.startStep != null) allSteps.add(s.startStep!);
      allSteps.addAll(s.normalSteps.whereType<ItineraryStepViewModel>());
      if (s.finishStep != null) allSteps.add(s.finishStep!);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<ItineraryEditorController>().initializeSteps(allSteps);
      });
    }
  }

  // ─── Actions delegated to ItineraryEditorController ─────────────────

  void _addStep() {
    final now = DateTime.now();
    context.read<ItineraryEditorController>().addStep(
          PlaceHolderStepViewModel(
            id: 'step_${now.millisecondsSinceEpoch}',
            title: '',
            startDate: now,
            finishDate: now,
          ),
        );
  }

  void _onStepTypeSelected(StepType type) {
    final editor = context.read<ItineraryEditorController>();
    final idx = editor.selectedStepIndex;
    if (idx < 0) return;
    final current = editor.steps[idx];
    final now = DateTime.now();

    ItineraryStepViewModel updated;
    switch (type) {
      case StepType.stop:
        updated = StopStepViewModel(
          id: current.id,
          title: current.title,
          startDate: current.startDate,
          finishDate: current.finishDate,
          name: '',
          description: '',
          experiences: [],
        );
      case StepType.hosting:
        updated = HostingStepViewModel(
          id: current.id,
          title: current.title,
          startDate: current.startDate,
          finishDate: current.finishDate,
          placeName: '',
          address: '',
          checkIn: now,
          checkOut: now,
        );
      case StepType.travelSegment:
        updated = TravelSegmentStepViewModel(
          id: current.id,
          title: current.title,
          startDate: current.startDate,
          finishDate: current.finishDate,
          startPoint: '',
          finishPoint: '',
          transport: AirplaneViewModel(
            id: 'transport_${now.millisecondsSinceEpoch}',
            flightNumber: '',
            flightCompany: '',
            flightDate: now,
            departureGate: '',
            departureAirport: '',
            arrivalAirport: '',
          ),
        );
    }
    editor.updateStep(idx, updated);
  }

  void _onPlaceholderTitleChanged(String title) {
    final editor = context.read<ItineraryEditorController>();
    final idx = editor.selectedStepIndex;
    if (idx < 0) return;
    final current = editor.steps[idx];
    if (current is PlaceHolderStepViewModel) {
      editor.updateStep(
        idx,
        PlaceHolderStepViewModel(
          id: current.id,
          title: title,
          startDate: current.startDate,
          finishDate: current.finishDate,
        ),
      );
    }
  }

  void _onStepChanged(ItineraryStepViewModel updated) {
    final editor = context.read<ItineraryEditorController>();
    editor.updateStep(editor.selectedStepIndex, updated);
  }

  void _showDeleteConfirmation(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Step'),
        content: const Text('Are you sure you want to delete this step?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              onConfirm();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  // ─── Save/Submit ─────────────────────────────────────────────────────

  Future<void> _saveItinerary({bool finish = false}) async {
    final editor = context.read<ItineraryEditorController>();
    editor.setSubmitting(true);

    final validSteps = editor.steps
        .where((s) => s is! PlaceHolderStepViewModel)
        .toList();

    if (validSteps.isEmpty) {
      editor.setSubmitting(false);
      return;
    }

    final itineraryData = {
      'id': 'itinerary_${DateTime.now().millisecondsSinceEpoch}',
      'responsibleAgentName': 'Agent',
      'itinerarySteps': validSteps
          .map((s) => ItineraryStepMapper.toDomain(s).toJson())
          .toList(),
    };

    bool success = false;

    if (widget.isEditMode) {
      final controller = context.read<UpdateItineraryController>();
      success = await controller.updateItinerary(widget.travelId, itineraryData);
    } else {
      final controller = context.read<CreateItineraryController>();
      success = await controller.createItinerary(widget.travelId, itineraryData);
    }

    editor.setSubmitting(false);

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            finish ? 'Itinerary finished successfully!' : 'Itinerary saved.',
          ),
        ),
      );
      Navigator.of(context).pop();
    } else {
      final errorMsg = widget.isEditMode
          ? (context.read<UpdateItineraryController>()).error
          : (context.read<CreateItineraryController>()).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg ?? 'Failed to save itinerary.')),
      );
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final editor = context.watch<ItineraryEditorController>();
    final theme = Theme.of(context);
    final steps = editor.steps;
    final selectedIndex = editor.selectedStepIndex;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.isEditMode ? 'Edit' : 'Create'} Itinerary'
          ' — ${widget.buildModel.travelName}',
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
            interestPoints: widget.buildModel.interestsPoints
                .map((vm) => InterestPoint(
                      id: vm.id,
                      name: vm.name,
                      description: vm.description,
                    ))
                .toList(),
            checkedIds: editor.checkedInterestPointIds,
            onToggle: editor.toggleInterestPoint,
          ),
          VerticalDivider(width: 1, color: theme.dividerColor),

          // ─── Center: Step workflow ──────────────────────────────
          Expanded(
            child: _buildCenterPanel(
              theme,
              steps,
              selectedIndex,
              editor,
            ),
          ),
          VerticalDivider(width: 1, color: theme.dividerColor),

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

  Widget _buildCenterPanel(
    ThemeData theme,
    List<ItineraryStepViewModel> steps,
    int selectedIndex,
    ItineraryEditorController editor,
  ) {
    if (steps.isEmpty || selectedIndex < 0) {
      return _buildEmptyState(theme);
    }

    final step = steps[selectedIndex];
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepNavigation(theme, step, selectedIndex, steps.length, editor),
          const SizedBox(height: 24),
          _buildStepForm(step, editor, selectedIndex),
        ],
      ),
    );
  }

  /// Empty state shown when no steps have been added yet.
  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline,
            size: 64,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'Add your first step to begin building the itinerary.',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _addStep,
            icon: const Icon(Icons.add),
            label: const Text('Add Step'),
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.secondary,
              foregroundColor: theme.colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Navigation bar at the top of the center panel showing prev/next/add controls.
  Widget _buildStepNavigation(
    ThemeData theme,
    ItineraryStepViewModel step,
    int selectedIndex,
    int totalSteps,
    ItineraryEditorController editor,
  ) {
    final isFirst = selectedIndex == 0;
    final isLast = selectedIndex == totalSteps - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: isFirst ? null : editor.goToPreviousStep,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Previous Step',
        ),
        Text(
          'Step — ${step.title.isNotEmpty ? step.title : '#${selectedIndex + 1}'}',
          style: theme.textTheme.titleSmall
              ?.copyWith(fontWeight: FontWeight.w600),
        ),
        isLast
            ? IconButton(
                onPressed: _addStep,
                icon: const Icon(Icons.add),
                tooltip: 'Add Step',
                color: theme.colorScheme.secondary,
              )
            : IconButton(
                onPressed: editor.goToNextStep,
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'Next Step',
              ),
      ],
    );
  }

  /// Renders the correct form widget based on the current step's type.
  Widget _buildStepForm(
    ItineraryStepViewModel step,
    ItineraryEditorController editor,
    int index,
  ) {
    void onDelete() => _showDeleteConfirmation(() => editor.deleteStep(index));

    if (step is PlaceHolderStepViewModel) {
      return StepTypeSelector(
        title: step.title,
        onTitleChanged: _onPlaceholderTitleChanged,
        onTypeSelected: _onStepTypeSelected,
        onDelete: onDelete,
      );
    }

    if (step is StopStepViewModel) {
      // Map ViewModel → domain entity for the form widget
      final domainStop = ItineraryStepMapper.toDomain(step) as Stop;
      return StopFormWidget(
        key: ValueKey(step.id),
        stop: domainStop,
        onChanged: (updated) {
          // Map domain entity → ViewModel on callback
          _onStepChanged(StopStepViewModel(
            id: updated.id,
            title: updated.title,
            startDate: updated.startDate,
            finishDate: updated.finishDate,
            name: updated.name,
            description: updated.description,
            experiences: updated.experiences,
          ));
        },
        onDelete: onDelete,
      );
    }

    if (step is HostingStepViewModel) {
      final domainHosting = ItineraryStepMapper.toDomain(step) as Hosting;
      return HostingFormWidget(
        key: ValueKey(step.id),
        hosting: domainHosting,
        onChanged: (updated) {
          _onStepChanged(HostingStepViewModel(
            id: updated.id,
            title: updated.title,
            startDate: updated.startDate,
            finishDate: updated.finishDate,
            placeName: updated.name,
            address: updated.address,
            checkIn: updated.checkIn,
            checkOut: updated.checkOut,
          ));
        },
        onDelete: onDelete,
      );
    }

    if (step is TravelSegmentStepViewModel) {
      final domainSegment = ItineraryStepMapper.toDomain(step) as TravelSegment;
      return TravelSegmentFormWidget(
        key: ValueKey(step.id),
        segment: domainSegment,
        onChanged: (updated) {
          // The form widget uses mock_repository types internally;
          // map its Transport back to a TransportViewModel manually.
          final t = updated.transport;
          TransportViewModel transportVm;
          if (t is Airplane) {
            transportVm = AirplaneViewModel(
              id: t.id,
              flightNumber: t.flightNumber,
              flightCompany: t.flightCompany,
              flightDate: t.flightDate,
              departureGate: t.departureGate,
              departureAirport: t.departureAirport,
              arrivalAirport: t.arrivalAirport,
            );
          } else if (t is Bus) {
            transportVm = BusViewModel(
              id: t.id,
              travelNumber: t.travelNumber,
              travelCompany: t.travelCompany,
              departureGate: t.departureGate,
              departureDateTime: t.departureDateTime,
              busStationName: t.busStationName,
              description: t.description,
              details: t.details,
            );
          } else if (t is RentalCar) {
            transportVm = RentalCarViewModel(
              id: t.id,
              vehicleModelName: t.vehicleModelName,
              vehicleLicensePlate: t.vehicleLicensePlate,
              companyName: t.companyName,
              checkInDate: t.checkInDate,
              checkOutDate: t.checkOutDate,
            );
          } else {
            throw Exception('Unknown transport type: ${t.runtimeType}');
          }
          _onStepChanged(TravelSegmentStepViewModel(
            id: updated.id,
            title: updated.title,
            startDate: updated.startDate,
            finishDate: updated.finishDate,
            startPoint: updated.startPoint,
            finishPoint: updated.finishPoint,
            transport: transportVm,
          ));
        },
        onDelete: onDelete,
      );
    }

    return const SizedBox.shrink();
  }
}
