import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/features/dashboard/domain/dashboard_repository.dart';
import 'package:travel_matrix/features/dashboard/domain/entities/dashboard_stats.dart';
import 'package:travel_matrix/features/dashboard/domain/get_dashboard_stats.dart';

class _MockDashboardRepository extends Mock implements DashboardRepository {}

void main() {
  late _MockDashboardRepository repository;
  late GetDashboardStats useCase;

  setUp(() {
    repository = _MockDashboardRepository();
    useCase = GetDashboardStats(repository);
  });

  const stats = DashboardStats(
    totalTravels: 12,
    completedItineraries: 7,
    pendingItineraries: 5,
    activeClients: 9,
    recentTravels: [],
    activeClientsList: [],
  );

  test('returns the stats from the repository on success', () async {
    when(() => repository.getDashboardStats()).thenAnswer((_) async => stats);

    final result = await useCase();

    expect(result.totalTravels, stats.totalTravels);
    verify(() => repository.getDashboardStats()).called(1);
  });

  test('propagates the failure when the repository throws', () async {
    when(() => repository.getDashboardStats())
        .thenThrow(StateError('Not authenticated.'));

    expect(() => useCase(), throwsA(isA<StateError>()));
  });
}
