import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/data/repositories/participants_repository_impl.dart';
import 'package:routecraft_app/features/travels/data/repositories/route_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/person.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/usecases/participants_usecases.dart';
import 'package:routecraft_app/features/travels/domain/usecases/route_usecases.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/utils/date_formatting.dart';

class EditRouteState {
  final bool isSubmitting;
  final String? submitErrorMessage;
  final bool isSuccess;

  const EditRouteState({this.isSubmitting = false, this.submitErrorMessage, this.isSuccess = false});

  EditRouteState copyWith({bool? isSubmitting, String? submitErrorMessage, bool? isSuccess}) {
    return EditRouteState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      // No `?? this.submitErrorMessage` fallback: a passed `null` must clear
      // a stale message from a previous attempt (same fix as LoginState).
      submitErrorMessage: submitErrorMessage,
      isSuccess: isSuccess ?? this.isSuccess,
    );
  }
}

/// Edits the [RoutePlan] of an existing [Travel] — `PUT /travels/{id}/route`
/// is an isolated upsert that never touches the itinerary/participants, so
/// this controller only ever builds/sends a [RoutePlan]. Removed interest
/// points stay visible (struck through, with an "undo" action) until the
/// change is actually submitted, per wireframe 1i — never a destructive,
/// hard-to-reverse delete.
class EditRouteController extends ChangeNotifier {
  EditRouteController({
    required this.travelId,
    required this.original,
    required this.showPublishedWarning,
    required this.clientName,
    required List<Person> originalParticipants,
    RouteUseCases? routeUseCases,
    ParticipantsUseCases? participantsUseCases,
  })  : interestPoints = [...original.interestsList],
        startDate = original.startDate,
        endDate = original.endDate,
        participants = [...originalParticipants],
        _originalParticipants = originalParticipants,
        _routeUseCasesOverride = routeUseCases,
        _participantsUseCasesOverride = participantsUseCases {
    startLocationController = TextEditingController(text: original.startLocation)..addListener(notifyListeners);
    destinationController = TextEditingController(text: original.destination)..addListener(notifyListeners);
  }

  final String travelId;
  final RoutePlan original;
  final bool showPublishedWarning;

  /// The authenticated client's name — identifies which entry in
  /// [participants] is theirs (see [isClientParticipant]), since [Person]
  /// itself carries no such flag.
  final String clientName;

  final RouteUseCases? _routeUseCasesOverride;
  RouteUseCases get _routeUseCases => _routeUseCasesOverride ?? RouteUseCases(RouteRepositoryImpl());

  final ParticipantsUseCases? _participantsUseCasesOverride;
  ParticipantsUseCases get _participantsUseCases =>
      _participantsUseCasesOverride ?? ParticipantsUseCases(ParticipantsRepositoryImpl());

  EditRouteState _state = const EditRouteState();
  EditRouteState get state => _state;

  DateTime startDate;
  DateTime endDate;
  late final TextEditingController startLocationController;
  late final TextEditingController destinationController;

  /// Every interest point currently on the form — original ones plus any
  /// added this session. A point marked in [_pendingRemovalIds] stays in
  /// this list (struck through in the UI) until it's either undone or the
  /// change is submitted.
  final List<InterestPoint> interestPoints;
  final Set<String> _pendingRemovalIds = {};

  bool isPendingRemoval(String domainId) => _pendingRemovalIds.contains(domainId);

  void setStartDate(DateTime date) {
    startDate = date;
    notifyListeners();
  }

  void setEndDate(DateTime date) {
    endDate = date;
    notifyListeners();
  }

  void addInterestPoint(String name, String description) {
    interestPoints.add(InterestPoint(domainId: const Uuid().v4(), backEndId: null, name: name, description: description));
    notifyListeners();
  }

  void markForRemoval(String domainId) {
    _pendingRemovalIds.add(domainId);
    notifyListeners();
  }

  void undoRemoval(String domainId) {
    _pendingRemovalIds.remove(domainId);
    notifyListeners();
  }

