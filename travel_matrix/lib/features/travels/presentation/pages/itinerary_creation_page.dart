import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:travel_matrix/shared/widgets/breadcrumb_bar.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';

/// Itinerary Creation Page with three-column layout:
/// Left: interest points from route
/// Center: step workflow with stop form
/// Right: list of created stops
class ItineraryCreationPage extends StatefulWidget {
  final Travel travel;

  const ItineraryCreationPage({super.key, required this.travel});

  @override
  State<ItineraryCreationPage> createState() =>
      _ItineraryCreationPageState();
}

class _ItineraryCreationPageState extends State<ItineraryCreationPage> {
  final List<ItineraryStop> _stops = [];
  int _selectedStopIndex = -1;
  bool _isSubmitting = false;

  // Form controllers for each stop
  final _stopNameCtrl = TextEditingController();
  final _stopDescCtrl = TextEditingController();
  final _experienceCtrl = TextEditingController();
  final List<String> _currentExperiences = [];

  // Hosting
  final List<Hosting> _accommodations = [];
  final _hostingNameCtrl = TextEditingController();
  final _hostingAddressCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pre-populate if editing an existing itinerary
    if (widget.travel.hasItinerary) {
      _stops.addAll(widget.travel.itinerary!.listOfStops);
      _accommodations.addAll(widget.travel.itinerary!.accommodationsList);
    }
  }

  @override
  void dispose() {
    _stopNameCtrl.dispose();
    _stopDescCtrl.dispose();
    _experienceCtrl.dispose();
    _hostingNameCtrl.dispose();
    _hostingAddressCtrl.dispose();
    super.dispose();
  }

  void _addExperience() {
    if (_experienceCtrl.text.isNotEmpty) {
      setState(() {
        _currentExperiences.add(_experienceCtrl.text);
        _experienceCtrl.clear();
      });
    }
  }

  void _addStop() {
    if (_stopNameCtrl.text.isEmpty) return;
    setState(() {
      _stops.add(ItineraryStop(
        id: 'stop_${DateTime.now().millisecondsSinceEpoch}',
        name: _stopNameCtrl.text,
        description: _stopDescCtrl.text,
        experiences: List.from(_currentExperiences),
        isCompleted: false,
      ));
      _stopNameCtrl.clear();
      _stopDescCtrl.clear();
      _currentExperiences.clear();
    });
  }

  void _selectStop(int index) {
    setState(() {
      _selectedStopIndex = index;
      final stop = _stops[index];
      _stopNameCtrl.text = stop.name;
      _stopDescCtrl.text = stop.description;
      _currentExperiences
        ..clear()
        ..addAll(stop.experiences);
    });
  }

  void _updateStop() {
    if (_selectedStopIndex < 0) return;
    setState(() {
      _stops[_selectedStopIndex] = ItineraryStop(
        id: _stops[_selectedStopIndex].id,
        name: _stopNameCtrl.text,
        description: _stopDescCtrl.text,
        experiences: List.from(_currentExperiences),
        isCompleted: _stops[_selectedStopIndex].isCompleted,
      );
      _selectedStopIndex = -1;
      _stopNameCtrl.clear();
      _stopDescCtrl.clear();
      _currentExperiences.clear();
    });
  }

  Future<void> _saveItinerary({bool finish = false}) async {
    if (_stops.isEmpty) return;

    setState(() => _isSubmitting = true);

    final controller = context.read<TravelsController>();
    final itineraryData = {
      'id': widget.travel.itinerary?.id ??
          'itinerary_${DateTime.now().millisecondsSinceEpoch}',
      'responsibleAgentName': 'Agent Smith', // From logged user
      'accommodationsList':
          _accommodations.map((a) => a.toMap()).toList(),
      'listOfStops': _stops.map((s) => s.toMap()).toList(),
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
      body: Column(
        children: [
          BreadcrumbBar(items: [
            'Travels Dashboard',
            'Travel View',
            widget.travel.hasItinerary
                ? 'Edit Itinerary'
                : 'Create Itinerary',
          ]),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Left: Interest Points ────────────────────────
                SizedBox(
                  width: 250,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.05),
                        child: Text('Interest Points',
                            style: theme.textTheme.titleSmall
                                ?.copyWith(
                                    fontWeight: FontWeight.w600)),
                      ),
                      Expanded(
                        child: route.interestsList.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Text('No interest points'),
                                ),
                              )
                            : ListView.builder(
                                itemCount:
                                    route.interestsList.length,
                                itemBuilder: (context, index) {
                                  final poi =
                                      route.interestsList[index];
                                  return ListTile(
                                    dense: true,
                                    leading: Icon(Icons.place,
                                        size: 18,
                                        color: theme
                                            .colorScheme.secondary),
                                    title: Text(poi.name,
                                        style: const TextStyle(
                                            fontSize: 13)),
                                    subtitle: Text(
                                        poi.description,
                                        style: const TextStyle(
                                            fontSize: 11)),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
                VerticalDivider(
                    width: 1, color: theme.dividerColor),
                // ─── Center: Stop Form ────────────────────────────
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedStopIndex >= 0
                              ? 'Edit Stop #${_selectedStopIndex + 1}'
                              : 'Add New Stop',
                          style: theme.textTheme.titleMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _stopNameCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Stop Name',
                              border: OutlineInputBorder()),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _stopDescCtrl,
                          decoration: const InputDecoration(
                              labelText: 'Description',
                              border: OutlineInputBorder()),
                          maxLines: 2,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _experienceCtrl,
                                decoration: const InputDecoration(
                                    labelText: 'Add Experience',
                                    border:
                                        OutlineInputBorder()),
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              onPressed: _addExperience,
                              icon: const Icon(
                                  Icons.add_circle),
                              color:
                                  theme.colorScheme.secondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          children: _currentExperiences
                              .map((e) => Chip(
                                    label: Text(e,
                                        style:
                                            const TextStyle(
                                                fontSize:
                                                    12)),
                                    onDeleted: () {
                                      setState(() =>
                                          _currentExperiences
                                              .remove(e));
                                    },
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (_selectedStopIndex >= 0) ...[
                              ElevatedButton(
                                onPressed: _updateStop,
                                child:
                                    const Text('Update Stop'),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedStopIndex = -1;
                                    _stopNameCtrl.clear();
                                    _stopDescCtrl.clear();
                                    _currentExperiences
                                        .clear();
                                  });
                                },
                                child: const Text('Cancel'),
                              ),
                            ] else
                              ElevatedButton.icon(
                                onPressed: _addStop,
                                icon:
                                    const Icon(Icons.add),
                                label: const Text(
                                    'Add Stop'),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                    width: 1, color: theme.dividerColor),
                // ─── Right: Created Stops ─────────────────────────
                SizedBox(
                  width: 280,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        color: theme.colorScheme.primary
                            .withValues(alpha: 0.05),
                        child: Text(
                            'Stops (${_stops.length})',
                            style: theme
                                .textTheme.titleSmall
                                ?.copyWith(
                                    fontWeight:
                                        FontWeight.w600)),
                      ),
                      Expanded(
                        child: _stops.isEmpty
                            ? const Center(
                                child: Padding(
                                  padding:
                                      EdgeInsets.all(16),
                                  child:
                                      Text('No stops yet'),
                                ),
                              )
                            : ReorderableListView.builder(
                                itemCount: _stops.length,
                                onReorder: (oldIndex,
                                    newIndex) {
                                  setState(() {
                                    if (newIndex >
                                        oldIndex) {
                                      newIndex -= 1;
                                    }
                                    final item = _stops
                                        .removeAt(
                                            oldIndex);
                                    _stops.insert(
                                        newIndex, item);
                                  });
                                },
                                itemBuilder:
                                    (context, index) {
                                  final stop =
                                      _stops[index];
                                  final isSelected =
                                      index ==
                                          _selectedStopIndex;
                                  return ListTile(
                                    key: ValueKey(
                                        stop.id),
                                    selected: isSelected,
                                    selectedTileColor: theme
                                        .colorScheme
                                        .secondary
                                        .withValues(
                                            alpha: 0.1),
                                    leading:
                                        CircleAvatar(
                                      radius: 14,
                                      backgroundColor:
                                          theme
                                              .colorScheme
                                              .primary,
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: theme
                                              .colorScheme
                                              .onPrimary,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      stop.name,
                                      style:
                                          const TextStyle(
                                              fontSize:
                                                  13,
                                              fontWeight:
                                                  FontWeight
                                                      .w600),
                                    ),
                                    subtitle: Text(
                                      stop.description,
                                      style:
                                          const TextStyle(
                                              fontSize:
                                                  11),
                                      maxLines: 1,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                    trailing:
                                        IconButton(
                                      icon: const Icon(
                                          Icons.close,
                                          size: 16),
                                      onPressed: () {
                                        setState(() {
                                          _stops.removeAt(
                                              index);
                                          if (_selectedStopIndex ==
                                              index) {
                                            _selectedStopIndex =
                                                -1;
                                          }
                                        });
                                      },
                                    ),
                                    onTap: () =>
                                        _selectStop(
                                            index),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
