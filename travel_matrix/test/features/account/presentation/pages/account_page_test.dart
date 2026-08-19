import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/app/global_controllers/settings_controller.dart';
import 'package:travel_matrix/features/account/domain/entities/agent_profile.dart';
import 'package:travel_matrix/features/account/domain/get_agent_profile.dart';
import 'package:travel_matrix/features/account/presentation/controllers/account_controller.dart';
import 'package:travel_matrix/features/account/presentation/pages/account_page.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockGetAgentProfile extends Mock implements GetAgentProfile {}

const _profile = AgentProfile(
  id: '1',
  name: 'Agent Smith',
  email: 'agent@matrix.com',
  cpf: '000.000.000-00',
  cnpj: '00.000.000/0000-00',
  phoneNumber: '11999999999',
);

Widget _wrap(AccountController controller) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => SettingsController()),
      ChangeNotifierProvider(create: (_) => AuthController()),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      home: AccountPage(controller: controller),
    ),
  );
}

void main() {
  late _MockGetAgentProfile getAgentProfile;

  setUp(() {
    getAgentProfile = _MockGetAgentProfile();
  });

  testWidgets('shows the profile once loading succeeds', (tester) async {
    when(() => getAgentProfile()).thenAnswer((_) async => _profile);
    final controller = AccountController(getAgentProfile: getAgentProfile);

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('Agent Smith'), findsOneWidget);
    expect(find.text('agent@matrix.com'), findsWidgets);
  });

  testWidgets('shows a friendly error message on failure, never the raw exception', (tester) async {
    when(() => getAgentProfile()).thenThrow(StateError('Not authenticated.'));
    final controller = AccountController(getAgentProfile: getAgentProfile);

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(
      find.text('Unable to load your profile right now. Please try again later.'),
      findsOneWidget,
    );
    expect(find.textContaining('Not authenticated'), findsNothing);
    expect(find.textContaining('StateError'), findsNothing);
  });
}