  /// Every participant currently on the form — original ones plus any added
  /// this session. Same "stays visible, struck through, with undo" pattern
  /// as [interestPoints] above — never a destructive, hard-to-reverse
  /// delete on data that may already be saved.
  final List<Person> participants;
  final List<Person> _originalParticipants;
  final Set<String> _pendingParticipantRemovalIds = {};

  bool isClientParticipant(Person person) => person.name == clientName;
  bool isParticipantPendingRemoval(String domainId) => _pendingParticipantRemovalIds.contains(domainId);

  void addParticipant({required String name, required String age, required String sex}) {
    participants.add(Person(domainId: const Uuid().v4(), backEndId: null, name: name, age: age, sex: sex));
    notifyListeners();
  }

  /// No-op for the client's own entry — the UI never offers a way to
  /// trigger this for it, but guarding here too keeps the invariant
  /// enforced at the controller, not just the view.
  void markParticipantForRemoval(String domainId) {
    final person = participants.firstWhere((p) => p.domainId == domainId);
    if (isClientParticipant(person)) return;
    _pendingParticipantRemovalIds.add(domainId);
    notifyListeners();
  }

  void undoParticipantRemoval(String domainId) {
    _pendingParticipantRemovalIds.remove(domainId);
    notifyListeners();
  }

  void updateParticipant(String domainId, {String? name, String? age, String? sex}) {
    final index = participants.indexWhere((p) => p.domainId == domainId);
    if (index == -1) return;
    final current = participants[index];
    participants[index] = Person(
      domainId: current.domainId,
      backEndId: current.backEndId,
      name: name ?? current.name,
      age: age ?? current.age,
      sex: sex ?? current.sex,
    );
    notifyListeners();
  }

  int get participantsAddedCount =>
      participants.where((p) => p.backEndId == null && !_pendingParticipantRemovalIds.contains(p.domainId)).length;

  int get participantsRemovedCount =>
      _pendingParticipantRemovalIds.where((id) => _originalParticipants.any((p) => p.domainId == id)).length;

  /// True when a surviving (not pending-removal) participant's fields
  /// differ from what was originally loaded — covers in-place edits that
  /// [participantsAddedCount]/[participantsRemovedCount] don't.
  bool get participantFieldsEdited {
    for (final person in participants) {
      if (_pendingParticipantRemovalIds.contains(person.domainId)) continue;
      Person? original;
      for (final candidate in _originalParticipants) {
        if (candidate.domainId == person.domainId) {
          original = candidate;
          break;
        }
      }
      if (original == null) continue; // added this session, already counted
      if (original.name != person.name || original.age != person.age || original.sex != person.sex) return true;
    }
    return false;
  }

  bool get participantsChanged => participantsAddedCount > 0 || participantsRemovedCount > 0 || participantFieldsEdited;

  /// The participants that would actually be submitted — added ones kept,
  /// pending-removal ones dropped.
  List<Person> get _submittedParticipants =>
      participants.where((p) => !_pendingParticipantRemovalIds.contains(p.domainId)).toList();

  bool get startDateChanged => startDate != original.startDate;
  bool get endDateChanged => endDate != original.endDate;
  bool get startLocationChanged => startLocationController.text.trim() != original.startLocation;
  bool get destinationChanged => destinationController.text.trim() != original.destination;

  /// Points added this session and not since undone-by-removal — an added
  /// point that gets marked for removal again before submitting cancels out
  /// to no change at all, rather than counting as both an add and a remove.
  int get interestsAddedCount =>
      interestPoints.where((p) => p.backEndId == null && !_pendingRemovalIds.contains(p.domainId)).length;

  /// Pending removals of points that exist on the saved route — removing a
  /// point added this same session isn't a "removal" relative to what's
  /// saved, so it's excluded here too (see [interestsAddedCount]).
  int get interestsRemovedCount =>
      _pendingRemovalIds.where((id) => original.interestsList.any((p) => p.domainId == id)).length;

  bool get _routeChanged =>
      startDateChanged ||
      endDateChanged ||
      startLocationChanged ||
      destinationChanged ||
      interestsAddedCount > 0 ||
      interestsRemovedCount > 0;

