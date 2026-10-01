import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/domain/entities/person.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_participants.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_route.dart';
import 'package:travel_matrix/features/travels/domain/usecases/crud_travel.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/participants_view_tab.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockCrudTravelUseCases extends Mock implements CrudTravelUseCases {}

class _MockCrudRoute extends Mock implements CrudRoute {}

class _MockCrudParticipants extends Mock implements CrudParticipants {}

Travel _travel({List<Person> participants = const []}) => Travel(
  domainId: 't1',
  backEndId: 't1',
  clientName: 'Maria Silva',
  travelName: 'Lisbon 2026',
  travelStatus: TravelStatus.routeCreated,
  participantsList: participants,
  routePlan: RoutePlan(
    domainId: 'r1',
    backEndId: 'r1',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 1, 11),
    startLocation: 'Sao Paulo',
    destination: 'Lisbon',
    interestsList: const [],
  ),
);

void main() {
  late _MockCrudTravelUseCases travelUseCases;
  late _MockCrudRoute routeUseCases;
  late _MockCrudParticipants participantsUseCases;
  late TravelsController controller;

  setUpAll(() {
    registerFallbackValue(<Person>[]);
  });

  setUp(() {
    travelUseCases = _MockCrudTravelUseCases();
    routeUseCases = _MockCrudRoute();
    participantsUseCases = _MockCrudParticipants();
    when(() => travelUseCases.readAll()).thenAnswer((_) async => const Result.success([]));
    controller = TravelsController(
      travelUseCases: travelUseCases,
      routeUseCases: routeUseCases,
      participantsUseCases: participantsUseCases,
    );
  });

  Future<TravelViewModel> pump(WidgetTester tester, Travel travel, {ValueChanged<TravelViewModel>? onTravelUpdated}) async {
    final viewModel = TravelViewModel.fromDomain(travel);
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: controller,
        child: MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: ParticipantsViewTab(travel: viewModel, onTravelUpdated: onTravelUpdated)),
        ),
      ),
    );
    await tester.pumpAndSettle();
    return viewModel;
  }

  testWidgets('shows the empty state with an "Add participant" action when there are no participants', (tester) async {
    await pump(tester, _travel());

    expect(find.text('No participants yet'), findsOneWidget);
    expect(find.text('Add participant'), findsWidgets);
  });

  testWidgets('lists existing participants with name and age/sex subtitle', (tester) async {
    await pump(
      tester,
      _travel(
        participants: [Person(domainId: 'p1', backendId: 'p1', name: 'Ana Silva', age: '30', sex: 'F')],
      ),
    );

    expect(find.text('Ana Silva'), findsOneWidget);
    expect(find.textContaining('30 years old'), findsOneWidget);
    expect(find.textContaining('Female'), findsOneWidget);
  });

  testWidgets('adding a participant fills the form, submits and calls onTravelUpdated with the merged list', (tester) async {
    TravelViewModel? updatedTravel;
    when(() => participantsUseCases.updateParticipants('t1', any())).thenAnswer(
      (invocation) async => Result.success(invocation.positionalArguments[1] as List<Person>),
    );

    await pump(tester, _travel(), onTravelUpdated: (t) => updatedTravel = t);

    await tester.tap(find.byKey(const Key('participants_add_button')));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Bruno Costa');
    await tester.enterText(find.widgetWithText(TextField, 'Age'), '28');
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('participants_add_dialog_submit')));
    await tester.pumpAndSettle();

    verify(() => participantsUseCases.updateParticipants('t1', any())).called(1);
    expect(updatedTravel, isNotNull);
    expect(updatedTravel!.participants, hasLength(1));
    expect(updatedTravel!.participants.single.name, 'Bruno Costa');
  });

  testWidgets('the "Add participant" submit button stays disabled until a name is entered', (tester) async {
    await pump(tester, _travel());

    await tester.tap(find.byKey(const Key('participants_add_button')));
    await tester.pumpAndSettle();

    final submitButton = tester.widget<ElevatedButton>(find.byKey(const Key('participants_add_dialog_submit')));
    expect(submitButton.onPressed, isNull);
  });

  testWidgets('removing a participant asks for confirmation, then submits and calls onTravelUpdated', (tester) async {
    TravelViewModel? updatedTravel;
    final ana = Person(domainId: 'p1', backendId: 'p1', name: 'Ana Silva', age: '30', sex: 'F');
    when(() => participantsUseCases.updateParticipants('t1', any())).thenAnswer((_) async => const Result.success([]));

    await pump(tester, _travel(participants: [ana]), onTravelUpdated: (t) => updatedTravel = t);

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    expect(find.text('Remove Ana Silva from this travel?'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Delete'));
    await tester.pumpAndSettle();

    final sent = verify(() => participantsUseCases.updateParticipants('t1', captureAny())).captured.single as List<Person>;
    expect(sent, isEmpty);
    expect(updatedTravel, isNotNull);
    expect(updatedTravel!.participants, isEmpty);
  });

  testWidgets('cancelling the remove confirmation does not submit anything', (tester) async {
    final ana = Person(domainId: 'p1', backendId: 'p1', name: 'Ana Silva', age: '30', sex: 'F');
    await pump(tester, _travel(participants: [ana]));

    await tester.tap(find.byIcon(Icons.delete_outline));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(TextButton, 'Cancel'));
    await tester.pumpAndSettle();

    verifyNever(() => participantsUseCases.updateParticipants(any(), any()));
    expect(find.text('Ana Silva'), findsOneWidget);
  });

  testWidgets('shows a generic error SnackBar when the mutation fails, without the raw backend message', (tester) async {
    when(() => participantsUseCases.updateParticipants('t1', any()))
        .thenAnswer((_) async => const Result.failure('SQLException: constraint violation at row 42'));

    await pump(tester, _travel());

    await tester.tap(find.byKey(const Key('participants_add_button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Bruno Costa');
    await tester.pumpAndSettle(); // rebuild the dialog so the submit button becomes enabled
    await tester.tap(find.byKey(const Key('participants_add_dialog_submit')));
    // Not pumpAndSettle from here: a SnackBar has its own auto-dismiss
    // timer, and settling would pump straight through its whole visible
    // duration, leaving nothing to find. Zero-duration pumps drain the
    // multi-hop async chain (controller await -> notifyListeners ->
    // ScaffoldMessenger.showSnackBar) without advancing the fake clock,
    // then one timed pump lets the SnackBar's entrance animation start.
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Could not update participants. Please try again.'), findsOneWidget);
    expect(find.textContaining('SQLException'), findsNothing);
  });

  testWidgets('tapping "Try again" on the error SnackBar resubmits the same mutation', (tester) async {
    TravelViewModel? updatedTravel;
    var callCount = 0;
    when(() => participantsUseCases.updateParticipants('t1', any())).thenAnswer((invocation) async {
      callCount++;
      if (callCount == 1) return const Result.failure('boom');
      return Result.success(invocation.positionalArguments[1] as List<Person>);
    });

    await pump(tester, _travel(), onTravelUpdated: (t) => updatedTravel = t);

    await tester.tap(find.byKey(const Key('participants_add_button')));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Bruno Costa');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('participants_add_dialog_submit')));
    await tester.pump();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Could not update participants. Please try again.'), findsOneWidget);
    expect(updatedTravel, isNull);

    await tester.tap(find.text('Try again'));
    await tester.pump();
    await tester.pump();

    expect(callCount, 2);
    expect(updatedTravel, isNotNull);
    expect(updatedTravel!.participants.single.name, 'Bruno Costa');
  });
}
