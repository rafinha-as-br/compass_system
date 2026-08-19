import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:travel_matrix/features/dashboard/domain/get_dashboard_stats.dart';
import 'package:travel_matrix/features/dashboard/presentation/controllers/dashboard_controller.dart';

class _MockGetDashboardStats extends Mock implements GetDashboardStats {}

void main() {
  late _MockGetDashboardStats getDashboardStats;

  setUp(() {
    getDashboardStats = _MockGetDashboardStats();
  });

  const stats = DashboardStats(
    totalTravels: 12,
    completedItineraries: 7,
    pendingItineraries: 5,
    activeClients: 9,
    recentTravels: [],
    activeClientsList: [],
  );

  test('loads the dashboard and exposes it through state on success', () async {
    when(() => getDashboardStats()).thenAnswer((_) async => stats);

    final controller = DashboardController(getDashboardStats: getDashboardStats);
    await pumpEventQueue();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.hasError, isFalse);
    expect(controller.state.dashboard?.totalTravels, stats.totalTravels);
  });

  test('exposes a hasError state without leaking the raw exception on failure', () async {
    when(() => getDashboardStats()).thenThrow(StateError('Not authenticated.'));

    final controller = DashboardController(getDashboardStats: getDashboardStats);
    await pumpEventQueue();

    expect(controller.state.isLoading, isFalse);
    expect(controller.state.hasError, isTrue);
    expect(controller.state.dashboard, isNull);
  });

  test('starts in a loading state before the use case resolves', () {
    when(() => getDashboardStats()).thenAnswer(
      (_) => Future.delayed(const Duration(milliseconds: 10), () => stats),
    );

    final controller = DashboardController(getDashboardStats: getDashboardStats);

    expect(controller.state.isLoading, isTrue);
  });
}
