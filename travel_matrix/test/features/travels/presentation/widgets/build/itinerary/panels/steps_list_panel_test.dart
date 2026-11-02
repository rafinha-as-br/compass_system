import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/itinerary_steps_view_models.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/build/itinerary/panels/steps_list_panel.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

void main() {
  testWidgets('steps list has no standalone "Add step" button', (tester) async {
    final steps = ItineraryStepsBuildModel(
      normalSteps: const [],
      startStep: ItineraryStepViewModel.newPlaceHolder(
        position: StepPosition.start,
        title: 'Start',
        description: 'd',
      ),
      finishStep: ItineraryStepViewModel.newPlaceHolder(
        position: StepPosition.finish,
        title: 'Finish',
        description: 'd',
      ),
    );

    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('en'),
      home: Scaffold(
        body: Row(children: [
          StepsListPanel(
            steps: steps,
            selectedIndex: 0,
            onSelectStep: (_) {},
            onReorder: (_, __) {},
            onDeleteStep: (_) {},
          ),
        ]),
      ),
    ));

    expect(find.text('Start'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsNothing);
    expect(find.text('Add step'), findsNothing);
  });
}
