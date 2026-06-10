import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';

import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/route_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';

/// Page for editing the [RoutePlan] of an existing travel.
///
/// Opened from [TravelViewPage] when the agent wants to update the route
/// details (locations, dates, interest points) without creating a new travel.
///
/// On submit, calls [TravelsController.updateRoute] and pops on success.
///
/// Layout: Form with inputs for locations, dates, and dynamic interest points.
class RouteCreationPage extends StatefulWidget {
  const RouteCreationPage({super.key, required this.travel});

  /// The existing travel whose route is being edited.
  final TravelViewModel travel;

  @override
  State<RouteCreationPage> createState() => _RouteCreationPageState();
}

class _RouteCreationPageState extends State<RouteCreationPage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _startLocationCtrl;
  late final TextEditingController _destinationCtrl;
  late DateTime _startDate;
  late DateTime _endDate;
  late List<InterestPointViewModel> _interestPoints;

  final _poiNameCtrl = TextEditingController();
  final _poiDescCtrl = TextEditingController();

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final route = widget.travel.route;
    _startLocationCtrl = TextEditingController(text: route.start);
    _destinationCtrl = TextEditingController(text: route.destination);
    _startDate = route.startDate;
    _endDate = route.endDate;
    _interestPoints = List.from(route.interests);
  }

  @override
  void dispose() {
    _startLocationCtrl.dispose();
    _destinationCtrl.dispose();
    _poiNameCtrl.dispose();
    _poiDescCtrl.dispose();
    super.dispose();
  }

  void _addInterestPoint() {
    if (_poiNameCtrl.text.isEmpty) return;
    setState(() {
      _interestPoints.add(InterestPointViewModel(
        localId: 'poi_${DateTime.now().millisecondsSinceEpoch}',
        backEndId: null,
        name: _poiNameCtrl.text,
        description: _poiDescCtrl.text,
      ));
      _poiNameCtrl.clear();
      _poiDescCtrl.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    final controller = context.read<TravelsController>();

    final success = await controller.updateRoute(widget.travel.localId, {
      'startDate': _startDate.toIso8601String(),
      'endDate': _endDate.toIso8601String(),
      'startLocation': _startLocationCtrl.text,
      'destination': _destinationCtrl.text,
      // Map back to API format (or domain format if the controller handles it)
      'interestsList': _interestPoints.map((p) => {
        'id': p.backEndId ?? p.localId,
        'name': p.name,
        'description': p.description,
      }).toList(),
    });

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) {
        context.go('${AppRoutes.travels}/${widget.travel.localId}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Route'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
                    'Route Details',
                    style: theme.textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  // ─── Locations ──────────────────────────────────────
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _startLocationCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Start Location',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _destinationCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Destination',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Required' : null,
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
                          title: const Text('Start Date'),
                          subtitle: Text(
                            '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_today),
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
                          title: const Text('End Date'),
                          subtitle: Text(
                            '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.calendar_today),
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
                    'Interest Points',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _poiNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Point Name',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _poiDescCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Description',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _addInterestPoint,
                        icon: const Icon(Icons.add_circle),
                        color: theme.colorScheme.secondary,
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
                          : const Text('UPDATE ROUTE'),
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

