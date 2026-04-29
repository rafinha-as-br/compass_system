import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:mock_repository/mock_repository.dart';

import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/pages/travel_views/a.dart';
import 'package:travel_matrix/features/travels/presentation/pages/travel_views/itinerary_view_tab.dart';
import 'package:travel_matrix/features/travels/presentation/pages/travel_views/route_view_tab.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/itinerary/itinerary_timeline.dart';
import 'package:travel_matrix/features/travels/presentation/pages/itinerary_creation_page.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/travel_view_app_bar.dart';
import 'package:travel_matrix/features/travels/presentation/widgets/view/travel_view_body.dart';

/// Travel View Page — divided into Route View and Itinerary View tabs.
class TravelViewPage extends StatefulWidget {
  final Travel travel;

  const TravelViewPage({super.key, required this.travel});

  @override
  State<TravelViewPage> createState() => _TravelViewPageState();
}

class _TravelViewPageState extends State<TravelViewPage> with SingleTickerProviderStateMixin{
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: TravelViewAppBar(
        travel: widget.travel,
      ),
      body: TravelViewBody(
          tabController: _tabController,
          travel: widget.travel
      ),
    );
  }

}

