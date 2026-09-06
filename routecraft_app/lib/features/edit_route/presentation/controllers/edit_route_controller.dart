import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/travels/data/repositories/route_repository_impl.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
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
    RouteUseCases? routeUseCases,
  })  : interestPoints = [...original.interestsList],
        startDate = original.startDate,
        endDate = original.endDate,
        _routeUseCasesOverride = routeUseCases {
    startLocationController = TextEditingController(text: original.startLocation)..addListener(notifyListeners);
    destinationController = TextEditingController(text: original.destination)..addListener(notifyListeners);
  }

  final String travelId;
  final RoutePlan original;
  final bool showPublishedWarning;

  final RouteUseCases? _routeUseCasesOverride;
  RouteUseCases get _routeUseCases => _routeUseCasesOverride ?? RouteUseCases(RouteRepositoryImpl());

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

  bool get hasChanges =>
      startDateChanged ||
      endDateChanged ||
      startLocationChanged ||
      destinationChanged ||
      interestsAddedCount > 0 ||
      interestsRemovedCount > 0;

  /// The interest points that would actually be submitted — added ones kept,
  /// pending-removal ones dropped. Used both for the request body and for
  /// [interestsAddedCount] logic elsewhere.
  List<InterestPoint> get _submittedInterestPoints =>
      interestPoints.where((p) => !_pendingRemovalIds.contains(p.domainId)).toList();

  Future<void> submit() async {
    if (!hasChanges || _state.isSubmitting) return;

    _state = _state.copyWith(isSubmitting: true, submitErrorMessage: null);
    notifyListeners();

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
    switch (result) {
      case Success<RoutePlan>():
        _state = _state.copyWith(isSubmitting: false, isSuccess: true);
      case Failure<RoutePlan>(message: final message):
        _state = _state.copyWith(isSubmitting: false, submitErrorMessage: message);
    }
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

  return descriptions;
}
