import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/core/entities/result.dart';
import 'package:routecraft_app/features/account/domain/entities/client_profile.dart';
import 'package:routecraft_app/features/account/domain/repositories/client_profile_repository.dart';
import 'package:routecraft_app/features/account/domain/usecases/client_profile_usecases.dart';
import 'package:routecraft_app/features/account/presentation/controllers/personal_data_controller.dart';
import 'package:routecraft_app/features/account/presentation/pages/personal_data_page.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

class _FakeClientProfileRepository implements ClientProfileRepository {
  Result<ClientProfile>? nextGetResult;
  Result<ClientProfile>? nextUpdateResult;
  Result<void>? nextResetPasswordResult;
  ClientProfile? lastUpdateRequest;
  int resetPasswordCallCount = 0;

  @override
  Future<Result<ClientProfile>> getCurrentUser() async => nextGetResult!;

  @override
  Future<Result<ClientProfile>> updateUser(ClientProfile profile) async {
    lastUpdateRequest = profile;
    return nextUpdateResult!;
  }

  @override
  Future<Result<void>> resetPassword(String id) async {
    resetPasswordCallCount++;
    return nextResetPasswordResult!;
  }
}

const _profile = ClientProfile(
  id: '1',
  name: 'Maria Cliente',
  cpf: '12345678900',
  phoneNumber: '11999998888',
  email: 'maria@email.com',
  age: 30,
  sex: 'F',
);

Widget _wrap(PersonalDataController controller) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: PersonalDataPage(controller: controller),
  );
}

void main() {
  testWidgets('shows a loading spinner while fetching', (tester) async {
    await tester.pumpWidget(_wrap(PersonalDataController.withState(const PersonalDataState())));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('shows the fetched profile: editable fields populated, CPF/e-mail read-only', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(
      PersonalDataController.withState(const PersonalDataState(isLoading: false, profile: _profile)),
    ));

    expect(find.text('Maria Cliente'), findsOneWidget);
    expect(find.text('11999998888'), findsOneWidget);
    expect(find.text('30'), findsOneWidget);
    expect(find.text('12345678900'), findsOneWidget);
    expect(find.text('maria@email.com'), findsOneWidget);

    // CPF/e-mail are read-only display, not editable fields.
    expect(find.byKey(const Key('personalDataNameField')), findsOneWidget);
    expect(find.widgetWithText(TextFormField, '12345678900'), findsNothing);
  });

  testWidgets('renders without crashing for a client whose gender is "O" (agent-set, not just M/F)', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_wrap(
      PersonalDataController.withState(
        const PersonalDataState(isLoading: false, profile: ClientProfile(
          id: '1',
          name: 'Alex Cliente',
          cpf: '12345678900',
          phoneNumber: '11999998888',
          email: 'alex@email.com',
          age: 30,
          sex: 'O',
        )),
      ),
    ));

    expect(tester.takeException(), isNull);
    expect(find.text('Other'), findsOneWidget);
  });

  testWidgets('saving sends the edited fields via PUT and shows a success message', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repository = _FakeClientProfileRepository()
      ..nextGetResult = const Result.success(_profile)
      ..nextUpdateResult = const Result.success(
        ClientProfile(
          id: '1',
          name: 'Maria Souza',
          cpf: '12345678900',
          phoneNumber: '11888887777',
          email: 'maria@email.com',
          age: 31,
          sex: 'F',
        ),
      );
    final controller = PersonalDataController(useCases: ClientProfileUseCases(repository));

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('personalDataNameField')), 'Maria Souza');
    await tester.enterText(find.byKey(const Key('personalDataPhoneField')), '11888887777');
    await tester.enterText(find.byKey(const Key('personalDataAgeField')), '31');

    await tester.tap(find.byKey(const Key('personalDataSaveButton')));
    await tester.pumpAndSettle();

    expect(repository.lastUpdateRequest?.name, 'Maria Souza');
    expect(repository.lastUpdateRequest?.phoneNumber, '11888887777');
    expect(repository.lastUpdateRequest?.age, 31);
    expect(find.text('Data saved successfully.'), findsOneWidget);
  });

  testWidgets('reset password: cancelling the confirmation does not call the backend', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repository = _FakeClientProfileRepository()..nextGetResult = const Result.success(_profile);
    final controller = PersonalDataController(useCases: ClientProfileUseCases(repository));

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('personalDataResetPasswordButton')));
    await tester.pumpAndSettle();

    expect(find.text('Reset password?'), findsOneWidget);

    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();

    expect(repository.resetPasswordCallCount, 0);
    expect(find.text('Reset password?'), findsNothing);
  });

  testWidgets('reset password: confirming calls the backend and shows a success message', (tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final repository = _FakeClientProfileRepository()
      ..nextGetResult = const Result.success(_profile)
      ..nextResetPasswordResult = const Result.success(null);
    final controller = PersonalDataController(useCases: ClientProfileUseCases(repository));

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('personalDataResetPasswordButton')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Reset password').last);
    await tester.pumpAndSettle();

    expect(find.text('Password reset successfully.'), findsOneWidget);
  });
}
