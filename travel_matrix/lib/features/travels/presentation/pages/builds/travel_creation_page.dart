import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/users/data/user_client_data_source.dart';
import 'package:travel_matrix/features/users/data/user_repository_impl.dart';
import 'package:travel_matrix/features/users/domain/user_crud_use_cases.dart';

/// Simple helper class to populate the client dropdown.
class _ClientItem {
  final String id;
  final String name;
  _ClientItem({required this.id, required this.name});
}

/// Simple helper class for interest point data before API submission.
class _InterestPointItem {
  final String id;
  final String name;
  final String description;
  _InterestPointItem({
    required this.id,
    required this.name,
    required this.description,
  });
  Map<String, dynamic> toMap() => {'name': name, 'description': description};
}

/// Page for creating a new [Travel].
///
/// The agent fills in the travel name, client, route details (locations, dates),
/// and optionally adds interest points. On submit, delegates to
/// [TravelsController.createTravel] and pops on success.
///
/// Note: itinerary creation happens separately via [ItineraryBuildPage]
/// after the travel has been created.
class TravelCreationPage extends StatefulWidget {
  const TravelCreationPage({super.key, this.userUseCases});

  /// Overrides the default [UserUseCases]. Exposed for widget tests.
  final UserUseCases? userUseCases;

  @override
  State<TravelCreationPage> createState() => _TravelCreationPageState();
}

class _TravelCreationPageState extends State<TravelCreationPage> {
  late final _userUseCases =
      widget.userUseCases ?? UserUseCases(UserClientRepositoryImpl(UserClientDataSource()));
  final _formKey = GlobalKey<FormState>();
  final _travelNameCtrl = TextEditingController();
  final _startLocationCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  DateTime _startDate = DateTime.now().add(const Duration(days: 7));
  DateTime _endDate = DateTime.now().add(const Duration(days: 14));
  String _selectedClientId = '';
  bool _isSubmitting = false;
  List<_ClientItem> _clients = [];
  bool _isLoadingClients = true;

  // Interest points
  final List<_InterestPointItem> _interestPoints = [];
  final _poiNameCtrl = TextEditingController();
  final _poiDescCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadClients();
  }

  Future<void> _loadClients() async {
    final result = await _userUseCases.getAllUsers();
    if (result.isSuccess && result.data != null && mounted) {
      setState(() {
        _clients = result.data!
            .map((user) => _ClientItem(id: user.backEndId ?? user.domainId, name: user.name))
            .toList();
        if (_clients.isNotEmpty) {
          _selectedClientId = _clients.first.id;
        }
        _isLoadingClients = false;
      });
    }
  }

  @override
  void dispose() {
    _travelNameCtrl.dispose();
    _startLocationCtrl.dispose();
    _destinationCtrl.dispose();
    _poiNameCtrl.dispose();
    _poiDescCtrl.dispose();
    super.dispose();
  }

  void _addInterestPoint() {
    if (_poiNameCtrl.text.isEmpty) return;
    setState(() {
      _interestPoints.add(
        _InterestPointItem(
          id: 'poi_${DateTime.now().millisecondsSinceEpoch}',
          name: _poiNameCtrl.text,
          description: _poiDescCtrl.text,
        ),
      );
      _poiNameCtrl.clear();
      _poiDescCtrl.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedClientId.isEmpty) return;

    setState(() => _isSubmitting = true);

    final controller = context.read<TravelsController>();
    final agentId = context.read<AuthController>().userId ?? 'agent_1';

    final success = await controller.createTravel({
      'clientId': _selectedClientId,
      'agentId': agentId,
      'travelName': _travelNameCtrl.text,
      'routePlan': {
        'startDate': _startDate.toIso8601String(),
        'finishDate': _endDate.toIso8601String(),
        'startLocation': _startLocationCtrl.text,
        'destination': _destinationCtrl.text,
        'interestPoints': _interestPoints.map((p) => p.toMap()).toList(),
      },
    });

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) context.go(AppRoutes.travels);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Travel'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.travels);
            }
          },
        ),
      ),
      body: _isLoadingClients
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                          'Step 1: Create Route',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Define the route first. An itinerary can be created after.',
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _travelNameCtrl,
                          decoration: const InputDecoration(
                            labelText: 'Travel Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? 'Travel name is required' : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedClientId.isEmpty
                              ? null
                              : _selectedClientId,
                          decoration: const InputDecoration(
                            labelText: 'Client',
                            border: OutlineInputBorder(),
                          ),
                          items: _clients
                              .map(
                                (c) => DropdownMenuItem(
                                  value: c.id,
                                  child: Text(c.name),
                                ),
                              )
                              .toList(),
                          onChanged: (v) =>
                              setState(() => _selectedClientId = v ?? ''),
                        ),
                        const SizedBox(height: 16),
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
                        Text(
                          'Interest Points',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
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
                                onPressed: () {
                                  setState(() => _interestPoints.remove(p));
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
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
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('CREATE TRAVEL'),
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
