import 'package:flutter/widgets.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/shared/utils/date_formatting.dart';
import 'package:routecraft_app/shared/widgets/travel_status_chip.dart';

/// Maps the domain [TravelStatus] to the shared [TravelStatusChip]'s own
/// variant enum — used wherever a [Travel] is rendered as a card (Início,
/// Viagens).
TravelStatusChipVariant travelStatusChipVariant(TravelStatus status) => switch (status) {
      TravelStatus.routeCreated => TravelStatusChipVariant.routeCreated,
      TravelStatus.itineraryCreated => TravelStatusChipVariant.itineraryCreated,
      TravelStatus.travelStarted => TravelStatusChipVariant.travelStarted,
      TravelStatus.travelFinished => TravelStatusChipVariant.travelFinished,
    };

/// "origem → destino" for a [TravelCard] — used wherever a [Travel] is
/// rendered as a card (Início, Viagens).
String travelRouteText(Travel travel) {
  final route = travel.routePlan;
  return '${route.startLocation} → ${route.destination}';
}

/// The travel's date range, formatted for the current locale — used
/// wherever a [Travel] is rendered as a card (Início, Viagens).
String travelPeriodText(BuildContext context, Travel travel) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final route = travel.routePlan;
  return formatDateRange(languageCode, route.startDate, route.endDate);
}
