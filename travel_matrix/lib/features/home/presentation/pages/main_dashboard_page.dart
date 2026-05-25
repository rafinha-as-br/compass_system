import 'package:flutter/material.dart';
import 'package:travel_matrix/core/services/auth_service.dart';
import 'package:travel_matrix/core/services/compass_service.dart';
import 'package:mock_repository/mock_repository.dart';

/// Main Dashboard Tab — displays travel updates and KPI metrics.
class MainDashboardPage extends StatefulWidget {
  const MainDashboardPage({super.key});

  @override
  State<MainDashboardPage> createState() => _MainDashboardPageState();
}

class _MainDashboardPageState extends State<MainDashboardPage> {
  bool _isLoading = true;
  List<Travel> _travels = [];
  int _totalClients = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final token = await AuthService.instance.getToken();
      if (token == null) return;

      final travelsResponse =
          await CompassService.instance.getAllTravels(token);
      final usersResponse =
          await CompassService.instance.getAllUsers(token);

      if (mounted) {
        setState(() {
          if (travelsResponse['status'] == 'success') {
            _travels = (travelsResponse['data'] as List<dynamic>)
                .map((e) => Travel.fromJson(e as Map<String, dynamic>))
                .toList();
          }
          if (usersResponse['status'] == 'success') {
            _totalClients = (usersResponse['data'] as List<dynamic>).length;
          }
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Dashboard Overview',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                // ─── KPI Cards ──────────────────────────────────
                _buildKpiRow(theme),
                const SizedBox(height: 32),
                // ─── Recent Travels ─────────────────────────────
                Text(
                  'Recent Travel Updates',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                _buildRecentTravels(theme),
              ],
            ),
          );
  }

  Widget _buildKpiRow(ThemeData theme) {
    final completedTravels =
        _travels.where((t) => t.hasItinerary).length;
    final pendingItineraries =
        _travels.where((t) => !t.hasItinerary).length;

    return Row(
      children: [
        Expanded(
          child: _KpiCard(
            icon: Icons.flight_takeoff,
            label: 'Total Travels',
            value: '${_travels.length}',
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            icon: Icons.check_circle,
            label: 'Itineraries Completed',
            value: '$completedTravels',
            color: const Color(0xFF2E7D5B),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            icon: Icons.pending_actions,
            label: 'Pending Itineraries',
            value: '$pendingItineraries',
            color: const Color(0xFFC08A2E),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _KpiCard(
            icon: Icons.people,
            label: 'Active Clients',
            value: '$_totalClients',
            color: const Color(0xFF3A6EA5),
          ),
        ),
      ],
    );
  }

  Widget _buildRecentTravels(ThemeData theme) {
    if (_travels.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Center(
            child: Text(
              'No travels created yet.',
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ),
        ),
      );
    }

    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: _travels.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final travel = _travels[index];
          return ListTile(
            leading: Icon(
              travel.hasItinerary
                  ? Icons.check_circle
                  : Icons.schedule,
              color: travel.hasItinerary
                  ? const Color(0xFF2E7D5B)
                  : const Color(0xFFC08A2E),
            ),
            title: Text(
              travel.travelName,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              '${travel.routePlan.startLocation} ➔ ${travel.routePlan.destination}',
            ),
            trailing: Chip(
              label: Text(
                travel.hasItinerary ? 'COMPLETE' : 'PENDING',
                style: const TextStyle(fontSize: 10),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                color: Theme.of(context)
                    .colorScheme
                    .onSurface
                    .withValues(alpha: 0.6),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
