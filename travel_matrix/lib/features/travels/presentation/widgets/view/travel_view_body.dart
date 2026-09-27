import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/itinerary_view_tab.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/overview_view_tab.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/participants_view_tab.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/route_view_tab.dart';

/// Body for the Travel View Page.
///
/// Consumes a [TravelViewModel] and displays the [OverviewViewTab],
/// [RouteViewTab], [ItineraryViewTab] or [ParticipantsViewTab] depending on
/// the selected tab in the AppBar.
///
/// Layout: TabBarView containing the overview, route, itinerary and
/// participants views.
class TravelViewBody extends StatelessWidget {
  const TravelViewBody({super.key, required this.travel, this.onTravelUpdated});

  final TravelViewModel travel;

  /// Forwarded to [ParticipantsViewTab] — called after a successful
  /// add/remove so the header count and this tab's list stay in sync.
  final ValueChanged<TravelViewModel>? onTravelUpdated;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: TabBarView(
        children: [
          OverviewViewTab(travel: travel),
          RouteViewTab(travel: travel),
          ItineraryViewTab(travel: travel),
          ParticipantsViewTab(travel: travel, onTravelUpdated: onTravelUpdated),
        ],
      ),
    );
  }
}
