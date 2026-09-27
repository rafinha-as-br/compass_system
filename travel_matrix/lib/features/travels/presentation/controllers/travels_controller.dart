import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/participants_repository_impl.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/route_repository_impl.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/travel_repository_impl.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_participants.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';

import '../models/view_models/travel_view_model.dart';

class TravelsState {
  final bool isLoading;
  final List<TravelViewModel> travels;
  final String? errorMessage;

  /// Set when the listing itself failed to load (network/API down) — the UI
  /// shows a localized generic message for this instead of [errorMessage],
  /// which may contain raw, untranslated exception/backend text.
  final bool hasLoadError;

  const TravelsState({
    this.isLoading = true,
    this.travels = const [],
    this.errorMessage,
    this.hasLoadError = false,
  });

  TravelsState copyWith({
    bool? isLoading,
    List<TravelViewModel>? travels,
    String? errorMessage,
    bool? hasLoadError,
  }) {
    return TravelsState(
      isLoading: isLoading ?? this.isLoading,
      travels: travels ?? this.travels,
      errorMessage: errorMessage,
      hasLoadError: hasLoadError ?? false,
    );
  }
}

class TravelsController extends ChangeNotifier {
  final CrudTravelUseCases _travelUseCases;
  final CrudRoute _routeUseCases;
  final CrudParticipants _participantsUseCases;

  TravelsState _state = const TravelsState();
  TravelsState get state => _state;

  TravelsController({
    CrudTravelUseCases? travelUseCases,
    CrudRoute? routeUseCases,
    CrudParticipants? participantsUseCases,
  })  : _travelUseCases = travelUseCases ?? CrudTravelUseCases(TravelRepositoryImpl()),
        _routeUseCases = routeUseCases ?? CrudRoute(RouteRepositoryImpl()),
        _participantsUseCases = participantsUseCases ?? CrudParticipants(ParticipantsRepositoryImpl()) {
    fetchTravels();
  }

  Future<void> fetchTravels() async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final result = await _travelUseCases.readAll();

      if (result.isSuccess && result.data != null) {
        final travels = result.data!.map((t) => TravelViewModel.fromDomain(t)).toList();
        _state = TravelsState(isLoading: false, travels: travels);
      } else {
        _state = _state.copyWith(isLoading: false, hasLoadError: true);
      }
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(isLoading: false, hasLoadError: true);
      notifyListeners();
    }
  }

  /// Creates a travel from a raw creation-request payload (as built by
  /// [TravelCreationPage]: `clientId`, `agentId`, `travelName`, and a nested
  /// `routePlan` map) — see [CrudTravelUseCases.createFromRequest].
  Future<bool> createTravel(Map<String, dynamic> travelData) async {
    try {
      final result = await _travelUseCases.createFromRequest(travelData);
      if (result.isSuccess) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteTravel(String travelId) async {
    try {
      final result = await _travelUseCases.delete(travelId);
      if (result.isSuccess) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  /// Updates the route of an existing travel from the raw form data built by
  /// [RouteCreationPage] (`startDate`, `endDate`, `startLocation`,
  /// `destination`, `interestsList`) — kept separate from [RoutePlanDTO]'s
  /// json mapping since the two use different key names for the same data.
  Future<bool> updateRoute(String travelId, Map<String, dynamic> routeData) async {
    try {
      final interestPoints = ((routeData['interestsList'] as List<dynamic>?) ?? const [])
          .map((raw) {
            final map = raw as Map<String, dynamic>;
            final rawId = map['id']?.toString();
            final isTemporaryId = rawId == null || rawId.startsWith('poi_');
            return InterestPoint(
              domainId: rawId ?? const Uuid().v4(),
              backEndId: isTemporaryId ? null : rawId,
              name: map['name']?.toString() ?? '',
              description: map['description']?.toString() ?? '',
            );
          })
          .toList();

      final routePlan = RoutePlan(
        domainId: const Uuid().v4(),
        backEndId: null,
        startDate: DateTime.parse(routeData['startDate'] as String),
        endDate: DateTime.parse(routeData['endDate'] as String),
        startLocation: routeData['startLocation']?.toString() ?? '',
        destination: routeData['destination']?.toString() ?? '',
        interestsList: interestPoints,
      );

      final result = await _routeUseCases.updateRoute(travelId, routePlan);
      if (result.isSuccess) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<bool> markTravelAsReady(String travelId) async {
    try {
      final result = await _travelUseCases.markAsReady(travelId);
      if (result.isSuccess) {
        await fetchTravels();
        return true;
      }
      return false;
    } catch (_) {
      return false;
    }
  }

  bool _isSubmittingParticipants = false;
  bool get isSubmittingParticipants => _isSubmittingParticipants;

  /// Id of the participant currently being removed, so only that list item
  /// shows a spinner while the rest of the list stays interactive. Null
  /// while adding (the whole "Adicionar" action is disabled instead) or
  /// when nothing is in flight.
  String? _removingParticipantId;
  String? get removingParticipantId => _removingParticipantId;

  /// Generic, localizable-by-the-caller error from the last participants
  /// mutation — never the raw exception/backend text (see [Result.failure]
  /// callers in [ParticipantsRepositoryImpl]).
  String? get participantsErrorMessage => _participantsErrorMessage;
  String? _participantsErrorMessage;

  /// Appends [newParticipant] to [currentParticipants] and upserts the
  /// whole list — the API has no isolated "add one" operation.
  Future<List<PersonViewModel>?> addParticipant(
    String travelId,
    List<PersonViewModel> currentParticipants,
    PersonViewModel newParticipant,
  ) {
    return _submitParticipants(travelId, [...currentParticipants, newParticipant]);
  }

  /// Removes the participant with [participantId] from [currentParticipants]
  /// and upserts the whole list.
  Future<List<PersonViewModel>?> removeParticipant(
    String travelId,
    List<PersonViewModel> currentParticipants,
    String participantId,
  ) {
    return _submitParticipants(
      travelId,
      currentParticipants.where((p) => p.id != participantId).toList(),
      removingId: participantId,
    );
  }

  /// Upserts the participants list of [travelId] through the isolated
  /// endpoint. On success, also refetches the travels list (consistent with
  /// [updateRoute]/[markTravelAsReady]) so the dashboard reflects the new
  /// count — the caller is responsible for updating its own already-open
  /// [TravelViewModel] with the returned list, since this controller has no
  /// notion of "the currently viewed travel".
  Future<List<PersonViewModel>?> _submitParticipants(
    String travelId,
    List<PersonViewModel> participants, {
    String? removingId,
  }) async {
    _isSubmittingParticipants = true;
    _removingParticipantId = removingId;
    _participantsErrorMessage = null;
    notifyListeners();

    final result = await _participantsUseCases.updateParticipants(
      travelId,
      participants.map((p) => p.toDomain()).toList(),
    );

    List<PersonViewModel>? updated;
    if (result.isSuccess && result.data != null) {
      updated = result.data!.map((p) => PersonViewModel.fromDomain(p)).toList();
      await fetchTravels();
    } else {
      _participantsErrorMessage = result.error ?? 'Failed to update participants.';
    }

    _isSubmittingParticipants = false;
    _removingParticipantId = null;
    notifyListeners();

    return updated;
  }
}
