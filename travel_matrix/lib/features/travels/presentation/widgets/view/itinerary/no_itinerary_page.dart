import 'package:flutter/material.dart';
import 'package:mock_repository/mock_repository.dart';
import 'package:provider/provider.dart';

import '../../../controllers/travels_controller.dart';
import '../../../pages/builds/itinerary_creation_page.dart';

class NoItineraryPage extends StatelessWidget {
  const NoItineraryPage({super.key, required this.travel});
  final Travel travel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_note, size: 64,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.3)),
          const SizedBox(height: 16),
          Text(
            'No itinerary has been created yet.',
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              final controller = context.read<TravelsController>();
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChangeNotifierProvider.value(
                    value: controller,
                    child: ItineraryCreationPage(travel: travel),
                  ),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Itinerary'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
