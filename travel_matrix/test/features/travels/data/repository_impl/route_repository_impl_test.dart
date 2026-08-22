import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:travel_matrix/features/travels/data/data_sources/route_data_source.dart';
import 'package:travel_matrix/features/travels/data/dtos/route_dto.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/route_repository_impl.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';

class _MockRouteDataSource extends Mock implements RouteDataSource {}

RoutePlan _buildRoute({String destination = 'Paris'}) {
  return RoutePlan(
    domainId: 'route-1',
    backEndId: 'route-1',
    startDate: DateTime(2026, 1, 1),
    endDate: DateTime(2026, 1, 10),
    startLocation: 'SP',
    destination: destination,
    interestsList: const <InterestPoint>[],
  );
}

RoutePlanDTO _buildRouteDto({String destination = 'Paris'}) {
  return RoutePlanDTO.fromDomain(routePlan: _buildRoute(destination: destination));
}

void main() {
  late _MockRouteDataSource dataSource;
  late RouteRepositoryImpl repository;

  setUpAll(() {
    registerFallbackValue(_buildRouteDto());
  });

  setUp(() {
    dataSource = _MockRouteDataSource();
    repository = RouteRepositoryImpl(dataSource: dataSource);
  });

  test('upserts the route through the isolated endpoint and returns the updated plan', () async {
    when(() => dataSource.updateRoute('travel-1', any()))
        .thenAnswer((_) async => _buildRouteDto(destination: 'Rome'));

    final result = await repository.updateRoute('travel-1', _buildRoute(destination: 'Rome'));

    expect(result.isSuccess, isTrue);
    expect(result.data!.destination, 'Rome');

    final sentDto = verify(() => dataSource.updateRoute('travel-1', captureAny())).captured.single as RoutePlanDTO;
    expect(sentDto.destination, 'Rome');
    expect(sentDto.startLocation, 'SP');
  });

  test('returns failure without throwing when the data source fails', () async {
    when(() => dataSource.updateRoute('travel-1', any())).thenThrow(Exception('Network error'));

    final result = await repository.updateRoute('travel-1', _buildRoute());

    expect(result.isSuccess, isFalse);
    expect(result.error, contains('Network error'));
  });
}
