import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';

/// This appBar is used in the Travel_View_page, responsible for showing:
/// - Travel Name
/// - Travel Status (right next to the travel name)
/// - Travel Start and Finish Date
/// - Number of Travelers
class TravelViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TravelViewAppBar({
    super.key,
    required this.travel,
  });

  final TravelViewModel travel;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(
            color: Color(0xFFE8ECF0),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Travel Status and title
              Row(
                spacing: 16,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  // Title
                  Expanded(
                    child: Text(
                      travel.travelTitle,
                      style: const TextStyle(
                        fontSize: 32, // Slightly smaller to fit with back button
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1A2C3A),
                        letterSpacing: -0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // travel Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTravelStatusColor(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      travel.statusString,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              // Date and travelers row
              Row(
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.calendar_today_outlined,
                        size: 14,
                        color: Color(0xFF8E9AAB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${travel.route.startDate.month}/${travel.route.startDate.day}',
                        style: TextStyle(
                          color: _getTravelStatusColor(context),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.map), text: 'Route View'),
                  Tab(icon: Icon(Icons.view_timeline), text: 'Itinerary View'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(160);

  Color _getTravelStatusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (travel.status) {
      case TravelStatusViewModel.notReady:
        return scheme.error;
      case TravelStatusViewModel.ready:
        return scheme.primary;
      case TravelStatusViewModel.inProgress:
        return scheme.secondary;
      case TravelStatusViewModel.completed:
        return scheme.secondaryContainer;
    }
  }
}
