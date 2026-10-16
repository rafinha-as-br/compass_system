import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/app_injector.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/features/auth/presentation/pages/landing_page.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/login_panel.dart';
import 'package:travel_matrix/features/auth/presentation/widgets/welcome_panel.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

Future<void> _pumpLanding(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ChangeNotifierProvider(
      create: (_) => AuthController(),
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: const LandingPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  group('computeBannerLayout', () {
    test('em janelas largas, usa o padding e a largura máximos', () {
      final layout = computeBannerLayout(const Size(1600, 900));

      expect(layout.padding, const EdgeInsets.symmetric(horizontal: 230, vertical: 162));
      expect(layout.logoWidth, 400);
    });

    test('em janelas estreitas, reduz padding e logo sem estourar o espaço disponível', () {
      const availableSize = Size(900, 700);

      final layout = computeBannerLayout(availableSize);

      final totalWidthUsed = layout.padding.horizontal + layout.logoWidth;
      expect(totalWidthUsed, lessThanOrEqualTo(availableSize.width));
      expect(layout.padding.horizontal, greaterThanOrEqualTo(24 * 2));
      expect(layout.logoWidth, greaterThanOrEqualTo(120));
    });

    test('nunca deixa o padding ou a logo abaixo do mínimo, mesmo em janelas minúsculas', () {
      final layout = computeBannerLayout(const Size(100, 100));

      expect(layout.padding, const EdgeInsets.symmetric(horizontal: 24, vertical: 24));
      expect(layout.logoWidth, 120);
    });
  });

  group('LandingPage responsiva (CPS-198)', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      await AppInjector.init();
    });

    testWidgets('mobile (411): coluna única, sem overflow, e o botão de login fica alcançável', (tester) async {
      await _pumpLanding(tester, const Size(411, 800));
      expect(tester.takeException(), isNull);
      expect(find.byType(WelcomePanel), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(find.byType(LoginPanel), findsOneWidget);

      final submit = find.text('LOGIN AS AGENT');
      await tester.ensureVisible(submit);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final rect = tester.getRect(submit);
      expect(rect.bottom, lessThanOrEqualTo(800));
      expect(rect.right, lessThanOrEqualTo(411));
    });

    testWidgets('tablet (700) e desktop (1280) mantêm duas colunas sem overflow', (tester) async {
      for (final size in [const Size(700, 800), const Size(1280, 800)]) {
        await _pumpLanding(tester, size);
        expect(tester.takeException(), isNull, reason: '$size');
        expect(find.byType(Image), findsOneWidget, reason: '$size');
        expect(find.byType(WelcomePanel), findsOneWidget, reason: '$size');
        // Painel à direita do banner (duas colunas).
        expect(tester.getTopLeft(find.byType(WelcomePanel)).dx, greaterThan(size.width / 3), reason: '$size');
      }
    });
  });
}
