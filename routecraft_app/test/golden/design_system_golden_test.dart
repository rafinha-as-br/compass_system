import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/theme/app_theme.dart';
import 'package:routecraft_app/shared/widgets/app_bottom_sheet.dart';
import 'package:routecraft_app/shared/widgets/empty_state_view.dart';
import 'package:routecraft_app/shared/widgets/info_tile.dart';
import 'package:routecraft_app/shared/widgets/skeleton_block.dart';
import 'package:routecraft_app/shared/widgets/step_icon.dart';
import 'package:routecraft_app/shared/widgets/travel_card.dart';
import 'package:routecraft_app/shared/widgets/travel_status_chip.dart';

/// Golden coverage for the CPS-86 shared components, in both theme
/// variants — each rendered on its own, not inside a full screen.

// ponytail: see the identical note in screens_golden_test.dart — these
// goldens use a plain Material theme (no google_fonts) for the same reason
// (TestWidgetsFlutterBinding blocks the HTTP fetch GoogleFonts triggers).
ThemeData _goldenLightTheme() => ThemeData(
      brightness: Brightness.light,
      primaryColor: TravelAppColors.primary,
      scaffoldBackgroundColor: TravelAppColors.background,
      colorScheme: const ColorScheme.light(
        primary: TravelAppColors.primary,
        secondary: TravelAppColors.accentGold,
        surface: TravelAppColors.surface,
        error: TravelAppColors.error,
        onPrimary: TravelAppColors.textOnPrimary,
        onSecondary: TravelAppColors.textPrimary,
        onSurface: TravelAppColors.textPrimary,
        onError: TravelAppColors.textOnPrimary,
      ),
    );

ThemeData _goldenDarkTheme() => ThemeData(
      brightness: Brightness.dark,
      primaryColor: TravelAppColors.primaryDark,
      scaffoldBackgroundColor: TravelAppColors.surfaceDark,
      colorScheme: const ColorScheme.dark(
        primary: TravelAppColors.primaryLight,
        secondary: TravelAppColors.accentGoldLight,
        surface: TravelAppColors.surfaceDark,
        error: TravelAppColors.error,
        onPrimary: TravelAppColors.textOnPrimary,
        onSecondary: TravelAppColors.textPrimary,
        onSurface: TravelAppColors.textOnDark,
        onError: TravelAppColors.textOnPrimary,
      ),
    );

final _themes = <String, ThemeData Function()>{
  'light': _goldenLightTheme,
  'dark': _goldenDarkTheme,
};

Widget _gallery() => Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Wrap(spacing: 8, runSpacing: 8, children: [
            TravelStatusChip(status: TravelStatusChipVariant.routeCreated),
            TravelStatusChip(status: TravelStatusChipVariant.itineraryCreated),
            TravelStatusChip(status: TravelStatusChipVariant.travelStarted),
            TravelStatusChip(status: TravelStatusChipVariant.travelFinished),
          ]),
          const SizedBox(height: 16),
          const TravelCard(
            travelName: 'Lisbon 2025',
            routeSummary: 'São Paulo → Lisbon',
            status: TravelStatusChipVariant.itineraryCreated,
          ),
          const SizedBox(height: 16),
          const InfoTile(icon: Icons.calendar_today, label: 'Start date', value: 'Aug 1, 2025'),
          const SizedBox(height: 16),
          EmptyStateView(
            icon: Icons.map_outlined,
            title: 'No trips yet',
            message: 'Create a route to get started.',
            ctaLabel: 'Create Route',
            onCtaPressed: () {},
          ),
          const SizedBox(height: 16),
          const SkeletonBlock(height: 16, width: 200),
          const SizedBox(height: 8),
          const SkeletonBlock(height: 16, width: 120),
          const SizedBox(height: 16),
          const Wrap(spacing: 8, runSpacing: 8, children: [
            StepIcon(type: StepIconType.stop),
            StepIcon(type: StepIconType.hosting),
            StepIcon(type: StepIconType.airplane),
            StepIcon(type: StepIconType.bus),
            StepIcon(type: StepIconType.rentalCar),
            StepIcon(type: StepIconType.boundary),
          ]),
        ],
      ),
    );

void main() {
  for (final themeEntry in _themes.entries) {
    testWidgets('design system gallery (${themeEntry.key}) matches golden', (tester) async {
      tester.view.physicalSize = const Size(1080, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MaterialApp(
        theme: themeEntry.value(),
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        locale: const Locale('en'),
        home: Scaffold(body: SingleChildScrollView(child: _gallery())),
      ));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(MaterialApp),
        matchesGoldenFile('goldens/design_system_${themeEntry.key}.png'),
      );
    });
  }

  testWidgets('bottom sheet matches golden in light theme', (tester) async {
    tester.view.physicalSize = const Size(1080, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: _goldenLightTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: ElevatedButton(
              onPressed: () => AppBottomSheet.show<void>(
                context,
                title: 'Step details',
                child: const InfoTile(icon: Icons.flight, label: 'Flight', value: 'TP045'),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    await expectLater(
      find.byType(AppBottomSheet),
      matchesGoldenFile('goldens/design_system_bottom_sheet_light.png'),
    );
  });
}
