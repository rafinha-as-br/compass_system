import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';

import '../../pages/views/itinerary_view_tab.dart';
import '../../pages/views/route_view_tab.dart';
/* this widget shows the tab bar and tab bar view for the Travel view page*/
class TravelViewBody extends StatelessWidget {
  const TravelViewBody({super.key, required this.travel});
  final Travel travel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [

        // Tab bar
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            indicator: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            labelColor: Theme.of(context).colorScheme.onPrimary,
            unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(text: 'OVERVIEW'),
              Tab(text: 'ITINERARY'),
            ],
          ),
        ),

        // Tab bar view
        Expanded(
          child: TabBarView(
            children: [
              RouteViewTab(travel: travel),
              ItineraryViewTab(travel: travel),
            ],
          ),
        ),
      ],
    );
  }
}
