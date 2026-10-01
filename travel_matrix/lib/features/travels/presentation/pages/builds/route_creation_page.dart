import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';

import 'package:travel_matrix/core/constants/api_fields.dart';
import 'package:travel_matrix/core/services/places_suggestions_service.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/route_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/models/place_suggestion.dart';
import 'package:travel_matrix/shared/widgets/back_icon_button.dart';
import 'package:travel_matrix/shared/widgets/form_error_message.dart';
import 'package:travel_matrix/shared/widgets/places_autocomplete_field.dart';

/// Page for editing the [RoutePlan] of an existing travel.
///
/// Opened from [TravelViewPage] when the agent wants to update the route
/// details (locations, dates, interest points) without creating a new travel.
///
/// On submit, calls [TravelsController.updateRoute] and pops on success.
///
/// Layout: Form with inputs for locations, dates, and dynamic interest points.
class RouteCreationPage extends StatefulWidget {
  const RouteCreationPage({
    super.key,
    required this.travel,
    this.fetchSuggestions = fetchPlaceSuggestions,
  });

  /// The existing travel whose route is being edited.
  final TravelViewModel travel;

  /// Overridable in tests — defaults to the real network-backed lookup.
  final Future<List<PlaceSuggestion>> Function(String query) fetchSuggestions;

  @override
  State<RouteCreationPage> createState() => _RouteCreationPageState();
}

class _RouteCreationPageState extends State<RouteCreationPage> {
  final _formKey = GlobalKey<FormState>();
  late String _startLocation;
  late PlaceCoordinate? _startLocationCoordinate;
  late String _destination;
  late PlaceCoordinate? _destinationCoordinate;
  late DateTime _startDate;
  late DateTime _endDate;
  late List<InterestPointViewModel> _interestPoints;
  // See PlacesAutocompleteField isn't a FormField: same manual-touch pattern
  // as TravelCreationPage.
  bool _locationsTouched = false;

  String _poiName = '';
  PlaceCoordinate? _poiCoordinate;
  final _poiDescCtrl = TextEditingController();
  int _poiFieldResetKey = 0;

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final route = widget.travel.route;
    _startLocation = route.start;
    _startLocationCoordinate = route.startCoordinate;
    _destination = route.destination;
    _destinationCoordinate = route.destinationCoordinate;
    _startDate = route.startDate;
    _endDate = route.endDate;
    _interestPoints = List.from(route.interests);
  }

  @override
  void dispose() {
    _poiDescCtrl.dispose();
    super.dispose();
  }

  void _addInterestPoint() {
    if (_poiName.isEmpty) return;
    setState(() {
      _interestPoints.add(InterestPointViewModel(
        localId: 'poi_${DateTime.now().millisecondsSinceEpoch}',
        backEndId: null,
        name: _poiName,
        description: _poiDescCtrl.text,
        coordinate: _poiCoordinate,
      ));
      _poiName = '';
      _poiCoordinate = null;
      _poiFieldResetKey++;
      _poiDescCtrl.clear();
    });
  }

  Future<void> _submit() async {
    setState(() => _locationsTouched = true);
    final locationsValid = _startLocation.trim().isNotEmpty && _destination.trim().isNotEmpty;
    if (!_formKey.currentState!.validate() || !locationsValid) return;

    setState(() => _isSubmitting = true);

    final controller = context.read<TravelsController>();

    final success = await controller.updateRoute(widget.travel.localId, {
      'startDate': _startDate.toIso8601String(),
      'endDate': _endDate.toIso8601String(),
      'startLocation': _startLocation,
      'destination': _destination,
      RoutePlanApiFields.startLocationCoordinate: _startLocationCoordinate?.toJson(),
      RoutePlanApiFields.destinationCoordinate: _destinationCoordinate?.toJson(),
      // Map back to API format (or domain format if the controller handles it)
      'interestsList': _interestPoints.map((p) {
        return {
          'id': p.backEndId ?? p.localId,
          'name': p.name,
          'description': p.description,
          InterestPointApiFields.coordinate: p.coordinate?.toJson(),
        };
      }).toList(),
    });

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        context.go(
          '${AppRoutes.travels}/${widget.travel.localId}',
          extra: {'refresh': true},
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editRouteTitle),
        leading: BackIconButton(
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('${AppRoutes.travels}/${widget.travel.localId}');
            }
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.routeDetails,
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // ─── Locations ──────────────────────────────────────
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PlacesAutocompleteField(
                              labelText: l10n.startLocationLabel,
                              fetchSuggestions: widget.fetchSuggestions,
                              initialText: _startLocation,
                              initialCoordinate: _startLocationCoordinate,
                              onChanged: (result) => setState(() {
                                _startLocation = result.text;
                                _startLocationCoordinate = result.coordinate;
                              }),
                            ),
                            if (_locationsTouched && _startLocation.trim().isEmpty)
                              FormErrorMessage(message: l10n.requiredField),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            PlacesAutocompleteField(
                              labelText: l10n.destinationLabel,
                              fetchSuggestions: widget.fetchSuggestions,
                              initialText: _destination,
                              initialCoordinate: _destinationCoordinate,
                              onChanged: (result) => setState(() {
                                _destination = result.text;
                                _destinationCoordinate = result.coordinate;
                              }),
                            ),
                            if (_locationsTouched && _destination.trim().isEmpty)
                              FormErrorMessage(message: l10n.requiredField),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // ─── Dates ──────────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.startDateLabel),
                          subtitle: Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            tooltip: l10n.selectDateTooltip,
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _startDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _startDate = picked);
                              }
                            },
                          ),
                        ),
                      ),
                      Expanded(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(l10n.endDateLabel),
                          subtitle: Text(
                            '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_today),
                            tooltip: l10n.selectDateTooltip,
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _endDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2030),
                              );
                              if (picked != null) {
                                setState(() => _endDate = picked);
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Divider(),
                  const SizedBox(height: 16),

                  // ─── Interest Points ─────────────────────────────────
                  Text(
                    l10n.interestPointsTitle,
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: PlacesAutocompleteField(
                          key: ValueKey(_poiFieldResetKey),
                          labelText: l10n.pointNameLabel,
                          fetchSuggestions: widget.fetchSuggestions,
                          onChanged: (result) => setState(() {
                            _poiName = result.text;
                            _poiCoordinate = result.coordinate;
                          }),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _poiDescCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.descriptionLabel,
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addInterestPoint,
                        icon: const Icon(Icons.add_circle),
                        color: theme.colorScheme.secondary,
                        tooltip: l10n.addInterestPointTooltip,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ..._interestPoints.map(
                    (p) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.place),
                        title: Text(p.name),
                        subtitle: Text(p.description),
                        trailing: IconButton(
                          icon: const Icon(Icons.close, size: 18),
                          tooltip: l10n.removeInterestPointTooltip,
                          onPressed: () =>
                              setState(() => _interestPoints.remove(p)),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // ─── Submit ──────────────────────────────────────────
                  SizedBox(
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.secondary,
                        foregroundColor: theme.colorScheme.onSecondary,
                      ),
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(l10n.updateRouteButton),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

