import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/interest_points_panel.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/step_type_selector.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/stop_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/hosting_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/travel_segment_form_widget.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/steps_list_panel.dart';

/// Itinerary Creation Page with three-column layout:
/// Left: interest points from route (with checklist)
/// Center: stepper workflow for the selected step
/// Right: list of itinerary steps
class ItineraryCreationPage extends StatefulWidget {
  final Travel travel;

  const ItineraryCreationPage({super.key, required this.travel});

  @override
  State<ItineraryCreationPage> createState() =>
      _ItineraryCreationPageState();
}

class _ItineraryCreationPageState extends State<ItineraryCreationPage> {
  final List<ItineraryStep> _steps = [];
  int _selectedStepIndex = -1;
  bool _isSubmitting = false;
  final Set<String> _checkedInterestPointIds = {};

  @override
  void initState() {
    super.initState();
    // Pre-populate if editing an existing itinerary
    if (widget.travel.hasItinerary) {
      _steps.addAll(widget.travel.itinerary!.itinerarySteps);
      if (_steps.isNotEmpty) {
        _selectedStepIndex = 0;
      }
    }
  }

  // ─── Step management ─────────────────────────────────────────────────

  void _addStep() {
    setState(() {
      _steps.add(PlaceholderStep.empty());
      _selectedStepIndex = _steps.length - 1;
    });
  }

  void _selectStep(int index) {
    setState(() => _selectedStepIndex = index);
  }

  void _goToPreviousStep() {
    if (_selectedStepIndex > 0) {
      setState(() => _selectedStepIndex--);
    }
  }

  void _goToNextStep() {
    if (_selectedStepIndex < _steps.length - 1) {
      setState(() => _selectedStepIndex++);
    }
  }

  void _deleteStep(int index) {
    _showDeleteConfirmation(() {
      setState(() {
        _steps.removeAt(index);
        if (_steps.isEmpty) {
          _selectedStepIndex = -1;
        } else if (_selectedStepIndex >= _steps.length) {
          _selectedStepIndex = _steps.length - 1;
        } else if (_selectedStepIndex == index && index > 0) {
          _selectedStepIndex = index - 1;
        } else if (_selectedStepIndex > index) {
          _selectedStepIndex--;
        }
      });
    });
  }

  void _reorderSteps(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) newIndex -= 1;
      final item = _steps.removeAt(oldIndex);
      _steps.insert(newIndex, item);

