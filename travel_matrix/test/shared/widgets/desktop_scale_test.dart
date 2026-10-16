import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/shared/widgets/desktop_scale.dart';

Future<void> _pump(WidgetTester tester, double width, {double systemScale = 1}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    MediaQuery(
      data: MediaQueryData(
        size: Size(width, 800),
        textScaler: TextScaler.linear(systemScale),
      ),
      child: const Directionality(
        textDirection: TextDirection.ltr,
        child: DesktopScale(
          child: Column(
            children: [
              Text('t', style: TextStyle(fontSize: 14)),
              Icon(Icons.add, size: 24),
            ],
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('scales text and icons by 1.15 at the desktop breakpoint', (tester) async {
    await _pump(tester, 1024);

    expect(tester.getSize(find.byIcon(Icons.add)).width, closeTo(24 * 1.15, 0.01));
    final scaler = MediaQuery.textScalerOf(tester.element(find.text('t')));
    expect(scaler.scale(14), closeTo(14 * 1.15, 0.01));
  });

  testWidgets('leaves text and icons untouched below the desktop breakpoint', (tester) async {
    await _pump(tester, 1023);

    expect(tester.getSize(find.byIcon(Icons.add)).width, 24);
    final scaler = MediaQuery.textScalerOf(tester.element(find.text('t')));
    expect(scaler.scale(14), 14);
  });

  testWidgets('composes with the system text scale on desktop', (tester) async {
    await _pump(tester, 1280, systemScale: 1.2);

    final scaler = MediaQuery.textScalerOf(tester.element(find.text('t')));
    expect(scaler.scale(10), closeTo(10 * 1.2 * 1.15, 0.01));
  });
}
