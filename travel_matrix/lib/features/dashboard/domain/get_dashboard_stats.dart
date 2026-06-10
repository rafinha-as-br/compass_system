import 'package:travel_matrix/features/dashboard/domain/dashboard_repository.dart';
import 'package:travel_matrix/features/dashboard/domain/entities/dashboard_stats.dart';

class GetDashboardStats {
  final DashboardRepository _repository;

  const GetDashboardStats(this._repository);

  Future<DashboardStats> call() {
    return _repository.getDashboardStats();
  }
}
