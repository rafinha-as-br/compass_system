import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/pages/builds/travel_creation_page.dart';
import 'package:travel_matrix/features/travels/presentation/pages/views/travel_view_page.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// Travels Dashboard Tab — lists all travels with state indicator.
///
/// This is the main entry point to view travels. It consumes the [TravelsController]
/// to load and present a list of [TravelViewModel] items.
class TravelsDashboardPage extends StatelessWidget {
  const TravelsDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TravelsController(),
      child: const _TravelsDashboardView(),
    );
  }
}

class _TravelsDashboardView extends StatelessWidget {
  const _TravelsDashboardView();

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TravelsController>();
    final state = controller.state;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.allTravels,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ChangeNotifierProvider.value(
                        value: controller,
                        child: const TravelCreationPage(),
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.createTravel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.secondary,
                  foregroundColor: theme.colorScheme.onSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (state.errorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                state.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ),
          Expanded(
            child: state.isLoading
                ? const Center(child: CircularProgressIndicator())
                : state.travels.isEmpty
                    ? Center(
                        child: Text(
                          l10n.noTravelsCreated,
                          style: TextStyle(
                            color: theme.colorScheme.onSurface
                                .withValues(alpha: 0.6),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: state.travels.length,
                        itemBuilder: (context, index) {
                          final travel = state.travels[index];
                          return _buildTravelCard(
                              context, travel, controller, l10n);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelCard(
    BuildContext context,
    TravelViewModel travel,
    TravelsController controller,
    AppLocalizations l10n,
  ) {

    final hasItinerary = travel.itinerary != null;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: hasItinerary
              ? TravelAppColors.success.withValues(alpha: 0.15)
              : TravelAppColors.warning.withValues(alpha: 0.15),
          child: Icon(
            hasItinerary ? Icons.check : Icons.map,
            color: hasItinerary
                ? TravelAppColors.success
                : TravelAppColors.warning,
          ),
        ),
        title: Text(
          travel.travelTitle,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          '${travel.route.start} ➔ ${travel.route.destination}\n'
          '${l10n.clientLabel}: ${travel.clientName}',
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: hasItinerary
                    ? TravelAppColors.success.withValues(alpha: 0.1)
                    : TravelAppColors.warning.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                hasItinerary ? l10n.itineraryReady : l10n.routeOnly,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: hasItinerary
                      ? TravelAppColors.success
                      : TravelAppColors.warning,
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.chevron_right),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChangeNotifierProvider.value(
                      value: controller,
                      child: TravelViewPage(travel: travel),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => ChangeNotifierProvider.value(
                value: controller,
                child: TravelViewPage(travel: travel),
              ),
            ),
          );
        },
      ),
    );
  }
}

