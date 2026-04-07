import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/features/route_creation/presentation/controllers/route_creation_controller.dart';

class RouteCreationPage extends StatelessWidget {
  const RouteCreationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => RouteCreationController(),
      child: const _RouteCreationView(),
    );
  }
}

class _RouteCreationView extends StatelessWidget {
  const _RouteCreationView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RouteCreationController>();
    final state = controller.state;

    if (state.isSuccess) {
      return Scaffold(
        appBar: AppBar(title: const Text('Success')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 80),
              const SizedBox(height: 16),
              const Text('Route created successfully!', style: TextStyle(fontSize: 20)),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Back to Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create a Route'),
      ),
      body: Stepper(
        currentStep: state.currentStep,
        onStepContinue: controller.nextStep,
        onStepCancel: controller.previousStep,
        controlsBuilder: (context, details) {
          final isLastStep = state.currentStep == 2;
          return Padding(
            padding: const EdgeInsets.only(top: 24.0),
            child: Row(
              children: [
                if (isLastStep)
                  ElevatedButton(
                    onPressed: state.isSubmitting ? null : () => controller.submitRoute(),
                    child: state.isSubmitting
                        ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('SUBMIT ROUTE'),
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
            title: const Text('Trip Info'),
            content: Column(
              children: [
                TextField(
                  controller: controller.tripNameController,
                  decoration: const InputDecoration(labelText: 'Trip Name'),
                ),
              ],
            ),
            isActive: state.currentStep >= 0,
            state: state.currentStep > 0 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Locations'),
            content: Column(
              children: [
                TextField(
                  controller: controller.startLocationController,
                  decoration: const InputDecoration(labelText: 'Start Location'),
                ),
                TextField(
                  controller: controller.destinationController,
                  decoration: const InputDecoration(labelText: 'Destination'),
                ),
              ],
            ),
            isActive: state.currentStep >= 1,
            state: state.currentStep > 1 ? StepState.complete : StepState.indexed,
          ),
          Step(
            title: const Text('Interests'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8.0,
                  children: controller.interestPoints.map((i) => Chip(label: Text(i.name))).toList(),
                ),
                TextButton.icon(
                  onPressed: () {
                    controller.addInterestPoint('Culture & History', 'Historical sites');
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Add Culture Interest (Debug)'),
                ),
                if (state.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                  )
              ],
            ),
            isActive: state.currentStep >= 2,
          ),
        ],
      ),
    );
  }
}
