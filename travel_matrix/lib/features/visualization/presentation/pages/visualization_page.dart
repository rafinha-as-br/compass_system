import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/core/services/compass_service.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class VisualizationState {
  final bool isLoading;
  final List<RoutePlan> routes;
  final List<Itinerary> itineraries;

  const VisualizationState({
    this.isLoading = true,
    this.routes = const [],
    this.itineraries = const [],
  });
}

class VisualizationController extends ChangeNotifier {
  VisualizationState _state = const VisualizationState();
  VisualizationState get state => _state;

  VisualizationController() {
    _fetchData();
  }

  Future<void> _fetchData() async {
    _state = const VisualizationState(isLoading: true);
    notifyListeners();

    try {
      final routes = await CompassService.instance.getRoutes();
      final itineraries = await CompassService.instance.getItineraries();

      _state = VisualizationState(
        isLoading: false,
        routes: routes,
        itineraries: itineraries,
      );
      notifyListeners();
    } catch (e) {
      _state = const VisualizationState(isLoading: false);
      notifyListeners();
    }
  }
}

class VisualizationPage extends StatelessWidget {
  const VisualizationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VisualizationController(),
      child: const _VisualizationView(),
    );
  }
}

class _VisualizationView extends StatelessWidget {
  const _VisualizationView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TravelAppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Breadcrumbs & Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Booking > Client Routes', style: TextStyle(color: TravelAppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    const Text('Client Routes', style: TextStyle(color: TravelAppColors.primary, fontSize: 28, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    const Text('Manage and review incoming travel requests from your elite portfolio.', style: TextStyle(color: TravelAppColors.textSecondary, fontSize: 14)),
                  ],
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    backgroundColor: TravelAppColors.primary,
                    foregroundColor: TravelAppColors.surface,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () {},
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('Create Manual Route', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // KPI Cards row
            Row(
              children: [
                Expanded(child: _buildKpiCard(Icons.library_books, 'NEW REQUESTS', '12', TravelAppColors.info)),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(Icons.edit_calendar, 'IN REVIEW', '08', TravelAppColors.warning)),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(Icons.check_circle, 'COMPLETED', '45', TravelAppColors.success)),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(Icons.history, 'THIS MONTH', '89', TravelAppColors.textSecondary)),
              ],
            ),
            const SizedBox(height: 40),

            // Table Container
            Container(
              decoration: BoxDecoration(
                color: TravelAppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TravelAppColors.border),
              ),
              child: Column(
                children: [
                  // Filter & Action Row
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            _buildTabButton('All Routes', true),
                            const SizedBox(width: 8),
                            _buildTabButton('New Request', false),
                            const SizedBox(width: 8),
                            _buildTabButton('In Review', false),
                          ],
                        ),
                        Row(
                          children: [
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.filter_list, size: 18, color: TravelAppColors.textSecondary),
                              label: const Text('More Filters', style: TextStyle(color: TravelAppColors.textPrimary)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: TravelAppColors.border)),
                            ),
                            const SizedBox(width: 12),
                            OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.file_download_outlined, size: 18, color: TravelAppColors.textSecondary),
                              label: const Text('Export CSV', style: TextStyle(color: TravelAppColors.textPrimary)),
                              style: OutlinedButton.styleFrom(side: const BorderSide(color: TravelAppColors.border)),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: TravelAppColors.divider),
                  
                  // Mock DataTable
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: TravelAppColors.divider),
                    child: DataTable(
                      headingTextStyle: const TextStyle(color: TravelAppColors.textSecondary, fontWeight: FontWeight.bold, fontSize: 11),
                      columnSpacing: 32,
                      horizontalMargin: 24,
                      columns: const [
                        DataColumn(label: Text('CLIENT\nID')),
                        DataColumn(label: Text('CLIENT NAME')),
                        DataColumn(label: Text('DESTINATION')),
                        DataColumn(label: Text('TRAVEL\nPERIOD')),
                        DataColumn(label: Text('STATUS')),
                        DataColumn(label: Text('ACTIONS')),
                      ],
                      rows: [
                        _buildTableRow('#TM-8821', 'Elena', 'Sterling', 'Santorini, Greece', 'Oct 12 — Oct 22\n10 Nights', 'NEW REQUEST', TravelAppColors.info),
                        _buildTableRow('#TM-8902', 'Julian', 'Thorne', 'Kyoto, Japan', 'Nov 04 — Nov 18\n14 Nights', 'IN REVIEW', TravelAppColors.warning),
                        _buildTableRow('#TM-8845', 'Sienna', 'Rivera', 'Cape Town, SA', 'Dec 20 — Jan 05\n16 Nights', 'ITINERARY CREATED', TravelAppColors.success),
                        _buildTableRow('#TM-8951', 'Aidan', 'Vance', 'Swiss Alps, Switzerland', 'Jan 15 — Jan 22\n7 Nights', 'CANCELLED', TravelAppColors.textSecondary),
                      ],
                    ),
                  ),
                  
                  // Pagination Footer
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Showing 1-10 of 84 routes', style: TextStyle(color: TravelAppColors.textSecondary, fontSize: 13)),
                        Row(
                          children: [
                            const IconButton(icon: Icon(Icons.chevron_left, size: 20), onPressed: null),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(color: TravelAppColors.primary, borderRadius: BorderRadius.circular(4)),
                              child: const Text('1', style: TextStyle(color: TravelAppColors.surface, fontWeight: FontWeight.bold)),
                            ),
                            const IconButton(icon: Icon(Icons.chevron_right, size: 20), onPressed: null),
                          ],
                        )
                      ],
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(IconData icon, String title, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TravelAppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TravelAppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: iconColor.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(color: TravelAppColors.textSecondary, fontSize: 11, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(value, style: const TextStyle(color: TravelAppColors.primary, fontSize: 24, fontWeight: FontWeight.bold)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? TravelAppColors.primary : TravelAppColors.background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? TravelAppColors.surface : TravelAppColors.textSecondary,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }

  DataRow _buildTableRow(String id, String firstName, String lastName, String destination, String dates, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(Text(id, style: const TextStyle(color: TravelAppColors.textSecondary, fontWeight: FontWeight.bold))),
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: TravelAppColors.divider,
                child: Text(firstName[0], style: const TextStyle(fontSize: 12, color: TravelAppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(firstName, style: const TextStyle(fontWeight: FontWeight.bold, color: TravelAppColors.primary)),
                  Text(lastName, style: const TextStyle(fontWeight: FontWeight.bold, color: TravelAppColors.primary)),
                ],
              ),
            ],
          ),
        ),
        DataCell(
          Row(
            children: [
              const Icon(Icons.location_on, color: TravelAppColors.accentGoldDark, size: 16),
              const SizedBox(width: 8),
              Text(destination, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          )
        ),
        DataCell(Text(dates, style: const TextStyle(color: TravelAppColors.textSecondary))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(16)),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(color: TravelAppColors.accentGold.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
            child: const Text('Review\nRoute', textAlign: TextAlign.center, style: TextStyle(color: TravelAppColors.accentGoldDark, fontWeight: FontWeight.bold, fontSize: 11)),
          )
        ),
      ],
    );
  }
}