  bool get hasChanges => _routeChanged || participantsChanged;

  /// The interest points that would actually be submitted — added ones kept,
  /// pending-removal ones dropped. Used both for the request body and for
  /// [interestsAddedCount] logic elsewhere.
  List<InterestPoint> get _submittedInterestPoints =>
      interestPoints.where((p) => !_pendingRemovalIds.contains(p.domainId)).toList();

  /// Submits only what actually changed — route and participants are
  /// isolated endpoints, so an unchanged one is never called just because
  /// the other one was edited.
  Future<void> submit() async {
    if (!hasChanges || _state.isSubmitting) return;

    _state = _state.copyWith(isSubmitting: true, submitErrorMessage: null);
    notifyListeners();

    if (_routeChanged) {
      final updated = RoutePlan(
        domainId: original.domainId,
        backEndId: original.backEndId,
        startDate: startDate,
        endDate: endDate,
        startLocation: startLocationController.text.trim(),
        destination: destinationController.text.trim(),
        interestsList: _submittedInterestPoints,
      );

      final result = await _routeUseCases.updateRoute(travelId, updated);
      if (result case Failure<RoutePlan>(message: final message)) {
        _state = _state.copyWith(isSubmitting: false, submitErrorMessage: message);
        notifyListeners();
        return;
      }
    }

    if (participantsChanged) {
      final result = await _participantsUseCases.updateParticipants(travelId, _submittedParticipants);
      if (result case Failure<List<Person>>(message: final message)) {
        _state = _state.copyWith(isSubmitting: false, submitErrorMessage: message);
        notifyListeners();
        return;
      }
    }

    _state = _state.copyWith(isSubmitting: false, isSuccess: true);
    notifyListeners();
  }

  @override
  void dispose() {
    startLocationController.dispose();
    destinationController.dispose();
    super.dispose();
  }
}

/// A short "d MMM" date, e.g. "19 out" — [formatDate] always includes the
/// year, too long for an inline diff line like "volta 19 out → 21 out".
String _shortDate(String languageCode, DateTime date) => '${date.day} ${monthAbbreviation(languageCode, date.month)}';

/// Human-readable list of pending changes, e.g. `["volta 19 out → 21 out",
/// "1 interesse removido"]` — joined with " · " for display. Empty when
/// [EditRouteController.hasChanges] is false.
List<String> editRouteChangeDescriptions(EditRouteController controller, AppLocalizations l10n, String languageCode) {
  final descriptions = <String>[];

  if (controller.startDateChanged) {
    descriptions.add(l10n.editRouteDiffDeparture(
      _shortDate(languageCode, controller.original.startDate),
      _shortDate(languageCode, controller.startDate),
    ));
  }
  if (controller.endDateChanged) {
    descriptions.add(l10n.editRouteDiffReturn(
      _shortDate(languageCode, controller.original.endDate),
      _shortDate(languageCode, controller.endDate),
    ));
  }
  if (controller.startLocationChanged) {
    descriptions.add(l10n.editRouteDiffOrigin(controller.original.startLocation, controller.startLocationController.text.trim()));
  }
  if (controller.destinationChanged) {
    descriptions.add(l10n.editRouteDiffDestination(controller.original.destination, controller.destinationController.text.trim()));
  }
  if (controller.interestsAddedCount > 0) {
    descriptions.add(l10n.editRouteDiffInterestsAdded(controller.interestsAddedCount));
  }
  if (controller.interestsRemovedCount > 0) {
    descriptions.add(l10n.editRouteDiffInterestsRemoved(controller.interestsRemovedCount));
  }
  if (controller.participantsAddedCount > 0) {
    descriptions.add(l10n.editRouteDiffParticipantsAdded(controller.participantsAddedCount));
  }
  if (controller.participantsRemovedCount > 0) {
    descriptions.add(l10n.editRouteDiffParticipantsRemoved(controller.participantsRemovedCount));
  }
  if (controller.participantFieldsEdited) {
    descriptions.add(l10n.editRouteDiffParticipantsUpdated);
  }

  return descriptions;
}
