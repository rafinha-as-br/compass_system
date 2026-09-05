import 'package:flutter/material.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';

/// Itinerary step types the client's read-only timeline can show — kept
/// independent from the travels feature's own domain types so this shared
/// widget has no dependency on it.
enum StepIconType { stop, hosting, airplane, bus, rentalCar, boundary }

/// Icon by itinerary step type — same mapping used in the timeline and (in
/// Travel Matrix) the step type selector.
class StepIcon extends StatelessWidget {
  final StepIconType type;

  const StepIcon({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color) = switch (type) {
      StepIconType.stop => (Icons.place_outlined, theme.colorScheme.primary),
      StepIconType.hosting => (Icons.bed_outlined, TravelAppColors.info),
      StepIconType.airplane => (Icons.flight_outlined, theme.colorScheme.secondary),
      StepIconType.bus => (Icons.directions_bus_outlined, TravelAppColors.warning),
      StepIconType.rentalCar => (Icons.directions_car_outlined, TravelAppColors.success),
      StepIconType.boundary => (Icons.flag_outlined, theme.colorScheme.onSurface),
    };

    return CircleAvatar(
      radius: 20,
      backgroundColor: color.withValues(alpha: 0.12),
      child: Icon(icon, color: color, size: 20),
    );
  }
}
