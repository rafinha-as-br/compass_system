import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/core/services/compass_service.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class ItineraryCreationState {
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const ItineraryCreationState({
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ItineraryCreationState copyWith({
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ItineraryCreationState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ItineraryCreationController extends ChangeNotifier {
  ItineraryCreationState _state = const ItineraryCreationState();
  ItineraryCreationState get state => _state;

  final List<ItineraryStop> _stops = [];
  List<ItineraryStop> get stops => _stops;

  void addStop(String location, String activity, String date) {
    _stops.add(ItineraryStop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itineraryId: '',
      location: location,
      description: activity,
      reservationInformation: date,
    ));
    notifyListeners();
  }

  void removeStop(String id) {
    _stops.removeWhere((stop) => stop.id == id);
    notifyListeners();
  }

  Future<void> submitItinerary() async {
    _state = _state.copyWith(isSubmitting: true, errorMessage: null);
    notifyListeners();

    try {
      final itineraryId = 'itinerary_${DateTime.now().millisecondsSinceEpoch}';
      
      final definedStops = _stops.map((s) => ItineraryStop(
        id: s.id,
        itineraryId: itineraryId,
        location: s.location,
        description: s.description,
        reservationInformation: s.reservationInformation,
      )).toList();

      final newItinerary = Itinerary(
        id: itineraryId,
        routeId: 'ROUTE-MOCK', 
        createdByAgent: 'agent_1',
        listOfStops: definedStops,
      );

      await CompassService.instance.createItinerary(newItinerary);

      _state = _state.copyWith(isSubmitting: false, isSuccess: true);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(
        isSubmitting: false,
        errorMessage: 'Failed to create Itinerary: $e',
      );
      notifyListeners();
    }
  }

  void reset() {
    _stops.clear();
    _state = const ItineraryCreationState();
    notifyListeners();
  }
}

class ItineraryCreationPage extends StatelessWidget {
  const ItineraryCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ItineraryCreationController(),
      child: const _ItineraryCreationView(),
    );
  }
}

class _ItineraryCreationView extends StatefulWidget {
  const _ItineraryCreationView();

  @override
  State<_ItineraryCreationView> createState() => _ItineraryCreationViewState();
}

class _ItineraryCreationViewState extends State<_ItineraryCreationView> {
  final _activityCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _dateCtrl = TextEditingController();

  @override
  void dispose() {
    _activityCtrl.dispose();
    _locationCtrl.dispose();
    _dateCtrl.dispose();
    super.dispose();
  }

  void _onAddStop() {
    if (_activityCtrl.text.isEmpty || _locationCtrl.text.isEmpty) return;
    
    context.read<ItineraryCreationController>().addStop(
      _locationCtrl.text,
      _activityCtrl.text,
      _dateCtrl.text.isEmpty ? 'TBD' : _dateCtrl.text,
    );
    
    _activityCtrl.clear();
    _locationCtrl.clear();
    _dateCtrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ItineraryCreationController>();
    final state = controller.state;

    if (state.isSuccess) {
      return Scaffold(
        backgroundColor: TravelAppColors.background,
        body: Center(
          child: Container(
            padding: const EdgeInsets.all(48),
            decoration: BoxDecoration(color: TravelAppColors.surface, borderRadius: BorderRadius.circular(16), border: Border.all(color: TravelAppColors.border)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: TravelAppColors.success, size: 80),
                const SizedBox(height: 16),
                const Text('Itinerary Built Successfully', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: TravelAppColors.primary)),
                const SizedBox(height: 8),
                const Text('The itinerary has been saved and linked to the client route.', style: TextStyle(color: TravelAppColors.textSecondary)),
                const SizedBox(height: 32),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: TravelAppColors.primary, foregroundColor: TravelAppColors.surface, padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16)),
                  onPressed: () => controller.reset(),
                  child: const Text('Create Another Itinerary', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: TravelAppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Booking > Itinerary Creation', style: TextStyle(color: TravelAppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Dynamic Itinerary Builder', style: TextStyle(color: TravelAppColors.primary, fontSize: 28, fontWeight: FontWeight.bold)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: TravelAppColors.success,
                    foregroundColor: TravelAppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: controller.stops.isEmpty || state.isSubmitting ? null : () => controller.submitItinerary(),
                  icon: state.isSubmitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: TravelAppColors.surface, strokeWidth: 2)) : const Icon(Icons.send, size: 20),
                  label: Text(state.isSubmitting ? 'PROCESSING...' : 'FINALIZE & SAVE', style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 32),
            if (state.errorMessage != null)
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: TravelAppColors.error.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(state.errorMessage!, style: const TextStyle(color: TravelAppColors.error, fontWeight: FontWeight.bold)),
              ),

            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Pane: Form
                  Expanded(
                    flex: 4,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: TravelAppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: TravelAppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Add New Stop', style: TextStyle(color: TravelAppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          const Text('Fill the details to add a new chronological stop to this itinerary.', style: TextStyle(color: TravelAppColors.textSecondary)),
                          const SizedBox(height: 32),
                          const Text('ACTIVITY NAME', style: TextStyle(color: TravelAppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _activityCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. Private Museum Tour',
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: TravelAppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: TravelAppColors.border)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('LOCATION', style: TextStyle(color: TravelAppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _locationCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. The Louvre, Paris',
                              prefixIcon: const Icon(Icons.location_on, color: TravelAppColors.textSecondary),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: TravelAppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: TravelAppColors.border)),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text('DATE & TIME', style: TextStyle(color: TravelAppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _dateCtrl,
                            decoration: InputDecoration(
                              hintText: 'e.g. Oct 24, 2023 - 10:00 AM',
                              prefixIcon: const Icon(Icons.calendar_today, color: TravelAppColors.textSecondary, size: 18),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: TravelAppColors.border)),
                              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: TravelAppColors.border)),
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 20),
                                backgroundColor: TravelAppColors.primary,
                                foregroundColor: TravelAppColors.surface,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: _onAddStop,
                              icon: const Icon(Icons.add_circle_outline, size: 20),
                              label: const Text('Add Stop to Itinerary', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 32),
                  // Right Pane: Dynamic Stepper
                  Expanded(
                    flex: 5,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: TravelAppColors.background, // Match background so it flows naturally, or surface
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Itinerary Timeline', style: TextStyle(color: TravelAppColors.primary, fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Text('${controller.stops.length} Stops configured', style: const TextStyle(color: TravelAppColors.textSecondary)),
                          const SizedBox(height: 32),
                          Expanded(
                            child: controller.stops.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.timeline, size: 60, color: TravelAppColors.border),
                                        const SizedBox(height: 16),
                                        const Text('No stops added yet.', style: TextStyle(color: TravelAppColors.textSecondary, fontSize: 16, fontWeight: FontWeight.bold)),
                                        const SizedBox(height: 4),
                                        const Text('Use the form on the left to start building.', style: TextStyle(color: TravelAppColors.textSecondary)),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    itemCount: controller.stops.length,
                                    itemBuilder: (context, index) {
                                      final stop = controller.stops[index];
                                      final isLast = index == controller.stops.length - 1;
                                      return _buildTimelineStep(stop, index + 1, isLast, controller);
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineStep(ItineraryStop stop, int stepNumber, bool isLast, ItineraryCreationController controller) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline line & node
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: TravelAppColors.accentGold,
                  shape: BoxShape.circle,
                  border: Border.all(color: TravelAppColors.surface, width: 3),
                  boxShadow: [
                    BoxShadow(color: TravelAppColors.accentGold.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Center(child: Text('$stepNumber', style: const TextStyle(color: TravelAppColors.surface, fontWeight: FontWeight.bold, fontSize: 12))),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: TravelAppColors.divider,
                  ),
                ),
            ],
          ),
          const SizedBox(width: 24),
          // Content Card
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: TravelAppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: TravelAppColors.border),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(stop.description, style: const TextStyle(color: TravelAppColors.primary, fontSize: 18, fontWeight: FontWeight.bold)),
                        IconButton(
                          onPressed: () => controller.removeStop(stop.id),
                          icon: const Icon(Icons.close, size: 18, color: TravelAppColors.textSecondary),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        )
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 16, color: TravelAppColors.accentGold),
                        const SizedBox(width: 8),
                        Text(stop.location, style: const TextStyle(color: TravelAppColors.textSecondary, fontWeight: FontWeight.w600)),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.access_time, size: 16, color: TravelAppColors.textSecondary),
                        const SizedBox(width: 8),
                        Text(stop.reservationInformation, style: const TextStyle(color: TravelAppColors.textSecondary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
