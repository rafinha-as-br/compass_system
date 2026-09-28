

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/route_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_event_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

import '../../../domain/entities/travel.dart';
import 'itinerary_view_model.dart';

/// Enum view model for [TravelStatus]
enum TravelStatusViewModel {
  notReady,
  ready,
  inProgress,
  completed;

  /// Converts [TravelStatus] domain enum
  /// to [TravelStatusViewModel]
  static TravelStatusViewModel fromDomain(
      TravelStatus status,
      ) {
    switch (status) {
      case TravelStatus.routeCreated:
        return TravelStatusViewModel.notReady;

      case TravelStatus.itineraryCreated:
        return TravelStatusViewModel.ready;

      case TravelStatus.travelStarted:
        return TravelStatusViewModel.inProgress;

      case TravelStatus.travelFinished:
        return TravelStatusViewModel.completed;
    }
  }

  /// Converts [TravelStatusViewModel]
  /// to [TravelStatus] domain enum
  TravelStatus toDomain() {
    switch (this) {
      case TravelStatusViewModel.notReady:
        return TravelStatus.routeCreated;

      case TravelStatusViewModel.ready:
        return TravelStatus.itineraryCreated;

      case TravelStatusViewModel.inProgress:
        return TravelStatus.travelStarted;

      case TravelStatusViewModel.completed:
        return TravelStatus.travelFinished;
    }
  }
}

/// Shared status→color/label/support-line presentation for
/// [TravelStatusViewModel] — reused by the app bar chip and by the
/// Overview tab's status card so the two mappings never drift apart.
extension TravelStatusPresentation on TravelStatusViewModel {
  /// Base color for the status — always applied at 12% alpha for chip/icon
  /// backgrounds, matching the pattern already used across the app (the
  /// solid *Container [ColorScheme] tokens are undefined here, so they
  /// silently fall back to the full-strength color).
  Color color(ThemeData theme) {
    switch (this) {
      case TravelStatusViewModel.notReady:
        return theme.semanticColors.warning;
      case TravelStatusViewModel.ready:
        return theme.semanticColors.success;
      case TravelStatusViewModel.inProgress:
        return theme.colorScheme.primary;
      case TravelStatusViewModel.completed:
        return theme.colorScheme.secondary;
    }
  }

  /// Localized label for the Overview tab's status card — distinct from
  /// [TravelViewModel.statusString], which is not localized and keeps
  /// powering the existing app bar chip unchanged.
  String label(AppLocalizations l10n) {
    switch (this) {
      case TravelStatusViewModel.notReady:
        return l10n.travelStatusNotReadyLabel;
      case TravelStatusViewModel.ready:
        return l10n.travelStatusReadyLabel;
      case TravelStatusViewModel.inProgress:
        return l10n.travelStatusInProgressLabel;
      case TravelStatusViewModel.completed:
        return l10n.travelStatusCompletedLabel;
    }
  }

  /// Localized support line for the Overview tab's status card.
  String supportLine(AppLocalizations l10n) {
    switch (this) {
      case TravelStatusViewModel.notReady:
        return l10n.travelStatusNotReadySupportLine;
      case TravelStatusViewModel.ready:
        return l10n.travelStatusReadySupportLine;
      case TravelStatusViewModel.inProgress:
        return l10n.travelStatusInProgressSupportLine;
      case TravelStatusViewModel.completed:
        return l10n.travelStatusCompletedSupportLine;
    }
  }
}


