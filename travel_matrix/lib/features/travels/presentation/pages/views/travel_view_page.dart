import 'package:flutter/material.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/travel_view_app_bar.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/travel_view_body.dart';

/// Travel View Page — divided into Route View and Itinerary View tabs.
///
/// This is a "dumb" screen that consumes a [TravelViewModel] representing
/// the travel entity. It delegates the UI to [TravelViewAppBar] and [TravelViewBody].
///
/// Layout: Scaffold with an AppBar and a Body with Tabs.
class TravelViewPage extends StatelessWidget {
  const TravelViewPage({super.key, required this.travel});

  final TravelViewModel travel;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: TravelViewAppBar(
            travel: travel,
          ),
          body: TravelViewBody(
              travel: travel
          ),
        )
    );
  }
}

