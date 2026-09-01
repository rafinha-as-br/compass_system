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
  activeClientsList: [],
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
}
