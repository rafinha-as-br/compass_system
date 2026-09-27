import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/itinerary_view_tab.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/overview_view_tab.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/route_view_tab.dart';

/// Body for the Travel View Page.
///
/// Consumes a [TravelViewModel] and displays the [OverviewViewTab],
/// [RouteViewTab] or [ItineraryViewTab] depending on the selected tab in
/// the AppBar.
///
/// Layout: TabBarView containing the overview, route and itinerary views.
class TravelViewBody extends StatelessWidget {
  const TravelViewBody({super.key, required this.travel});

  final TravelViewModel travel;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: TabBarView(
        children: [
          OverviewViewTab(travel: travel),
          RouteViewTab(travel: travel),
          ItineraryViewTab(travel: travel),
        ],
      ),
    );
  }
}
