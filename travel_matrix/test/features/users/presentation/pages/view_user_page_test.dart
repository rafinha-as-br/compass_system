import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/app_injector.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:travel_matrix/features/users/domain/user_crud_use_cases.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/pages/view_user_page.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_status_view_model.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_view_model.dart';
import 'package:travel_matrix/features/users/presentation/view_models/user_stats_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockUserUseCases extends Mock implements UserUseCases {}

final _testUser = UserClientViewModel(
  backEndId: '1',
  localId: '1',
  name: 'Jane Doe',
  cpf: '000.000.000-00',
  sex: 'F',
  phoneNumber: '11999999999',
  status: const UserClientStatusViewModel(
    status: ActiveStatusViewModel(),
    lastLogin: null,
  ),
  email: 'jane@example.com',
  travels: const [],
  stats: UserStatsViewModel(totalTravels: '0', uniqueDestinationsCount: '0'),
);

Widget _wrap(UsersController controller) {
  return ChangeNotifierProvider.value(
    value: controller,
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: ViewUserPage(user: _testUser),
    ),
  );
}

void main() {
  late _MockUserUseCases useCases;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await AppInjector.init();
    useCases = _MockUserUseCases();
    when(() => useCases.getAllUsers())
        .thenAnswer((_) async => const Result.success(<UserClient>[]));
  });

  testWidgets('force logout requires confirmation before terminating sessions', (tester) async {
    when(() => useCases.forceLogout(any()))
        .thenAnswer((_) async => const Result.success());
    final controller = UsersController(useCases: useCases);

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Force Logout'));
    await tester.tap(find.text('Force Logout'));
    await tester.pumpAndSettle();

    expect(find.text('Force Logout?'), findsOneWidget);
    verifyNever(() => useCases.forceLogout(any()));

    await tester.tap(find.text('CONFIRM'));
    await tester.pumpAndSettle();

    verify(() => useCases.forceLogout('1')).called(1);
    expect(find.text('User sessions terminated'), findsOneWidget);
  });

  testWidgets('cancelling the confirmation dialog does not call forceLogout', (tester) async {
    when(() => useCases.forceLogout(any()))
        .thenAnswer((_) async => const Result.success());
    final controller = UsersController(useCases: useCases);

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Force Logout'));
    await tester.tap(find.text('Force Logout'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    verifyNever(() => useCases.forceLogout(any()));
  });
}
