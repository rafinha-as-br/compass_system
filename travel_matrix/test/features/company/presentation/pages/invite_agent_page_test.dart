import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/company/domain/company_use_cases.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/company_agent.dart';
import 'package:travel_matrix/features/company/domain/entities/invited_agent.dart';
import 'package:travel_matrix/features/company/presentation/controllers/invite_agent_controller.dart';
import 'package:travel_matrix/features/company/presentation/pages/invite_agent_page.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockCompanyUseCases extends Mock implements CompanyUseCases {}

const _invited = InvitedAgent(
  agent: CompanyAgent(
    id: '12',
    name: 'Ana Paula Ribeiro',
    login: 'ana.paula.ribeiro2@aurora.com.br',
    role: AgentRole.member,
  ),
  temporaryPassword: 'Xy7kQ2pL9m',
);

Widget _wrap(InviteAgentController controller) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: InviteAgentPage(controller: controller),
  );
}

void main() {
  late _MockCompanyUseCases useCases;
  late InviteAgentController controller;

  setUp(() {
    useCases = _MockCompanyUseCases();
    controller = InviteAgentController(domain: 'aurora.com.br', useCases: useCases);
  });

  testWidgets('typing the name updates the read-only login preview', (tester) async {
    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    expect(find.text('Login that will be generated'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'Ana Paula Ribeiro');
    await tester.pump();

    expect(find.textContaining('ana.paula.ribeiro'), findsOneWidget);
    expect(find.textContaining('@aurora.com.br'), findsOneWidget);
  });

  testWidgets('submitting with an empty name shows validation and does not call the API', (tester) async {
    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();

    final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
    expect(button.onPressed, isNull);
    verifyNever(() => useCases.inviteAgent(any()));
  });

  testWidgets('success replaces the form with the one-time credentials', (tester) async {
    when(() => useCases.inviteAgent('Ana Paula Ribeiro'))
        .thenAnswer((_) async => const Result.success(_invited));

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Ana Paula Ribeiro');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Agent created'), findsOneWidget);
    expect(find.text('ana.paula.ribeiro2@aurora.com.br'), findsOneWidget);
    expect(find.text('Xy7kQ2pL9m'), findsOneWidget);
    expect(find.text('Copy credentials'), findsOneWidget);
    expect(find.text('Back to Panel'), findsOneWidget);
    expect(find.byType(TextFormField), findsNothing);
  });

  testWidgets('failure keeps the form and shows the backend message', (tester) async {
    when(() => useCases.inviteAgent('Ana'))
        .thenAnswer((_) async => const Result.failure('Apenas agentes OWNER podem gerenciar os agentes da empresa.'));

    await tester.pumpWidget(_wrap(controller));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField), 'Ana');
    await tester.pump();
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    expect(find.text('Apenas agentes OWNER podem gerenciar os agentes da empresa.'), findsOneWidget);
    expect(find.byType(TextFormField), findsOneWidget);
    expect(find.text('Agent created'), findsNothing);
  });
}
