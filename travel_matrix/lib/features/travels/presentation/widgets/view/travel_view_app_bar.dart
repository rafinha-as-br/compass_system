import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';

/*
* This appBar is used in the Travel_View_page, responsible for showing:
* - Travel Name
* - Travel Status (right next to the travel name)
* - Travel Start and Finish Date
* - Number of Travelers
* */
class TravelViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TravelViewAppBar({super.key, required this.travel,});
  final Travel travel;

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
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
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
                      travel.travelName,
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
                      color: getTravelStatusColor(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      getTravelStatus(),
                      style: TextStyle(
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
                        '${travel.routePlan.startDate.month}'
                            '/${travel.routePlan.startDate.day}'
                            ' - ${travel.routePlan.endDate.month}'
                            '/${travel.routePlan.endDate.day}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5B6E8C),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline,
                        size: 14,
                        color: Color(0xFF8E9AAB),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${travel.participantsList.length} Travelers',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF5B6E8C),
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(170);

  String getTravelStatus() {
    switch(travel.travelStatus){
      case TravelStatus.routeCreated:
        return 'Travel not ready';
      case TravelStatus.itineraryCreated :
        return 'Travel ready';
      case TravelStatus.travelStarted:
        return 'Travel Started';
      case TravelStatus.travelFinished:
        return 'Travel Completed';
    }
  }
  Color getTravelStatusColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    switch (travel.travelStatus) {
      case TravelStatus.routeCreated:
        return scheme.outlineVariant;

      case TravelStatus.itineraryCreated:
        return scheme.tertiaryContainer;

      case TravelStatus.travelStarted:
        return scheme.primaryContainer;

      case TravelStatus.travelFinished:
        return scheme.secondaryContainer;
    }
  }

}
