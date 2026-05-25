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
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant,
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
                      color: _getTravelStatusBgColor(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      travel.statusString,
                      style: TextStyle(
                        color: _getTravelStatusFgColor(context),
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
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: Color(0xFF8E9AAB),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(travel.route.startDate)} - ${_formatDate(travel.route.endDate)}',
                    style: const TextStyle(
                      color: Color(0xFF8E9AAB),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${travel.participants.length} Travelers',
                    style: const TextStyle(
                      color: Color(0xFF8E9AAB),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: Color(0xFF8E9AAB),
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
  Size get preferredSize => const Size.fromHeight(170);

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getTravelStatusBgColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (travel.status) {
      case TravelStatusViewModel.notReady:
        return scheme.errorContainer;
      case TravelStatusViewModel.ready:
        return scheme.primaryContainer;
      case TravelStatusViewModel.inProgress:
        return scheme.secondaryContainer;
      case TravelStatusViewModel.completed:
        return scheme.tertiaryContainer;
    }
  }

  Color _getTravelStatusFgColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (travel.status) {
      case TravelStatusViewModel.notReady:
        return scheme.onErrorContainer;
      case TravelStatusViewModel.ready:
        return scheme.onPrimaryContainer;
      case TravelStatusViewModel.inProgress:
        return scheme.onSecondaryContainer;
      case TravelStatusViewModel.completed:
        return scheme.onTertiaryContainer;
    }
  }
}
