import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';
import 'package:travel_matrix/shared/widgets/primary_submit_button.dart';

Widget _wrap({required bool isLoading, required ThemeData theme}) {
  // Key por brightness: sem isso, um segundo pumpWidget com o mesmo MaterialApp
  // (mesmo tipo/sem key) não repropaga a troca de tema através do Navigator.
  return MaterialApp(
    key: ValueKey(theme.brightness),
    theme: theme,
    home: Scaffold(
      body: PrimarySubmitButton(label: 'Submit', isLoading: isLoading, onPressed: () {}),
    ),
  );
}

void main() {
  testWidgets('loading spinner color comes from colorScheme.onPrimary, and follows theme changes', (tester) async {
    await tester.pumpWidget(_wrap(isLoading: true, theme: AppTheme.lightTheme));
    var indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    expect(indicator.color, AppTheme.lightTheme.colorScheme.onPrimary);

    await tester.pumpWidget(_wrap(isLoading: true, theme: AppTheme.darkTheme));
    indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    expect(indicator.color, AppTheme.darkTheme.colorScheme.onPrimary);
  });

  testWidgets('spinner color is not hardcoded — a non-white onPrimary is picked up', (tester) async {
    // AppTheme.lightTheme/darkTheme's onPrimary is white in both, o que não
    // provaria nada contra um Colors.white esquecido no widget. Um tema com
    // onPrimary propositalmente diferente prova que a cor vem do tema.
    const distinctOnPrimary = Color(0xFF123456);
    final theme = ThemeData(
      colorScheme: const ColorScheme.light(onPrimary: distinctOnPrimary),
    );

    await tester.pumpWidget(_wrap(isLoading: true, theme: theme));
    final indicator = tester.widget<CircularProgressIndicator>(find.byType(CircularProgressIndicator));
    expect(indicator.color, distinctOnPrimary);
    expect(indicator.color, isNot(Colors.white));
  });

  testWidgets('shows the label instead of a spinner when not loading', (tester) async {
    await tester.pumpWidget(_wrap(isLoading: false, theme: AppTheme.lightTheme));

    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(find.text('Submit'), findsOneWidget);
  });
}
