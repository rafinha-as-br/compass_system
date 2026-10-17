import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/features/account/domain/change_password.dart';
import 'package:travel_matrix/features/account/presentation/controllers/change_password_controller.dart';
import 'package:travel_matrix/features/account/presentation/widgets/change_password_form.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

class _MockChangePassword extends Mock implements ChangePassword {}

Widget _wrap(ChangePasswordController controller, VoidCallback onSuccess) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SingleChildScrollView(
        child: ChangePasswordForm(controller: controller, onSuccess: onSuccess),
      ),
    ),
  );
}

Future<void> _fill(WidgetTester tester, String current, String next, String confirm) async {
  final fields = find.byType(TextFormField);
  await tester.enterText(fields.at(0), current);
  await tester.enterText(fields.at(1), next);
  await tester.enterText(fields.at(2), confirm);
  await tester.tap(find.byType(ElevatedButton));
  await tester.pumpAndSettle();
}

void main() {
  late _MockChangePassword changePassword;
  late ChangePasswordController controller;
  late int successCalls;

  setUp(() {
    changePassword = _MockChangePassword();
    controller = ChangePasswordController(changePassword: changePassword);
    successCalls = 0;
  });

  testWidgets('mismatching confirmation blocks the submit', (tester) async {
    await tester.pumpWidget(_wrap(controller, () => successCalls++));

    await _fill(tester, 'temp-pass', 'new-password-1', 'other-password');

    expect(find.text('Passwords do not match'), findsOneWidget);
    verifyNever(() => changePassword(any(), any()));
    expect(successCalls, 0);
  });

  testWidgets('a new password shorter than 8 characters blocks the submit', (tester) async {
    await tester.pumpWidget(_wrap(controller, () => successCalls++));

    await _fill(tester, 'temp-pass', 'short', 'short');

    expect(find.text('Use at least 8 characters'), findsOneWidget);
    verifyNever(() => changePassword(any(), any()));
  });

  testWidgets('wrong current password shows the backend error and stays on the form', (tester) async {
    when(() => changePassword('wrong', 'new-password-1'))
        .thenThrow(StateError('A senha atual está incorreta.'));
    await tester.pumpWidget(_wrap(controller, () => successCalls++));

    await _fill(tester, 'wrong', 'new-password-1', 'new-password-1');

    expect(find.text('A senha atual está incorreta.'), findsOneWidget);
    expect(successCalls, 0);
  });

  testWidgets('success calls onSuccess with the entered passwords', (tester) async {
    when(() => changePassword('temp-pass', 'new-password-1')).thenAnswer((_) async {});
    await tester.pumpWidget(_wrap(controller, () => successCalls++));

    await _fill(tester, 'temp-pass', 'new-password-1', 'new-password-1');

    verify(() => changePassword('temp-pass', 'new-password-1')).called(1);
    expect(successCalls, 1);
  });
}
