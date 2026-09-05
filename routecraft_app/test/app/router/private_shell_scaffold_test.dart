import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/router/private_shell_scaffold.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';

class _CounterPage extends StatefulWidget {
  const _CounterPage({super.key});

  @override
  State<_CounterPage> createState() => _CounterPageState();
}

class _CounterPageState extends State<_CounterPage> {
  int _count = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => setState(() => _count++),
          child: Text('count: $_count'),
        ),
      ),
    );
  }
}

Widget _wrap(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: AppLocalizations.supportedLocales,
  );
}

GoRouter _threeBranchRouter() {
  return GoRouter(
    initialLocation: '/a',
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            PrivateShellScaffold(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(path: '/a', builder: (_, __) => const _CounterPage(key: ValueKey('a'))),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/b', builder: (_, __) => const _CounterPage(key: ValueKey('b'))),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/c', builder: (_, __) => const _CounterPage(key: ValueKey('c'))),
          ]),
        ],
      ),
    ],
  );
}

void main() {
  testWidgets('renders the 3 bottom navigation destinations without throwing', (tester) async {
    await tester.pumpWidget(_wrap(_threeBranchRouter()));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationDestination), findsNWidgets(3));
  });

  testWidgets('preserves each branch\'s state when switching tabs and back', (tester) async {
    await tester.pumpWidget(_wrap(_threeBranchRouter()));
    await tester.pumpAndSettle();

    // Bump the counter on branch A (index 0).
    await tester.tap(find.text('count: 0'));
    await tester.pumpAndSettle();
    expect(find.text('count: 1'), findsOneWidget);

    // Switch to branch B, then back to branch A.
    await tester.tap(find.byType(NavigationDestination).at(1));
    await tester.pumpAndSettle();
    expect(find.text('count: 1'), findsNothing);

    await tester.tap(find.byType(NavigationDestination).at(0));
    await tester.pumpAndSettle();

    expect(find.text('count: 1'), findsOneWidget);
  });
}
