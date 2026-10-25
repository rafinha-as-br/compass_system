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
import 'package:travel_matrix/shared/utils/participant_avatars.dart';
import 'package:travel_matrix/shared/widgets/avatar_picker.dart';
import 'package:travel_matrix/shared/widgets/participant_avatar.dart';

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

  group('participant character', () {
    Future<void> openDialogAndTypeName(WidgetTester tester) async {
      await tester.tap(find.byKey(const Key('participants_add_button')));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Name'), 'Bruno Costa');
      await tester.pumpAndSettle();
    }

    Future<List<Person>> submitAndCapture(WidgetTester tester) async {
      await tester.ensureVisible(find.byKey(const Key('participants_add_dialog_submit')));
      await tester.tap(find.byKey(const Key('participants_add_dialog_submit')));
      await tester.pumpAndSettle();
      return verify(() => participantsUseCases.updateParticipants('t1', captureAny())).captured.single as List<Person>;
    }

    setUp(() {
      when(() => participantsUseCases.updateParticipants('t1', any())).thenAnswer(
        (invocation) async => Result.success(invocation.positionalArguments[1] as List<Person>),
      );
    });

    testWidgets('a random character comes pre-selected and is saved when the user does not pick one', (tester) async {
      await pump(tester, _travel());
      await openDialogAndTypeName(tester);

      expect(find.textContaining('randomly picked, tap to change'), findsOneWidget);
      expect(find.byType(AvatarPicker), findsOneWidget);

      final saved = await submitAndCapture(tester);
      expect(isKnownParticipantAvatar(saved.single.avatarIndex), isTrue);
    });

    testWidgets('picking another character saves the picked index and drops the "randomly picked" hint', (tester) async {
      await pump(tester, _travel());
      await openDialogAndTypeName(tester);

      await tester.ensureVisible(find.byKey(const Key('avatar_picker_option_4')));
      await tester.tap(find.byKey(const Key('avatar_picker_option_4')));
      await tester.pumpAndSettle();

      expect(find.textContaining('randomly picked'), findsNothing);

      final saved = await submitAndCapture(tester);
      expect(saved.single.avatarIndex, 4);
    });

    testWidgets('tapping a participant avatar lets the user pick a character, saved without touching the others', (tester) async {
      TravelViewModel? updatedTravel;
      final viewModel = await pump(
        tester,
        _travel(
          participants: [
            Person(domainId: 'a', backendId: 'a', name: 'Ana Silva', age: '30', sex: 'F'),
            Person(domainId: 'b', backendId: 'b', name: 'Bruno Costa', age: '28', sex: 'M', avatarIndex: 2),
          ],
        ),
        onTravelUpdated: (t) => updatedTravel = t,
      );

      await tester.tap(find.byKey(Key('participant_avatar_button_${viewModel.participants.first.id}')));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.byKey(const Key('avatar_picker_option_5')));
      await tester.tap(find.byKey(const Key('avatar_picker_option_5')));
      await tester.pumpAndSettle();

      final saved = verify(() => participantsUseCases.updateParticipants('t1', captureAny())).captured.single as List<Person>;
      expect(saved.map((p) => p.avatarIndex), [5, 2]);
      expect(saved.map((p) => p.name), ['Ana Silva', 'Bruno Costa']);
      expect(updatedTravel!.participants.map((p) => p.avatarIndex), [5, 2]);
    });

    testWidgets('dismissing the character dialog saves nothing', (tester) async {
      final viewModel = await pump(
        tester,
        _travel(participants: [Person(domainId: 'a', backendId: 'a', name: 'Ana Silva', age: '30', sex: 'F')]),
      );

      await tester.tap(find.byKey(Key('participant_avatar_button_${viewModel.participants.first.id}')));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5)); // barrier
      await tester.pumpAndSettle();

      verifyNever(() => participantsUseCases.updateParticipants(any(), any()));
    });

    testWidgets('the list shows the character for participants with an index and initials for those without', (tester) async {
      await pump(
        tester,
        _travel(
          participants: [
            Person(domainId: 'a', backendId: 'a', name: 'Ana Silva', age: '30', sex: 'F', avatarIndex: 2),
            Person(domainId: 'b', backendId: 'b', name: 'Bruno Costa', age: '28', sex: 'M'),
          ],
        ),
      );

      final avatars = tester.widgetList<ParticipantAvatar>(find.byType(ParticipantAvatar)).toList();
      expect(avatars.map((a) => a.avatarIndex), [2, null]);
      expect(find.text('BC'), findsOneWidget);
      expect(find.text('AS'), findsNothing);
    });
  });

  group('participant note', () {
    Future<List<Person>> saveNoteOf(WidgetTester tester, String id, String text) async {
      await tester.enterText(find.byKey(Key('participant_note_field_$id')), text);
      await tester.tap(find.byKey(Key('participant_note_save_$id')));
      await tester.pumpAndSettle();
      return verify(() => participantsUseCases.updateParticipants('t1', captureAny())).captured.single as List<Person>;
    }

    setUp(() {
      when(() => participantsUseCases.updateParticipants('t1', any())).thenAnswer(
        (invocation) async => Result.success(invocation.positionalArguments[1] as List<Person>),
      );
    });

    testWidgets('shows the note when there is one and an "Add note" action when there is not', (tester) async {
      await pump(
        tester,
        _travel(
          participants: [
            Person(domainId: 'a', backendId: 'a', name: 'Ana Silva', age: '30', sex: 'F', note: 'Intolerância a lactose'),
            Person(domainId: 'b', backendId: 'b', name: 'Bruno Costa', age: '28', sex: 'M'),
          ],
        ),
      );

      expect(find.text('Intolerância a lactose'), findsOneWidget);
      expect(find.byKey(const Key('participant_note_add_a')), findsNothing);
      expect(find.byKey(const Key('participant_note_add_b')), findsOneWidget);
      expect(find.text('+ Add note'), findsOneWidget);
    });

    testWidgets('adds a note to a participant, saving it without touching the others', (tester) async {
      TravelViewModel? updatedTravel;
      await pump(
        tester,
        _travel(
          participants: [
            Person(domainId: 'a', backendId: 'a', name: 'Ana Silva', age: '30', sex: 'F', note: 'Vegetariana'),
            Person(domainId: 'b', backendId: 'b', name: 'Bruno Costa', age: '28', sex: 'M', avatarIndex: 2),
          ],
        ),
        onTravelUpdated: (t) => updatedTravel = t,
      );

      await tester.tap(find.byKey(const Key('participant_note_add_b')));
      await tester.pumpAndSettle();
      final saved = await saveNoteOf(tester, 'b', '  Mobilidade reduzida  ');

      expect(saved.map((p) => p.note), ['Vegetariana', 'Mobilidade reduzida']);
      expect(saved.map((p) => p.avatarIndex), [null, 2]);
      expect(updatedTravel!.participants.map((p) => p.note), ['Vegetariana', 'Mobilidade reduzida']);
      // Back to the read state once saved.
      expect(find.byKey(const Key('participant_note_field_b')), findsNothing);
    });

    testWidgets('editing starts from the current note and a blank save clears it', (tester) async {
      await pump(
        tester,
        _travel(participants: [Person(domainId: 'a', backendId: 'a', name: 'Ana Silva', age: '30', sex: 'F', note: 'Vegetariana')]),
      );

      await tester.tap(find.byKey(const Key('participant_note_view_a')));
      await tester.pumpAndSettle();
      expect(tester.widget<TextField>(find.byKey(const Key('participant_note_field_a'))).controller!.text, 'Vegetariana');

      final saved = await saveNoteOf(tester, 'a', '   ');
      expect(saved.single.note, isNull);
    });

    testWidgets('cancelling the edit saves nothing and keeps the note', (tester) async {
      await pump(
        tester,
        _travel(participants: [Person(domainId: 'a', backendId: 'a', name: 'Ana Silva', age: '30', sex: 'F', note: 'Vegetariana')]),
      );

      await tester.tap(find.byKey(const Key('participant_note_view_a')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('participant_note_field_a')), 'Outra coisa');
      await tester.tap(find.byKey(const Key('participant_note_cancel_a')));
      await tester.pumpAndSettle();

      verifyNever(() => participantsUseCases.updateParticipants(any(), any()));
      expect(find.text('Vegetariana'), findsOneWidget);
      expect(find.byKey(const Key('participant_note_field_a')), findsNothing);
    });

    testWidgets('a failed save keeps the field open with the typed text', (tester) async {
      when(() => participantsUseCases.updateParticipants('t1', any())).thenAnswer((_) async => const Result.failure('x'));
      await pump(tester, _travel(participants: [Person(domainId: 'a', backendId: 'a', name: 'Ana Silva', age: '30', sex: 'F')]));

      await tester.tap(find.byKey(const Key('participant_note_add_a')));
      await tester.pumpAndSettle();
      await tester.enterText(find.byKey(const Key('participant_note_field_a')), 'Alérgica a amendoim');
      await tester.tap(find.byKey(const Key('participant_note_save_a')));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('participant_note_field_a')), findsOneWidget);
      expect(tester.widget<TextField>(find.byKey(const Key('participant_note_field_a'))).controller!.text, 'Alérgica a amendoim');
      expect(find.text('Try again'), findsOneWidget);
    });
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
