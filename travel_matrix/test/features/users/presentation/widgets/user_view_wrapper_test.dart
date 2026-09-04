import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/core/services/auth_storage_service.dart';
import 'package:travel_matrix/features/users/domain/entities/user.dart';
import 'package:travel_matrix/features/users/domain/entities/user_status.dart';
import 'package:travel_matrix/features/users/domain/entities/user_stats.dart';
import 'package:travel_matrix/features/users/domain/user_crud_use_cases.dart';
import 'package:travel_matrix/features/users/presentation/controllers/users_controller.dart';
import 'package:travel_matrix/features/users/presentation/view_models/client_view_model.dart';
import 'package:travel_matrix/features/users/presentation/widgets/user_view_wrapper.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockUserUseCases extends Mock implements UserUseCases {}

UserClient _buildUser({required String phoneNumber}) {
  return UserClient(
    backEndId: '1',
    domainId: '1',
    name: 'Jane Doe',
    cpf: '000.000.000-00',
    sex: 'F',
    phoneNumber: phoneNumber,
    status: UserClientStatus(status: ActiveStatus(), lastLogin: null),
    email: 'jane@example.com',
    travels: const [],
    stats: UserStats(totalTravels: 0, uniqueDestinationsCount: 0),
  );
}

void main() {
  late _MockUserUseCases useCases;

  setUp(() async {
    SharedPreferences.setMockInitialValues({'auth_token': 'test-token'});
    await AuthStorageService.init();
    useCases = _MockUserUseCases();
  });

  testWidgets(
    'reflects the updated user after the shared controller refetches — not the pre-edit snapshot',
    (tester) async {
      final staleUser = _buildUser(phoneNumber: '11911111111');
      when(() => useCases.getAllUsers())
          .thenAnswer((_) async => Result.success([staleUser]));
      final controller = UsersController(useCases: useCases);

      // Mesma combinação que a navegação real passa na primeira visita à
      // ViewUserPage (via extra: {'user': ..., 'controller': ...}).
      final staleViewModel = UserClientViewModel.fromDomain(user: staleUser);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: UserViewWrapper(
            userId: '1',
            initialUser: staleViewModel,
            initialController: controller,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('11911111111'), findsOneWidget);

      // Simula o que UsersController.updateUser faz internamente após um
      // save com sucesso (refetch) — sem chamar pumpWidget de novo, para
      // reproduzir o cenário real: go_router reaproveita a MESMA instância
      // do UserViewWrapper ao voltar da tela de edição, sem remount.
      when(() => useCases.getAllUsers())
          .thenAnswer((_) async => Result.success([_buildUser(phoneNumber: '11922222222')]));
      await controller.fetchUsers();
      await tester.pump();

      expect(find.text('11922222222'), findsOneWidget);
      expect(find.text('11911111111'), findsNothing);
    },
  );
}
