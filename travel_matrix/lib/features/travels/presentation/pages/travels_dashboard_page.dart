import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

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

class _TravelsDashboardView extends StatefulWidget {
  const _TravelsDashboardView();

  @override
  State<_TravelsDashboardView> createState() => _TravelsDashboardViewState();
}

class _TravelsDashboardViewState extends State<_TravelsDashboardView> {
  String _searchQuery = '';
  _TravelFilter _filter = _TravelFilter.all;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TravelsController>();
    final state = controller.state;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final filteredTravels = _filteredTravels(state.travels);

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
                  context.go(
                    '${AppRoutes.travels}/${AppRoutes.travelCreate}',
                    extra: {'controller': controller},
                  );
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.createTravel),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                flex: 2,
                child: TextField(
                  decoration: InputDecoration(
                    hintText: l10n.searchTravelsHint,
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onChanged: (value) {
                    setState(() => _searchQuery = value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              SizedBox(
                width: 220,
                child: DropdownButtonFormField<_TravelFilter>(
                  initialValue: _filter,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12),
                  ),
                  items: [
                    DropdownMenuItem(
                      value: _TravelFilter.all,
                      child: Text(l10n.allStatus),
                    ),
                    DropdownMenuItem(
                      value: _TravelFilter.routeOnly,
                      child: Text(l10n.routeOnly),
                    ),
                    DropdownMenuItem(
                      value: _TravelFilter.itineraryReady,
                      child: Text(l10n.itineraryReady),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _filter = value ?? _TravelFilter.all);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
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
                : filteredTravels.isEmpty
                ? Center(
                    child: Text(
                      l10n.noTravelsCreated,
                      style: TextStyle(
                        color: theme.colorScheme.onSurface.withValues(
                          alpha: 0.6,
                        ),
                      ),
                    ),
                  )
                : Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: _TravelsTable(
                      travels: filteredTravels,
                      controller: controller,
                      l10n: l10n,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  List<TravelViewModel> _filteredTravels(List<TravelViewModel> travels) {
    final query = _searchQuery.trim().toLowerCase();
    return travels.where((travel) {
      final matchesSearch =
          query.isEmpty ||
          travel.travelTitle.toLowerCase().contains(query) ||
          travel.clientName.toLowerCase().contains(query) ||
          travel.route.destination.toLowerCase().contains(query);

      final matchesFilter = switch (_filter) {
        _TravelFilter.all => true,
        _TravelFilter.routeOnly => travel.itinerary == null,
        _TravelFilter.itineraryReady => travel.itinerary != null,
      };

      return matchesSearch && matchesFilter;
    }).toList();
  }
}

class _TravelsTable extends StatelessWidget {
  final List<TravelViewModel> travels;
  final TravelsController controller;
  final AppLocalizations l10n;

  const _TravelsTable({
    required this.travels,
    required this.controller,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(l10n.localeName);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: constraints.maxWidth),
            child: DataTable(
              headingRowColor: WidgetStatePropertyAll(
                theme.colorScheme.surfaceContainerHighest,
              ),
              dataRowMaxHeight: 68,
              dataRowMinHeight: 56,
              columns: [
                DataColumn(label: Text(l10n.travelNameColumn)),
                DataColumn(label: Text(l10n.clientLabel)),
                DataColumn(label: Text(l10n.routeColumn)),
                DataColumn(label: Text(l10n.statusColumn)),
                DataColumn(label: Text(l10n.datesColumn)),
                DataColumn(label: Text(l10n.actionsColumn)),
              ],
              rows: travels.map((travel) {
                final dates =
                    '${dateFormat.format(travel.route.startDate)} - ${dateFormat.format(travel.route.endDate)}';
                return DataRow(
                  cells: [
                    DataCell(Text(travel.travelTitle)),
                    DataCell(Text(travel.clientName)),
                    DataCell(
                      Text(
                        '${travel.route.start} -> ${travel.route.destination}',
                      ),
                    ),
                    DataCell(_TravelStatusChip(travel: travel, l10n: l10n)),
                    DataCell(Text(dates)),
                    DataCell(
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        tooltip: l10n.viewTravel,
                        onPressed: () {
                          context.go(
                            '${AppRoutes.travels}/${travel.localId}',
                            extra: {'travel': travel, 'controller': controller},
                          );
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}

class _TravelStatusChip extends StatelessWidget {
  final TravelViewModel travel;
  final AppLocalizations l10n;

  const _TravelStatusChip({required this.travel, required this.l10n});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final hasItinerary = travel.itinerary != null;
    final color = hasItinerary ? semantic.success : semantic.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        hasItinerary ? l10n.itineraryReady : l10n.routeOnly,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

enum _TravelFilter { all, routeOnly, itineraryReady }
