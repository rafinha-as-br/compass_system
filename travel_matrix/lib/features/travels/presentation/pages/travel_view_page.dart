import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/travel_view_app_bar.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/travel_view_body.dart';

/// Travel View Page — divided into Route View and Itinerary View tabs.
///

/* Travel View Page — divided into Route View and Itinerary View tabs. It consumes
* a travel from a provider

* */
class TravelViewPage extends StatelessWidget {
  const TravelViewPage({super.key, required this.travel});

  final Travel travel;

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

