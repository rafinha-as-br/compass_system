import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/shared/widgets/app_text_field.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  testWidgets('default state renders the label and accepts input', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(_wrap(AppTextField(labelText: 'Email', controller: controller)));

    expect(find.text('Email'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), 'agent@routecraft.com');
    expect(controller.text, 'agent@routecraft.com');
  });

  testWidgets('disabled state (enabled: false) rejects input', (tester) async {
    final controller = TextEditingController();
    await tester.pumpWidget(
      _wrap(AppTextField(labelText: 'Email', controller: controller, enabled: false)),
    );

    final field = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(field.enabled, isFalse);

    await tester.enterText(find.byType(TextFormField), 'agent@routecraft.com');
    expect(controller.text, isEmpty);
  });

  testWidgets('surfaces the validator error message inside a Form', (tester) async {
    final formKey = GlobalKey<FormState>();
    await tester.pumpWidget(
      _wrap(
        Form(
          key: formKey,
          child: AppTextField(
            labelText: 'Email',
            validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
          ),
        ),
      ),
    );

    formKey.currentState!.validate();
    await tester.pump();

    expect(find.text('Required'), findsOneWidget);
  });
}
