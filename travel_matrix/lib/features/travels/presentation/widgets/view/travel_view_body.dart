import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';

import '../../pages/travel_views/itinerary_view_tab.dart';
import '../../pages/travel_views/route_view_tab.dart';
/* this widget shows the tab bar and tab bar view for the Travel view page*/
class TravelViewBody extends StatelessWidget {
  const TravelViewBody({super.key, required this.tabController, required this.travel});
  final TabController tabController;
  final Travel travel;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tab bar
        Container(
          margin: const EdgeInsets.only(left: 20, right: 20, top: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF5F7FA),
            borderRadius: BorderRadius.circular(12),
          ),
          child: TabBar(
            controller: tabController,
            indicator: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(5),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            labelColor: const Color(0xFF1A2C3A),
            unselectedLabelColor: const Color(0xFF8E9AAB),
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
            controller: tabController,
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
