import 'package:flutter/material.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TravelAppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(40.0),
              decoration: BoxDecoration(
                color: TravelAppColors.primary,
                borderRadius: BorderRadius.circular(16),
                gradient: const LinearGradient(
                  colors: [TravelAppColors.primary, TravelAppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome, Agent!', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: TravelAppColors.surface)),
                  const SizedBox(height: 12),
                  Text.rich(
                    TextSpan(
                      text: 'Your desk is ready. You have ',
                      style: const TextStyle(color: TravelAppColors.disabled, fontSize: 16),
                      children: [
                        const TextSpan(text: '5 pending inquiries', style: TextStyle(color: TravelAppColors.surface, fontWeight: FontWeight.w600)),
                        const TextSpan(text: ' and '),
                        const TextSpan(text: '12 itineraries', style: TextStyle(color: TravelAppColors.surface, fontWeight: FontWeight.w600)),
                        const TextSpan(text: ' requiring\nyour expert touch today.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            
            // KPI Cards row
            Row(
              children: [
                Expanded(child: _buildKpiCard(Icons.route, 'Active Routes', '25', TravelAppColors.success, '+12%')),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(Icons.calendar_today, 'Itineraries in Progress', '12', TravelAppColors.accentGold, null)),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(Icons.check_circle_outline, 'Completed Trips', '148', TravelAppColors.success, null)),
                const SizedBox(width: 24),
                Expanded(child: _buildKpiCard(Icons.location_on_outlined, 'Pending Inquiries', '5', TravelAppColors.error, 'Urgent')),
              ],
            ),
            const SizedBox(height: 40),

            // Recent Routes Section
            Container(
              decoration: BoxDecoration(
                color: TravelAppColors.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: TravelAppColors.border),
              ),
              child: Column(
                children: [
                  // Table Header
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Recent Client Routes', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: TravelAppColors.primary)),
                        TextButton(
                          onPressed: () {},
                          child: const Text('View All Records', style: TextStyle(color: TravelAppColors.accentGoldDark, fontWeight: FontWeight.w600)),
                        )
                      ],
                    ),
                  ),
                  const Divider(height: 1, color: TravelAppColors.divider),
                  // Table
                  Theme(
                    data: Theme.of(context).copyWith(dividerColor: TravelAppColors.divider),
                    child: DataTable(
                      headingTextStyle: const TextStyle(color: TravelAppColors.textSecondary, fontWeight: FontWeight.w600, fontSize: 12),
                      columnSpacing: 60,
                      horizontalMargin: 24,
                      columns: const [
                        DataColumn(label: Text('CLIENT NAME')),
                        DataColumn(label: Text('DESTINATION')),
                        DataColumn(label: Text('DATE SUBMITTED')),
                        DataColumn(label: Text('STATUS')),
                      ],
                      rows: [
                        _buildTableRow('EJ', 'Eleanor Jacobs', 'Santorini, Greece', 'Oct 24, 2023', 'Pending Review', TravelAppColors.warning),
                        _buildTableRow('MC', 'Marcus Chen', 'Tokyo, Japan', 'Oct 23, 2023', 'In Progress', TravelAppColors.info),
                        _buildTableRow('SB', 'Sarah Blackwood', 'Reykjavik, Iceland', 'Oct 22, 2023', 'Completed', TravelAppColors.success),
                        _buildTableRow('DH', 'David Hoffman', 'Cape Town, South Africa', 'Oct 21, 2023', 'In Progress', TravelAppColors.info),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildKpiCard(IconData icon, String title, String value, Color iconColor, String? badgeText) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: TravelAppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TravelAppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 20),
              ),
              if (badgeText != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(badgeText, style: TextStyle(color: iconColor, fontSize: 10, fontWeight: FontWeight.bold)),
                )
            ],
          ),
          const SizedBox(height: 24),
          Text(title, style: const TextStyle(color: TravelAppColors.textSecondary, fontSize: 13, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(color: TravelAppColors.primary, fontSize: 32, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  DataRow _buildTableRow(String initials, String name, String destination, String date, String status, Color statusColor) {
    return DataRow(
      cells: [
        DataCell(
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: TravelAppColors.divider,
                child: Text(initials, style: const TextStyle(fontSize: 12, color: TravelAppColors.textSecondary, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: TravelAppColors.primary)),
            ],
          ),
        ),
        DataCell(Text(destination, style: const TextStyle(color: TravelAppColors.textSecondary))),
        DataCell(Text(date, style: const TextStyle(color: TravelAppColors.textSecondary))),
        DataCell(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(status, style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
