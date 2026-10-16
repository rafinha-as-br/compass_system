import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:travel_matrix/features/dashboard/presentation/widgets/kpi_cards_section.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

const _dashboard = DashboardViewModel(
  totalTravels: 12,
  completedItineraries: 7,
  pendingItineraries: 5,
  activeClients: 9,
  recentTravels: [],
);

Widget _wrap(ThemeData theme) {
  // Key por brightness: sem isso, um segundo pumpWidget com o mesmo MaterialApp
  // (mesmo tipo/sem key) não repropaga a troca de tema através do Navigator.
  return MaterialApp(
    key: ValueKey(theme.brightness),
    theme: theme,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Builder(
      builder: (context) => Scaffold(
        body: KpiCardsSection(dashboard: _dashboard, l10n: AppLocalizations.of(context)!),
      ),
    ),
  );
}

Color _iconColorOf(WidgetTester tester, IconData icon) {
  return tester.widget<Icon>(find.byIcon(icon)).color!;
}

void main() {
  testWidgets('each KPI card icon uses the expected brand/semantic color token, in light and dark', (tester) async {
    // Viewport largo o bastante para o layout em Row (não empilhado), evitando
    // overflow vertical no viewport default de teste.
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final theme in [AppTheme.lightTheme, AppTheme.darkTheme]) {
      await tester.pumpWidget(_wrap(theme));

      // Viagens -> secondary (dourado).
      expect(_iconColorOf(tester, Icons.route), theme.colorScheme.secondary);
      // Itinerários completos -> semântico success (inalterado).
      expect(_iconColorOf(tester, Icons.event_available), theme.semanticColors.success);
      // Itinerários pendentes -> semântico warning (inalterado).
      expect(_iconColorOf(tester, Icons.pending_actions), theme.semanticColors.warning);
      // Clientes ativos -> tertiary (verde, novo token).
      expect(_iconColorOf(tester, Icons.people_alt_outlined), theme.colorScheme.tertiary);
    }
  });

  testWidgets('tertiary is a distinct token from secondary and from the success semantic color', (tester) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(_wrap(AppTheme.lightTheme));

    final travelsColor = _iconColorOf(tester, Icons.route);
    final completedColor = _iconColorOf(tester, Icons.event_available);
    final clientsColor = _iconColorOf(tester, Icons.people_alt_outlined);

    expect(clientsColor, isNot(travelsColor));
    expect(clientsColor, isNot(completedColor));
  });

  group('grade por largura disponível (CPS-199)', () {
    Future<List<Rect>> pumpAt(WidgetTester tester, double width) async {
      tester.view.physicalSize = Size(width, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(_wrap(AppTheme.lightTheme));
      expect(tester.takeException(), isNull, reason: 'largura $width');
      return [for (final icon in [Icons.route, Icons.event_available, Icons.pending_actions, Icons.people_alt_outlined])
        tester.getRect(find.ancestor(of: find.byIcon(icon), matching: find.byType(Card)))];
    }

    testWidgets('desktop (>= 1024): 4 cartões em uma linha, mesma largura', (tester) async {
      final cards = await pumpAt(tester, 1400);
      expect({for (final c in cards) c.top}, hasLength(1));
      expect({for (final c in cards) c.width.round()}, hasLength(1));
    });

    testWidgets('tablet (600-1023, ex.: ~800 px de conteúdo): grade 2x2 alinhada, sem área vazia à direita', (tester) async {
      final cards = await pumpAt(tester, 800);
      expect(cards[0].top, cards[1].top);
      expect(cards[2].top, cards[3].top);
      expect(cards[2].top, greaterThan(cards[0].top));
      expect(cards[0].left, cards[2].left);
      expect(cards[1].left, cards[3].left);
      expect({for (final c in cards) c.width.round()}, hasLength(1));
      expect(cards[1].right, closeTo(800, 1));
    });

    testWidgets('mobile (< 600): uma coluna, cartões com a largura toda', (tester) async {
      final cards = await pumpAt(tester, 400);
      expect({for (final c in cards) c.left}, hasLength(1));
      expect({for (final c in cards) c.width.round()}, hasLength(1));
      expect(cards.first.width, closeTo(400, 1));
    });
  });
}