/// Travel view model class, used to represent a [Travel] on the UI
class TravelViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  final String clientName;
  final String travelTitle;
  /// Raw domain status — advances to [TravelStatus.itineraryCreated]
  /// automatically as soon as an itinerary exists (backend behavior,
  /// unchanged), independent of [prepared]. Use [status] for display.
  final TravelStatus travelStatus;
  final RoutePlanViewModel route;
  final ItineraryViewModel? itinerary;
  final List<PersonViewModel> participants;
  final List<TravelEventViewModel>? events;
  /// Free-text note from the client to the agent — read-only, but still
  /// carried through so [toDomain] never drops it on a full-object update.
  final String? observations;
  /// Whether the agent has explicitly confirmed "Preparar viagem" — see
  /// [Travel.prepared]. Carried through so [toDomain] never drops it.
  final bool prepared;

  /// Display status: [travelStatus] alone stops being enough to mean
  /// "ready" once itinerary creation started auto-advancing it — the trip
  /// only shows as Ready once the agent explicitly confirms "Preparar
  /// viagem" (CPS-166). Computed from [travelStatus]/[prepared] instead of
  /// stored, so it can never drift out of sync with either.
  TravelStatusViewModel get status {
    final domainStatus = TravelStatusViewModel.fromDomain(travelStatus);
    return domainStatus == TravelStatusViewModel.ready && !prepared
        ? TravelStatusViewModel.notReady
        : domainStatus;
  }

  TravelViewModel({
    required this.backEndId,
    required this.localId,
    required this.clientName,
    required this.travelTitle,
    required this.travelStatus,
    required this.route,
    required this.participants,
    required this.events,
    this.itinerary,
    this.observations,
    this.prepared = false,
  });

  /// Factory constructor from domain model
  factory TravelViewModel.fromDomain(Travel travel){
    return TravelViewModel(
      backEndId: travel.backEndId,
      localId: travel.domainId,
      clientName: travel.clientName,
      travelTitle: travel.travelName,
      travelStatus: travel.travelStatus,
      route: RoutePlanViewModel.fromDomain(travel.routePlan),
      participants: travel.participantsList.map((x) => PersonViewModel.fromDomain(x)).toList(),
      events: travel.eventsLog?.map((x) => TravelEventViewModel.fromDomain(x)).toList(),
      itinerary: travel.itinerary == null ? null : ItineraryViewModel.fromDomain(travel.itinerary!),
      observations: travel.observations,
      prepared: travel.prepared,
    );
  }

  /// To domain mapper method
  Travel toDomain(){
    return Travel(
      domainId: localId,
      backEndId: backEndId,
      clientName: clientName,
      travelName: travelTitle,
      routePlan: route.toDomain(),
      participantsList: participants.map((x) => x.toDomain()).toList(),
      travelStatus: travelStatus,
      prepared: prepared,
      itinerary: itinerary?.toDomain(),
      eventsLog: events?.map((x) => x.toDomain()).toList(),
      observations: observations,
    );
  }

  String get statusString{
    switch(status){
      case TravelStatusViewModel.notReady:
        return 'Not Ready';
        case TravelStatusViewModel.ready:
        return 'Ready';
        case TravelStatusViewModel.inProgress:
        return 'In Progress';
        case TravelStatusViewModel.completed:
        return 'Completed';
    }
  }

  /// Returns a copy with the given fields replaced — used after a
  /// sub-resource mutation (e.g. participants) that only returns that
  /// piece back from the API, not the whole [Travel].
  TravelViewModel copyWith({
    List<PersonViewModel>? participants,
  }) {
    return TravelViewModel(
      backEndId: backEndId,
      localId: localId,
      clientName: clientName,
      travelTitle: travelTitle,
      travelStatus: travelStatus,
      route: route,
      participants: participants ?? this.participants,
      events: events,
      itinerary: itinerary,
      observations: observations,
      prepared: prepared,
    );
  }

}

/// Person view model class, used to represent a [Person] on the UI
class PersonViewModel{
  /// Represents the id on the API, can be null in case of a new local instance
  final String? backEndId;
  final String localId;
  final String name;
  final String age;
  final String sex;

  PersonViewModel({
    required this.backEndId,
    required this.localId,
    required this.name,
    required this.age,
    required this.sex,
  });

  /// To domain mapper method
  Person toDomain(){
    return Person(
      domainId: localId,
      backendId: backEndId,
      name: name,
      age: age,
      sex: sex,
    );
  }

  /// Factory constructor from domain model
  factory PersonViewModel.fromDomain(
      Person person,
      ){
    return PersonViewModel(
      backEndId: person.backendId,
      localId: person.domainId,
      name: person.name,
      age: person.age,
      sex: person.sex,
    );
  }

  /// Factory constructor for local model
  factory PersonViewModel.fromLocal(
      String name,
      String age,
      String sex,
    ){
    return PersonViewModel(
      backEndId: null,
      // Uuid, not `name` — matches RoutePlanViewModel/InterestPointViewModel's
      // own `fromLocal` convention. Two participants can share the same
      // name, and [id] is used to tell list items apart (e.g. on removal).
      localId: const Uuid().v4(),
      name: name,
      age: age,
      sex: sex,
    );
  }

  /// Provides the local ID for UI reference
  String get id => localId;


}