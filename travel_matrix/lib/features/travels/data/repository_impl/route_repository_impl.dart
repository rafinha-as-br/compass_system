import 'package:travel_matrix/core/entities/result.dart';
import 'package:travel_matrix/features/travels/data/repository_impl/travel_repository_impl.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/domain/entities/travel.dart';
import 'package:travel_matrix/features/travels/domain/repository/route_repository.dart';
import 'package:travel_matrix/features/travels/domain/repository/travel_repository.dart';

class RouteRepositoryImpl implements RouteRepository {
  final TravelRepository _travelRepository;

  RouteRepositoryImpl({TravelRepository? travelRepository})
      : _travelRepository = travelRepository ?? TravelRepositoryImpl();

  @override
  Future<Result<RoutePlan>> updateRoute(
    String travelId,
    RoutePlan routePlan,
  ) async {
    final travelResult = await _travelRepository.getTravel(travelId);
    if (!travelResult.isSuccess || travelResult.data == null) {
      return Result.failure(travelResult.error ?? 'Travel not found.');
    }

    final travel = travelResult.data!;
    // Keep the existing route's own identity (domainId/backEndId) — only the
    // editable fields come from the caller — so the backend updates the
    // route already embedded in this travel instead of appearing to create
    // a new one.
    final mergedRoutePlan = RoutePlan(
      domainId: travel.routePlan.domainId,
      backEndId: travel.routePlan.backEndId,
      startDate: routePlan.startDate,
      endDate: routePlan.endDate,
      startLocation: routePlan.startLocation,
      destination: routePlan.destination,
      interestsList: routePlan.interestsList,
    );
    final updatedTravel = Travel(
      domainId: travel.domainId,
      backEndId: travel.backEndId,
      clientName: travel.clientName,
      travelName: travel.travelName,
      routePlan: mergedRoutePlan,
      participantsList: travel.participantsList,
      travelStatus: travel.travelStatus,
      itinerary: travel.itinerary,
      eventsLog: travel.eventsLog,
    );

    final updateResult = await _travelRepository.updateTravel(updatedTravel);
    if (!updateResult.isSuccess || updateResult.data == null) {
      return Result.failure(updateResult.error ?? 'Failed to update route.');
    }
    return Result.success(updateResult.data!.routePlan);
  }
}
