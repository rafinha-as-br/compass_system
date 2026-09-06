import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/transport.dart';
import 'package:routecraft_app/shared/widgets/step_icon.dart';

/// Maps a domain [ItineraryStep] to the [StepIconType] used to render it —
/// shared by every screen that lists itinerary steps (hub, timeline).
StepIconType stepIconType(ItineraryStep step) => switch (step) {
      Stop() => StepIconType.stop,
      Hosting() => StepIconType.hosting,
      TravelSegment(:final transport) => switch (transport) {
          Airplane() => StepIconType.airplane,
          Bus() => StepIconType.bus,
          RentalCar() => StepIconType.rentalCar,
          _ => StepIconType.boundary,
        },
      _ => StepIconType.boundary,
    };
