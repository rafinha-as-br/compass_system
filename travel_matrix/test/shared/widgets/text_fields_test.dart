import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';
import 'package:travel_matrix/shared/widgets/text_fields.dart';

Widget _wrap(Widget child, {required ThemeData theme}) {
  // Key por brightness: sem isso, um segundo pumpWidget com o mesmo MaterialApp
  // (mesmo tipo/sem key) não repropaga a troca de tema através do Navigator.
  return MaterialApp(
    key: ValueKey(theme.brightness),
    theme: theme,
    home: Scaffold(body: child),
  );
}

CustomFormField _buildField({String? errorText}) {
  return CustomFormField.text(
    label: 'Name',
    enabled: true,
    controller: TextEditingController(),
    onChanged: (_) {},
    errorText: errorText,
  );
}

/// [CustomFormField] não define bordas próprias — elas vêm inteiramente do
/// `inputDecorationTheme` do app. Lê a borda efetiva (já mesclada com o tema)
/// a partir do [InputDecorator] interno, em vez do [TextField.decoration] cru.
OutlineInputBorder _effectiveEnabledBorder(WidgetTester tester) {
  final decorator = tester.widget<InputDecorator>(find.byType(InputDecorator));
  return decorator.decoration.enabledBorder as OutlineInputBorder;
}

OutlineInputBorder _effectiveErrorBorder(WidgetTester tester) {
  final decorator = tester.widget<InputDecorator>(find.byType(InputDecorator));
  return decorator.decoration.errorBorder as OutlineInputBorder;
}

void main() {
  testWidgets('default (no error) border color comes from colorScheme.outline, and follows theme changes', (tester) async {
    await tester.pumpWidget(_wrap(_buildField(), theme: AppTheme.lightTheme));
    expect(_effectiveEnabledBorder(tester).borderSide.color, AppTheme.lightTheme.colorScheme.outline);

    // Nova instância — evita o widget idêntico ser pulado na reconstrução
    // (Flutter não re-diffa subárvores quando o widget é `identical()`).
    await tester.pumpWidget(_wrap(_buildField(), theme: AppTheme.darkTheme));
    final darkBorder = _effectiveEnabledBorder(tester).borderSide.color;
    expect(darkBorder, AppTheme.darkTheme.colorScheme.outline);
    expect(darkBorder, isNot(AppTheme.lightTheme.colorScheme.outline));
  });

  testWidgets('error state border color comes from colorScheme.error, and follows theme changes', (tester) async {
    await tester.pumpWidget(_wrap(_buildField(errorText: 'Required'), theme: AppTheme.lightTheme));
    expect(_effectiveErrorBorder(tester).borderSide.color, AppTheme.lightTheme.colorScheme.error);

    await tester.pumpWidget(_wrap(_buildField(errorText: 'Required'), theme: AppTheme.darkTheme));
    expect(_effectiveErrorBorder(tester).borderSide.color, AppTheme.darkTheme.colorScheme.error);
  });
}
