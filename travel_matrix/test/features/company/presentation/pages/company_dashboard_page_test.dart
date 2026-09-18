import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/company/domain/company_use_cases.dart';
import 'package:travel_matrix/features/company/domain/entities/agent_role.dart';
import 'package:travel_matrix/features/company/domain/entities/company.dart';
import 'package:travel_matrix/features/company/domain/entities/company_agent.dart';
import 'package:travel_matrix/features/company/domain/entities/plan_type.dart';
import 'package:travel_matrix/features/company/presentation/controllers/company_dashboard_controller.dart';
import 'package:travel_matrix/features/company/presentation/pages/company_dashboard_page.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockCompanyUseCases extends Mock implements CompanyUseCases {}

Company _company({AgentRole role = AgentRole.owner}) => Company(
      id: '7',
      name: 'Aurora Viagens',
      cnpj: '12.345.678/0001-90',
      domain: 'aurora.com.br',
      plan: PlanType.pro,
      currentAgentId: '1',
      currentAgentRole: role,
    );

final _owner = CompanyAgent(
  id: '1',
  name: 'Carla Owner',
  login: 'carla.owner@aurora.com.br',
  role: AgentRole.owner,
  memberSince: DateTime.utc(2026, 9, 18, 12),
);

const _member = CompanyAgent(
  id: '2',
  name: 'Bruno Member',
  login: 'bruno.member@aurora.com.br',
  role: AgentRole.member,
);

/// Acima de 900px a tabela mostra a coluna LOGIN GERADO; o viewport padrão do
/// flutter_test (800x600) cai no modo compacto, que a suprime.
Future<void> _useWideViewport(WidgetTester tester) async {
  tester.view.physicalSize = const Size(1400, 900);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget _wrap(CompanyDashboardController controller) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: CompanyDashboardPage(controller: controller)),
  );
}

void main() {
  setUpAll(() => registerFallbackValue(AgentRole.member));

  late _MockCompanyUseCases useCases;

  setUp(() {
    useCases = _MockCompanyUseCases();
    when(() => useCases.getMyCompany()).thenAnswer((_) async => Result.success(_company()));
    when(() => useCases.getAgents()).thenAnswer((_) async => Result.success([_owner, _member]));
  });

  testWidgets('OWNER sees header, plan badge, agents list and the invite button', (tester) async {
    await _useWideViewport(tester);
    await tester.pumpWidget(_wrap(CompanyDashboardController(useCases: useCases)));
    await tester.pumpAndSettle();

    expect(find.text('Aurora Viagens'), findsOneWidget);
    expect(find.text('12.345.678/0001-90'), findsOneWidget);
    expect(find.text('PRO plan'), findsOneWidget);
    expect(find.text('Agents (2)'), findsOneWidget);
    expect(find.text('Carla Owner (you)'), findsOneWidget);
    expect(find.text('bruno.member@aurora.com.br'), findsOneWidget);
    expect(find.text('Invite Agent'), findsOneWidget);
  });

  testWidgets('compact width hides the generated login column', (tester) async {
    await tester.pumpWidget(_wrap(CompanyDashboardController(useCases: useCases)));
    await tester.pumpAndSettle();

    expect(find.text('Carla Owner (you)'), findsOneWidget);
    expect(find.text('bruno.member@aurora.com.br'), findsNothing);
  });

  testWidgets('MEMBER sees the list but no invite button', (tester) async {
    when(() => useCases.getMyCompany())
        .thenAnswer((_) async => Result.success(_company(role: AgentRole.member)));

    await tester.pumpWidget(_wrap(CompanyDashboardController(useCases: useCases)));
    await tester.pumpAndSettle();

    expect(find.text('Agents (2)'), findsOneWidget);
    expect(find.text('Invite Agent'), findsNothing);
  });

  testWidgets('shows a friendly error with retry on load failure', (tester) async {
    when(() => useCases.getMyCompany())
        .thenAnswer((_) async => const Result.failure('ApiException(404): x'));

    await tester.pumpWidget(_wrap(CompanyDashboardController(useCases: useCases)));
    await tester.pumpAndSettle();

    expect(find.text('Unable to load your company right now. Please try again later.'), findsOneWidget);
    expect(find.textContaining('ApiException'), findsNothing);
    expect(find.text('Try again'), findsOneWidget);
  });

  testWidgets('tapping a MEMBER row opens the dialog with OWNER actions enabled', (tester) async {
    await tester.pumpWidget(_wrap(CompanyDashboardController(useCases: useCases)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bruno Member'));
    await tester.pumpAndSettle();

    expect(find.text('Promote to OWNER'), findsOneWidget);
    expect(find.text('Remove from company'), findsOneWidget);
    final promote = tester.widget<OutlinedButton>(
      find.ancestor(of: find.text('Promote to OWNER'), matching: find.byType(OutlinedButton)),
    );
    expect(promote.onPressed, isNotNull);
  });

  testWidgets('the sole OWNER gets disabled actions and the fixed notice', (tester) async {
    await tester.pumpWidget(_wrap(CompanyDashboardController(useCases: useCases)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Carla Owner (you)'));
    await tester.pumpAndSettle();

    expect(find.text('You are the only OWNER of the company — promote another agent first.'), findsOneWidget);
    expect(find.text('IN THE COMPANY SINCE'), findsOneWidget);
    expect(find.text('18/09/2026'), findsOneWidget);
    final demote = tester.widget<OutlinedButton>(
      find.ancestor(of: find.text('Demote to MEMBER'), matching: find.byType(OutlinedButton)),
    );
    expect(demote.onPressed, isNull);
  });

  testWidgets('MEMBER opens the dialog without the actions block', (tester) async {
    when(() => useCases.getMyCompany())
        .thenAnswer((_) async => Result.success(_company(role: AgentRole.member)));

    await tester.pumpWidget(_wrap(CompanyDashboardController(useCases: useCases)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bruno Member'));
    await tester.pumpAndSettle();

    expect(find.text('Close'), findsWidgets);
    expect(find.text('Promote to OWNER'), findsNothing);
    expect(find.text('Remove from company'), findsNothing);
    // Sem memberSince o diálogo omite a linha, sem placeholder.
    expect(find.text('IN THE COMPANY SINCE'), findsNothing);
  });

  testWidgets('remove flow: dialog → confirmation → call → snackbar', (tester) async {
    when(() => useCases.removeAgent('2')).thenAnswer((_) async => const Result.success());

    await tester.pumpWidget(_wrap(CompanyDashboardController(useCases: useCases)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bruno Member'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Remove from company'));
    await tester.pumpAndSettle();

    expect(find.text('Remove Bruno Member?'), findsOneWidget);
    when(() => useCases.getAgents()).thenAnswer((_) async => Result.success([_owner]));
    await tester.tap(find.text('Remove'));
    await tester.pumpAndSettle();

    verify(() => useCases.removeAgent('2')).called(1);
    expect(find.text('Bruno Member was removed from the company.'), findsOneWidget);
    expect(find.text('Agents (1)'), findsOneWidget);
  });

  testWidgets('cancelling the confirmation does not call the API', (tester) async {
    await tester.pumpWidget(_wrap(CompanyDashboardController(useCases: useCases)));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Bruno Member'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Promote to OWNER'));
    await tester.pumpAndSettle();

    expect(find.text('Promote Bruno Member to OWNER?'), findsOneWidget);
    await tester.tap(find.text('CANCEL'));
    await tester.pumpAndSettle();

    verifyNever(() => useCases.changeRole(any(), any()));
  });
}
