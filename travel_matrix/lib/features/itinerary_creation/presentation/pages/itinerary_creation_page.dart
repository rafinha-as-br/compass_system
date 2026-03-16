import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/core/services/compass_service.dart';

class ItineraryCreationState {
  final int currentStep;
  final bool isSubmitting;
  final String? errorMessage;
  final bool isSuccess;

  const ItineraryCreationState({
    this.currentStep = 0,
    this.isSubmitting = false,
    this.errorMessage,
    this.isSuccess = false,
  });

  ItineraryCreationState copyWith({
    int? currentStep,
    bool? isSubmitting,
    String? errorMessage,
    bool? isSuccess,
  }) {
    return ItineraryCreationState(
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

class ItineraryCreationController extends ChangeNotifier {
  ItineraryCreationState _state = const ItineraryCreationState();
  ItineraryCreationState get state => _state;

  final routeIdController = TextEditingController();
  final List<ItineraryStop> stops = [];

  void nextStep() {
    if (_state.currentStep < 1) {
      _state = _state.copyWith(currentStep: _state.currentStep + 1);
      notifyListeners();
    }
  }

  void previousStep() {
    if (_state.currentStep > 0) {
      _state = _state.copyWith(currentStep: _state.currentStep - 1);
      notifyListeners();
    }
  }

  void addStop(String location, String desc, String reservation) {
    stops.add(ItineraryStop(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      itineraryId: '', // Set on submit
      location: location,
      description: desc,
      reservationInformation: reservation,
    ));
    notifyListeners();
  }

  Future<void> submitItinerary() async {
    _state = _state.copyWith(isSubmitting: true, errorMessage: null);
    notifyListeners();

    try {
      final itineraryId = 'itinerary_${DateTime.now().millisecondsSinceEpoch}';
      
      // Update stops with real ID
      final definedStops = stops.map((s) => ItineraryStop(
        id: s.id,
        itineraryId: itineraryId,
        location: s.location,
        description: s.description,
        reservationInformation: s.reservationInformation,
      )).toList();

      final newItinerary = Itinerary(
        id: itineraryId,
        routeId: routeIdController.text,
        createdByAgent: 'agent_1', // Mocked currently authenticated agent
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

class _ItineraryCreationView extends StatelessWidget {
  const _ItineraryCreationView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<ItineraryCreationController>();
    final state = controller.state;

    if (state.isSuccess) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 80),
            const SizedBox(height: 16),
            const Text('Itinerary created successfully!', style: TextStyle(fontSize: 20)),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Should optimally return to first step to build more or switch tab
              },
              child: const Text('Create Another'),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Itinerary Creation Wizard', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Expanded(
            child: Stepper(
              type: StepperType.horizontal,
              currentStep: state.currentStep,
              onStepContinue: controller.nextStep,
              onStepCancel: controller.previousStep,
              controlsBuilder: (context, details) {
                final isLastStep = state.currentStep == 1;
                return Padding(
                  padding: const EdgeInsets.only(top: 24.0),
                  child: Row(
                    children: [
                      if (isLastStep)
                        ElevatedButton(
                          onPressed: state.isSubmitting ? null : () => controller.submitItinerary(),
                          child: state.isSubmitting
                              ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('SUBMIT ITINERARY'),
                        )
                      else
                        ElevatedButton(
                          onPressed: details.onStepContinue,
                          child: const Text('NEXT'),
                        ),
                      const SizedBox(width: 12),
                      if (state.currentStep > 0)
                        TextButton(
                          style: TextButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: state.isSubmitting ? null : details.onStepCancel,
                          child: const Text('BACK'),
                        ),
                    ],
                  ),
                );
              },
              steps: [
                Step(
                  title: const Text('Select Route'),
                  content: Column(
                    children: [
                      TextField(
                        controller: controller.routeIdController,
                        decoration: const InputDecoration(labelText: 'Route ID'),
                      ),
                      const SizedBox(height: 16),
                      const Text('In a full version, a dropdown picking from drafts would render here.')
                    ],
                  ),
                  isActive: state.currentStep >= 0,
                  state: state.currentStep > 0 ? StepState.complete : StepState.indexed,
                ),
                Step(
                  title: const Text('Configure Stops'),
                  content: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          controller.addStop('Sample Hotel', 'Rest Details', 'Res #H-4392');
                        },
                        icon: const Icon(Icons.add),
                        label: const Text('Add Debug Stop'),
                      ),
                      const SizedBox(height: 16),
                      ...controller.stops.map((s) => Card(
                        child: ListTile(
                          title: Text(s.location),
                          subtitle: Text('${s.description} | ${s.reservationInformation}'),
                        ),
                      )),
                      if (state.errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                        )
                    ],
                  ),
                  isActive: state.currentStep >= 1,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
