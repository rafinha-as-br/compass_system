import 'package:flutter/material.dart';
import 'package:travel_matrix/features/dashboard/data/dashboard_data_source.dart';
import 'package:travel_matrix/features/dashboard/data/dashboard_repository_impl.dart';
import 'package:travel_matrix/features/dashboard/domain/get_dashboard_stats.dart';
import 'package:travel_matrix/features/dashboard/presentation/view_models/dashboard_view_model.dart';

class DashboardState {
  final bool isLoading;
  final DashboardViewModel? dashboard;
  final bool hasError;

  const DashboardState({
    this.isLoading = true,
    this.dashboard,
    this.hasError = false,
  });
}

class DashboardController extends ChangeNotifier {
  final GetDashboardStats _getDashboardStats;

  DashboardState _state = const DashboardState();
  DashboardState get state => _state;

  DashboardController({GetDashboardStats? getDashboardStats})
      : _getDashboardStats = getDashboardStats ??
            GetDashboardStats(DashboardRepositoryImpl(DashboardDataSource())) {
    load();
  }

  Future<void> load() async {
    _state = const DashboardState(isLoading: true);
    notifyListeners();

    try {
      final stats = await _getDashboardStats();
      _state = DashboardState(
        isLoading: false,
        dashboard: DashboardViewModel.fromDomain(stats),
      );
    } catch (e) {
      debugPrint('DashboardController.load failed: $e');
      _state = const DashboardState(isLoading: false, hasError: true);
    }

    notifyListeners();
  }
}
