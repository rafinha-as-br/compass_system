import 'package:flutter/material.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/transport.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/utils/date_formatting.dart';
import 'package:routecraft_app/shared/widgets/info_tile.dart';

/// Full detail of an [ItineraryStep], meant as the `child` of
/// `AppBottomSheet.show` (title: `step.title`) opened from the timeline
/// (CPS-91). Read-only — no edit affordance — with one [InfoTile] per field,
/// following DESIGN.md §3.3.
class StepDetailSheet extends StatelessWidget {
  const StepDetailSheet({super.key, required this.step});

  final ItineraryStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final tiles = _infoTiles(step, l10n, languageCode);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _subtypeLabel(step, l10n),
          style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 16),
        for (final tile in tiles) ...[tile, const SizedBox(height: 16)],
      ],
    );
  }
}

String _subtypeLabel(ItineraryStep step, AppLocalizations l10n) => switch (step) {
      Stop() => l10n.stepDetailTypeStop,
      Hosting() => l10n.stepDetailTypeHosting,
      PlaceholderStep() => l10n.stepDetailTypePlaceholder,
      TravelSegment(:final transport) => switch (transport) {
          Airplane() => '${l10n.stepDetailTypeTravelSegment} · ${l10n.stepDetailSubtypeAirplane}',
          Bus() => '${l10n.stepDetailTypeTravelSegment} · ${l10n.stepDetailSubtypeBus}',
          RentalCar() => '${l10n.stepDetailTypeTravelSegment} · ${l10n.timelineRentalCarLabel}',
          _ => l10n.stepDetailTypeTravelSegment,
        },
      _ => l10n.stepDetailTypePlaceholder,
    };

List<Widget> _infoTiles(ItineraryStep step, AppLocalizations l10n, String languageCode) => switch (step) {
      Stop(:final name, :final description, :final experiences) => [
          InfoTile(icon: Icons.badge_outlined, label: l10n.stepDetailName, value: name),
          if (description.isNotEmpty)
            InfoTile(icon: Icons.notes_outlined, label: l10n.stepDetailDescription, value: description),
          if (experiences.isNotEmpty)
            InfoTile(icon: Icons.star_outline, label: l10n.stepDetailExperiences, value: experiences.join(', ')),
        ],
      Hosting(:final address, :final checkIn, :final checkOut) => [
          InfoTile(icon: Icons.location_on_outlined, label: l10n.stepDetailAddress, value: address),
          InfoTile(icon: Icons.login, label: l10n.stepDetailCheckIn, value: _formatDateTime(languageCode, checkIn)),
          InfoTile(icon: Icons.logout, label: l10n.stepDetailCheckOut, value: _formatDateTime(languageCode, checkOut)),
        ],
      PlaceholderStep(:final description) => [
          if (description.isNotEmpty)
            InfoTile(icon: Icons.notes_outlined, label: l10n.stepDetailDescription, value: description),
        ],
      TravelSegment(:final transport, :final startPoint, :final finishPoint) => [
          InfoTile(icon: Icons.trip_origin, label: l10n.stepDetailOrigin, value: startPoint),
          InfoTile(icon: Icons.flag_outlined, label: l10n.stepDetailDestination, value: finishPoint),
          ..._transportTiles(transport, l10n, languageCode),
        ],
      _ => const [],
    };

List<Widget> _transportTiles(Transport transport, AppLocalizations l10n, String languageCode) => switch (transport) {
      Airplane(
        :final flightNumber,
        :final flightCompany,
        :final flightDate,
        :final departureGate,
        :final departureAirport,
        :final arrivalAirport,
      ) =>
        [
          InfoTile(icon: Icons.flight_outlined, label: l10n.stepDetailFlight, value: '$flightNumber · $flightCompany'),
          InfoTile(icon: Icons.event_outlined, label: l10n.stepDetailDate, value: _formatDateTime(languageCode, flightDate)),
          InfoTile(icon: Icons.door_front_door_outlined, label: l10n.stepDetailGate, value: departureGate),
          InfoTile(icon: Icons.map_outlined, label: l10n.stepDetailAirports, value: '$departureAirport → $arrivalAirport'),
        ],
      Bus(
        :final travelNumber,
        :final travelCompany,
        :final departureGate,
        :final busStationName,
        :final departureDateTime,
      ) =>
        [
          InfoTile(icon: Icons.directions_bus_outlined, label: l10n.stepDetailBusLine, value: '$travelNumber · $travelCompany'),
          InfoTile(icon: Icons.door_front_door_outlined, label: l10n.stepDetailGate, value: departureGate),
          InfoTile(icon: Icons.store_outlined, label: l10n.stepDetailBusStation, value: busStationName),
          InfoTile(
            icon: Icons.event_outlined,
            label: l10n.stepDetailDepartureTime,
            value: _formatDateTime(languageCode, departureDateTime),
          ),
        ],
      RentalCar(
        :final vehicleModelName,
        :final vehicleLicensePlate,
        :final companyName,
        :final checkInDate,
        :final checkOutDate,
      ) =>
        [
          InfoTile(icon: Icons.directions_car_outlined, label: l10n.stepDetailModel, value: vehicleModelName),
          InfoTile(icon: Icons.confirmation_number_outlined, label: l10n.stepDetailLicensePlate, value: vehicleLicensePlate),
          InfoTile(icon: Icons.business_outlined, label: l10n.stepDetailRentalCompany, value: companyName),
          InfoTile(icon: Icons.login, label: l10n.stepDetailPickUp, value: _formatDateTime(languageCode, checkInDate)),
          InfoTile(icon: Icons.logout, label: l10n.stepDetailDropOff, value: _formatDateTime(languageCode, checkOutDate)),
        ],
      _ => const [],
    };

String _formatDateTime(String languageCode, DateTime date) =>
    '${date.day} ${monthAbbreviation(languageCode, date.month)} · ${formatTime(date)}';
