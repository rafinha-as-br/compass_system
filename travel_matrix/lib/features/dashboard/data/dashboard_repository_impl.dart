import 'package:travel_matrix/features/dashboard/data/dashboard_data_source.dart';
import 'package:travel_matrix/features/dashboard/data/dtos/dashboard_stats_dto.dart';
import 'package:travel_matrix/features/dashboard/domain/dashboard_repository.dart';
import 'package:travel_matrix/features/dashboard/domain/entities/dashboard_stats.dart';

class DashboardRepositoryImpl implements DashboardRepository {
  final DashboardDataSource _dataSource;

  const DashboardRepositoryImpl(this._dataSource);

  @override
  Future<DashboardStats> getDashboardStats() async {
    final response = await _dataSource.getDashboardStats();
    if (response['status'] != 'success') {
      throw StateError(response['message'] as String? ?? 'Failed to load dashboard.');
    }

    final data = response['data'] as Map<String, dynamic>;
    return DashboardStatsDto.fromJson(data).toDomain();
  }
}
