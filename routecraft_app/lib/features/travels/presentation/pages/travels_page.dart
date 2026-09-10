import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/presentation/controllers/travels_controller.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/utils/travel_status_mapping.dart';
import 'package:routecraft_app/shared/widgets/empty_state_view.dart';
import 'package:routecraft_app/shared/widgets/travel_card.dart';

class TravelsPage extends StatelessWidget {
  const TravelsPage({super.key, this.controller});

  /// Injectable for widget tests with a fixed state, without depending on
  /// the real network/singleton wiring. In production, the call site
  /// (`TravelsPage()`) is unaffected — the default wiring is used.
  final TravelsController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller ?? TravelsController(),
      child: const _TravelsView(),
    );
  }
}

class _TravelsView extends StatelessWidget {
  const _TravelsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<TravelsController>().state;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.visualizationTitle)),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.isError
              ? _TravelsError(onRetry: () => context.read<TravelsController>().retry())
              : state.isEmpty
                  ? const _EmptyTravels()
                  : _TravelsListView(state: state),
      floatingActionButton: (state.isLoading || state.isError || state.isEmpty)
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _pushAndRefresh(context, AppRoutes.travelsCreateRoute),
              icon: const Icon(Icons.add),
              label: Text(l10n.createRouteNav),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
    );
  }
}

/// Awaits the push before refreshing — the shell keeps [TravelsController]
/// alive across navigation, so a route created in the child screen would
/// otherwise never show up back on Viagens.
Future<void> _pushAndRefresh(BuildContext context, String location, {Object? extra}) async {
  await context.push(location, extra: extra);
  if (context.mounted) {
    context.read<TravelsController>().refresh();
  }
}

class _TravelsError extends StatelessWidget {
  const _TravelsError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return SafeArea(
      child: EmptyStateView(
        icon: Icons.error_outline,
        title: l10n.networkErrorTitle,
        message: l10n.networkErrorMessage,
        ctaLabel: l10n.networkErrorRetryCta,
        onCtaPressed: onRetry,
      ),
    );
  }
}

class _EmptyTravels extends StatelessWidget {
  const _EmptyTravels();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return EmptyStateView(
      icon: Icons.auto_awesome_outlined,
      title: l10n.noTravelsYet,
      message: l10n.homeEmptyMessage,
      ctaLabel: l10n.homeEmptyCta,
      onCtaPressed: () => _pushAndRefresh(context, AppRoutes.travelsCreateRoute),
    );
  }
}

/// Search field + status filter chips + the (filtered) travel list — split
/// out from [_TravelsView] so it only rebuilds/exists once there's actually
/// a non-empty travel list to search/filter.
class _TravelsListView extends StatelessWidget {
  const _TravelsListView({required this.state});

  final TravelsState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.read<TravelsController>();
    final filtered = state.filteredTravels;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: TextField(
            decoration: InputDecoration(
              hintText: l10n.travelsSearchHint,
              prefixIcon: const Icon(Icons.search),
              isDense: true,
              border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(12))),
            ),
            onChanged: controller.setSearchQuery,
          ),
        ),
        _StatusFilterChips(selected: state.statusFilter, onSelected: controller.setStatusFilter),
        const SizedBox(height: 8),
        Expanded(
          child: state.hasNoResults
              ? EmptyStateView(
                  icon: Icons.search_off,
                  title: l10n.noTravelsYet,
                  message: l10n.travelsNoResultsMessage,
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final travel = filtered[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TravelCard(
                        travelName: travel.travelName,
                        route: travelRouteText(travel),
                        period: travelPeriodText(context, travel),
                        status: travelStatusChipVariant(travel.travelStatus),
                        onTap: () => context.go(
                          '${AppRoutes.homeFollowTravel}?${AppRoutes.travelIdQuery(travel.backEndId!)}',
                          extra: travel,
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class _StatusFilterChips extends StatelessWidget {
  const _StatusFilterChips({required this.selected, required this.onSelected});

  final TravelStatus? selected;
  final ValueChanged<TravelStatus?> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final options = <(TravelStatus?, String)>[
      (null, l10n.travelsFilterAll),
      (TravelStatus.routeCreated, l10n.travelStatusRouteCreated),
      (TravelStatus.itineraryCreated, l10n.travelStatusItineraryCreated),
      (TravelStatus.travelStarted, l10n.travelStatusTravelStarted),
      (TravelStatus.travelFinished, l10n.travelStatusTravelFinished),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        key: const Key('travelsStatusFilterChips'),
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: options.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (status, label) = options[index];
          return ChoiceChip(
            label: Text(label),
            selected: selected == status,
            onSelected: (_) => onSelected(status),
          );
        },
      ),
    );
  }
}