      // Keep selection following the moved item
      if (_selectedStepIndex == oldIndex) {
        _selectedStepIndex = newIndex;
      } else if (_selectedStepIndex > oldIndex &&
          _selectedStepIndex <= newIndex) {
        _selectedStepIndex--;
      } else if (_selectedStepIndex < oldIndex &&
          _selectedStepIndex >= newIndex) {
        _selectedStepIndex++;
      }
    });
  }

  void _onStepTypeSelected(StepType type) {
    if (_selectedStepIndex < 0) return;
    final current = _steps[_selectedStepIndex];
    final now = DateTime.now();

    setState(() {
      switch (type) {
        case StepType.stop:
          _steps[_selectedStepIndex] = Stop(
            id: current.id,
            title: current.title,
            startDate: current.startDate,
            finishDate: current.finishDate,
            name: '',
            description: '',
            experiences: [],
          );
        case StepType.hosting:
          _steps[_selectedStepIndex] = Hosting(
            id: current.id,
            title: current.title,
            startDate: current.startDate,
            finishDate: current.finishDate,
            name: '',
            address: '',
            checkIn: now,
            checkOut: now,
          );
        case StepType.travelSegment:
          _steps[_selectedStepIndex] = TravelSegment(
            id: current.id,
            title: current.title,
            startDate: current.startDate,
            finishDate: current.finishDate,
            travelSegmentId: 'seg_${now.millisecondsSinceEpoch}',
            transport: Airplane(
              id: 'transport_${now.millisecondsSinceEpoch}',
              flightNumber: '',
              flightCompany: '',
              flightDate: now,
              departureGate: '',
              departureAirport: '',
              arrivalAirport: '',
            ),
            startPoint: '',
            finishPoint: '',
          );
      }
    });
  }

  void _onPlaceholderTitleChanged(String title) {
    if (_selectedStepIndex < 0) return;
    final current = _steps[_selectedStepIndex];
    if (current is PlaceholderStep) {
      setState(() {
        _steps[_selectedStepIndex] = PlaceholderStep(
          id: current.id,
          title: title,
          startDate: current.startDate,
          finishDate: current.finishDate,
        );
      });
    }
  }

  void _onStepChanged(ItineraryStep updated) {
    if (_selectedStepIndex < 0) return;
    setState(() {
      _steps[_selectedStepIndex] = updated;
    });
  }

  void _toggleInterestPoint(String id) {
    setState(() {
      if (_checkedInterestPointIds.contains(id)) {
        _checkedInterestPointIds.remove(id);
      } else {
        _checkedInterestPointIds.add(id);
      }
    });
  }

  // ─── Delete confirmation ─────────────────────────────────────────────

  void _showDeleteConfirmation(VoidCallback onConfirm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Step'),
        content:
            const Text('Are you sure you want to delete this step?'),
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

  // ─── Save ────────────────────────────────────────────────────────────

  Future<void> _saveItinerary({bool finish = false}) async {
    // Filter out placeholder steps before saving
    final validSteps =
        _steps.where((s) => s is! PlaceholderStep).toList();

    if (validSteps.isEmpty) return;

    setState(() => _isSubmitting = true);

    final controller = context.read<TravelsController>();
    final itineraryData = {
      'id': widget.travel.itinerary?.id ??
          'itinerary_${DateTime.now().millisecondsSinceEpoch}',
      'responsibleAgentName': 'Agent Smith',
      'itinerarySteps':
          validSteps.map((s) => s.toMap()).toList(),
    };

    bool success;
    if (widget.travel.hasItinerary) {
      success = await controller.updateItinerary(
          widget.travel.id, itineraryData);
    } else {
      success = await controller.createItinerary(
          widget.travel.id, itineraryData);
    }

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(finish
                ? 'Itinerary finished successfully!'
                : 'Itinerary saved.'),
          ),
        );
        Navigator.of(context).pop();
      }
    }
  }

  // ─── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final route = widget.travel.routePlan;

    return Scaffold(
      appBar: AppBar(
        title: Text('Itinerary — ${widget.travel.travelName}'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          TextButton.icon(
            onPressed: _isSubmitting ? null : () => _saveItinerary(),
            icon: Icon(Icons.save,
                color: theme.colorScheme.onPrimary),
            label: Text('Save',
                style: TextStyle(
                    color: theme.colorScheme.onPrimary)),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: _isSubmitting
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
          // ─── Left: Interest Points ──────────────────────
          InterestPointsPanel(
            interestPoints: route.interestsList,
            checkedIds: _checkedInterestPointIds,
            onToggle: _toggleInterestPoint,
          ),
          VerticalDivider(
              width: 1, color: theme.dividerColor),
          // ─── Center: Step Workflow ───────────────────────
          Expanded(
            child: _buildCenterPanel(theme),
          ),
          VerticalDivider(
              width: 1, color: theme.dividerColor),
          // ─── Right: Steps List ──────────────────────────
          StepsListPanel(
            steps: _steps,
            selectedIndex: _selectedStepIndex,
            onSelect: _selectStep,
            onReorder: _reorderSteps,
            onDelete: _deleteStep,
            onAddStep: _addStep,
          ),
        ],
      ),
    );
  }

  Widget _buildCenterPanel(ThemeData theme) {
    if (_steps.isEmpty || _selectedStepIndex < 0) {
      return _buildEmptyState(theme);
    }

    final step = _steps[_selectedStepIndex];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Navigation bar ─────────────────────────────────
          _buildStepperNavigation(theme, step),
          const SizedBox(height: 24),
          // ─── Step form ──────────────────────────────────────
          _buildStepForm(step),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle_outline,
              size: 64,
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'Add your first step to begin building the itinerary.',
            style: TextStyle(
              fontSize: 16,
              color: theme.colorScheme.onSurface
                  .withValues(alpha: 0.6),
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

  Widget _buildStepperNavigation(ThemeData theme, ItineraryStep step) {
    final isFirst = _selectedStepIndex == 0;
    final isLast = _selectedStepIndex == _steps.length - 1;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          onPressed: isFirst ? null : _goToPreviousStep,
          icon: const Icon(Icons.arrow_back),
          tooltip: 'Previous Step',
        ),
        Text(
          'Step - ${step.title}',
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
                onPressed: _goToNextStep,
                icon: const Icon(Icons.arrow_forward),
                tooltip: 'Next Step',
              ),
      ],
    );
  }

  Widget _buildStepForm(ItineraryStep step) {
    if (step is PlaceholderStep) {
      return StepTypeSelector(
        title: step.title,
        onTitleChanged: _onPlaceholderTitleChanged,
        onTypeSelected: _onStepTypeSelected,
        onDelete: () => _deleteStep(_selectedStepIndex),
      );
    }

    if (step is Stop) {
      return StopFormWidget(
        key: ValueKey(step.id),
        stop: step,
        onChanged: (updated) => _onStepChanged(updated),
        onDelete: () => _deleteStep(_selectedStepIndex),
      );
    }

    if (step is Hosting) {
      return HostingFormWidget(
        key: ValueKey(step.id),
        hosting: step,
        onChanged: (updated) => _onStepChanged(updated),
        onDelete: () => _deleteStep(_selectedStepIndex),
      );
    }

    if (step is TravelSegment) {
      return TravelSegmentFormWidget(
        key: ValueKey(step.id),
        segment: step,
        onChanged: (updated) => _onStepChanged(updated),
        onDelete: () => _deleteStep(_selectedStepIndex),
      );
    }

    return const SizedBox.shrink();
  }
}
