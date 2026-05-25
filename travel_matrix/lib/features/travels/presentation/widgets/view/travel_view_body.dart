import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/itinerary_view_tab.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/route_view_tab.dart';

/// Body for the Travel View Page.
///
/// Consumes a [TravelViewModel] and displays either the [RouteViewTab] or
/// [ItineraryViewTab] depending on the selected tab in the AppBar.
///
/// Layout: TabBarView containing the route and itinerary views.
class TravelViewBody extends StatelessWidget {
  const TravelViewBody({super.key, required this.travel});

  final TravelViewModel travel;

  @override
  Widget build(BuildContext context) {
    return TabBarView(
      children: [
        RouteViewTab(travel: travel),
        ItineraryViewTab(travel: travel),
      ],
    );
  }
}
