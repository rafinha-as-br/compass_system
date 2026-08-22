import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/core/services/compass_service/api_response_status.dart';
import 'package:travel_matrix/core/services/compass_service/compass_service.dart';
import 'package:go_router/go_router.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/widgets/back_icon_button.dart';

import '../../../../../core/services/auth_storage_service.dart';

/// Simple helper class to populate the client dropdown.
class _ClientItem {
  final String id;
  final String name;
  _ClientItem({required this.id, required this.name});
  factory _ClientItem.fromJson(Map<String, dynamic> json) => _ClientItem(
    id: json['id']?.toString() ?? '',
    name: json['name']?.toString() ?? '',
  );
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
  const TravelCreationPage({super.key});

  @override
  State<TravelCreationPage> createState() => _TravelCreationPageState();
}

class _TravelCreationPageState extends State<TravelCreationPage> {
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
    final token = await AuthStorageService.instance.getToken();
    if (token == null) return;
    final response = await CompassService.instance.getAllUsers(token);
    if (response['status'] == kApiSuccessStatus && mounted) {
      setState(() {
        _clients = (response['data'] as List<dynamic>)
            .map((e) => _ClientItem.fromJson(e as Map<String, dynamic>))
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

    // Get agent info
    final token = await AuthStorageService.instance.getToken();
    String agentId = 'agent_1';
    if (token != null) {
      final userResp = await CompassService.instance.getUser(token);
      if (userResp['status'] == 'success') {
        agentId = (userResp['data'] as Map<String, dynamic>)['id'] as String;
      }
    }

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
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.createTravelTitle),
        leading: BackIconButton(
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
                          l10n.stepCreateRoute,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.stepCreateRouteHint,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _travelNameCtrl,
                          decoration: InputDecoration(
                            labelText: l10n.travelNameLabel,
                            border: const OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v!.isEmpty ? l10n.travelNameRequired : null,
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          initialValue: _selectedClientId.isEmpty
                              ? null
                              : _selectedClientId,
                          decoration: InputDecoration(
                            labelText: l10n.clientLabel,
                            border: const OutlineInputBorder(),
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
                                decoration: InputDecoration(
                                  labelText: l10n.startLocationLabel,
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? l10n.requiredField : null,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: TextFormField(
                                controller: _destinationCtrl,
                                decoration: InputDecoration(
                                  labelText: l10n.destinationLabel,
                                  border: const OutlineInputBorder(),
                                ),
                                validator: (v) =>
                                    v!.isEmpty ? l10n.requiredField : null,
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
                        Text(
                          l10n.interestPointsTitle,
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
                                decoration: InputDecoration(
                                  labelText: l10n.pointNameLabel,
                                  border: const OutlineInputBorder(),
                                ),
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
                                : Text(l10n.createTravelButton),
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
