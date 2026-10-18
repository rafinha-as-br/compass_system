import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/shared/widgets/responsive_layout_builder.dart';

Widget _host(double width, {bool withTablet = true}) {
  return Directionality(
    textDirection: TextDirection.ltr,
    child: Center(
      child: SizedBox(
        width: width,
        child: ResponsiveLayoutBuilder(
          mobile: (_) => const Text('mobile'),
          tablet: withTablet ? (_) => const Text('tablet') : null,
          desktop: (_) => const Text('desktop'),
        ),
      ),
    ),
  );
}

void main() {
  setUp(() {
    final view = TestWidgetsFlutterBinding.ensureInitialized().platformDispatcher.views.first;
    view.physicalSize = const Size(1600, 900);
    view.devicePixelRatio = 1.0;
    addTearDown(view.resetPhysicalSize);
    addTearDown(view.resetDevicePixelRatio);
  });

  testWidgets('chooses the layout at the exact breakpoint limits', (tester) async {
    final expected = {
      599.0: 'mobile',
      600.0: 'tablet',
      1023.0: 'tablet',
      1024.0: 'desktop',
    };
    for (final entry in expected.entries) {
      await tester.pumpWidget(_host(entry.key));
      expect(find.text(entry.value), findsOneWidget, reason: '${entry.key}px');
    }
  });

  testWidgets('tablet falls back to mobile when no tablet builder is given', (tester) async {
    await tester.pumpWidget(_host(800, withTablet: false));
    expect(find.text('mobile'), findsOneWidget);
  });

  testWidgets('switches layout when the available width changes', (tester) async {
    await tester.pumpWidget(_host(500));
    expect(find.text('mobile'), findsOneWidget);

    await tester.pumpWidget(_host(1200));
    expect(find.text('desktop'), findsOneWidget);
    expect(find.text('mobile'), findsNothing);
  });
}
