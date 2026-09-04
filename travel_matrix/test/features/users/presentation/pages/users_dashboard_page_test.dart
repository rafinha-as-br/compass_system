import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/app_injector.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:travel_matrix/features/users/domain/entities/user_status.dart';
import 'package:travel_matrix/features/users/domain/entities/user_stats.dart';
import 'package:travel_matrix/features/users/domain/user_crud_use_cases.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/pages/users_dashboard_page.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class _MockUserUseCases extends Mock implements UserUseCases {}

UserClient _buildUser() {
  return UserClient(
    backEndId: '1',
    domainId: '1',
    name: 'Jane Doe',
    cpf: '000.000.000-00',
    sex: 'F',
    phoneNumber: '11999999999',
    status: UserClientStatus(status: ActiveStatus(), lastLogin: null),
    email: 'jane@example.com',
    travels: const [],
    stats: UserStats(totalTravels: 0, uniqueDestinationsCount: 0),
  );
}

Widget _wrap(UsersController controller, {required ThemeMode themeMode}) {
  return MaterialApp(
    theme: AppTheme.lightTheme,
    darkTheme: AppTheme.darkTheme,
    themeMode: themeMode,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: UsersDashboardPage(controller: controller)),
  );
}

void main() {
  late _MockUserUseCases useCases;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'auth_token': 'test-token'});
    await AppInjector.init();
    await AuthStorageService.init();
    useCases = _MockUserUseCases();
    when(() => useCases.getAllUsers())
        .thenAnswer((_) async => Result.success([_buildUser()]));
  });

  testWidgets('active status icon follows the dark theme semantic color, not the fixed light token', (tester) async {
    final controller = UsersController(useCases: useCases);

    await tester.pumpWidget(_wrap(controller, themeMode: ThemeMode.dark));
    await tester.pumpAndSettle();

    final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle_outline));
    expect(icon.color, AppTheme.darkTheme.semanticColors.success);
    expect(icon.color, isNot(TravelAppColors.success));
  });

  testWidgets('active status icon uses the light theme semantic color in light mode', (tester) async {
    final controller = UsersController(useCases: useCases);

    await tester.pumpWidget(_wrap(controller, themeMode: ThemeMode.light));
    await tester.pumpAndSettle();

    final icon = tester.widget<Icon>(find.byIcon(Icons.check_circle_outline));
    expect(icon.color, AppTheme.lightTheme.semanticColors.success);
  });
}
