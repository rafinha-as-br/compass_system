import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/route.dart';
import 'package:routecraft_app/features/travels/domain/entities/transport.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/utils/date_formatting.dart';
import 'package:routecraft_app/shared/widgets/app_button.dart';
import 'package:routecraft_app/shared/widgets/empty_state_view.dart';
import 'package:routecraft_app/shared/widgets/step_icon.dart';
import 'package:routecraft_app/shared/widgets/travel_status_chip.dart';

/// Entry point for a selected trip's itinerary — same layout for both
/// `travelStatus` states (no itinerary yet vs. itinerary published), per
/// wireframe 1d. Absence of an itinerary is the normal starting state of
/// every trip, not an error or edge case.
class ItineraryHubPage extends StatelessWidget {
  const ItineraryHubPage({super.key, required this.travel});

  final Travel? travel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final travel = this.travel;

    return Scaffold(
      body: SafeArea(
        child: travel == null
            ? EmptyStateView(
                icon: Icons.map_outlined,
                title: l10n.hubEmptyTitle,
                message: l10n.hubEmptyMessage,
                ctaLabel: l10n.hubGoToHomeCta,
                onCtaPressed: () => context.go(AppRoutes.home),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _HubHeader(travel: travel),
                    const SizedBox(height: 24),
                    if (travel.hasItinerary)
                      _ItineraryCreatedBody(travel: travel)
                    else
                      _RouteCreatedBody(travel: travel),
                  ],
                ),
              ),
      ),
    );
  }
}

class _HubHeader extends StatelessWidget {
  const _HubHeader({required this.travel});

  final Travel travel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.hubTitle,
                style: theme.textTheme.labelLarge
                    ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              Text(travel.travelName, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
        ),
        TravelStatusChip(status: _chipVariant(travel.travelStatus)),
      ],
    );
  }
}

/// `route_created` — no itinerary yet. Deliberately offers no way to create
/// or edit itinerary steps: that stays exclusive to the agent in Travel
/// Matrix. The wireframe's "Falar com meu agente" button is left out — the
/// backend has no messaging channel to back it (out of scope this sprint).
class _RouteCreatedBody extends StatelessWidget {
  const _RouteCreatedBody({required this.travel});

  final Travel travel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.hourglass_top_outlined, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(l10n.hubAwaitingAgentTitle, style: theme.textTheme.bodyLarge),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _RouteSummaryBlock(
          label: l10n.hubWhatYouAskedLabel,
          routePlan: travel.routePlan,
          trailing: TextButton(
            onPressed: () => _showComingSoon(context),
            child: Text(l10n.hubEditRouteLink),
          ),
        ),
      ],
    );
  }
}

/// `itinerary_created` (and beyond — `hasItinerary` covers every status past
/// `routeCreated`): next-step preview, quick counters and the route summary.
class _ItineraryCreatedBody extends StatelessWidget {
  const _ItineraryCreatedBody({required this.travel});

  final Travel travel;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final steps = travel.itinerary?.itinerarySteps ?? const [];
    final next = nextUpcomingStep(steps);
    final nights = travel.routePlan.endDate.difference(travel.routePlan.startDate).inDays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (next != null) ...[
          _NextStepCard(step: next),
          const SizedBox(height: 24),
        ],
        Row(
          children: [
            Expanded(child: _CounterBlock(label: l10n.hubStepsLabel, value: steps.length)),
            const SizedBox(width: 16),
            Expanded(child: _CounterBlock(label: l10n.hubNightsLabel, value: nights)),
          ],
        ),
        const SizedBox(height: 24),
        _RouteSummaryBlock(label: l10n.hubRouteSummaryLabel, routePlan: travel.routePlan),
        const SizedBox(height: 24),
        SizedBox(
          height: 50,
          child: AppButton(
            onPressed: () => _showComingSoon(context),
            child: Text(l10n.hubOpenFullItineraryButton),
          ),
        ),
      ],
    );
  }
}

class _NextStepCard extends StatelessWidget {
  const _NextStepCard({required this.step});

  final ItineraryStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;
    final daysUntil = _calendarDaysUntil(step.startDate);

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.hubNextStepLabel} · ${daysUntil <= 0 ? l10n.hubToday : l10n.hubInDaysCount(daysUntil)}',
              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                StepIcon(type: _stepIconType(step)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        formatDate(languageCode, step.startDate),
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => _showComingSoon(context),
                child: Text(l10n.hubViewDetailsLink),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CounterBlock extends StatelessWidget {
  const _CounterBlock({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('$value', style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
            Text(
              label,
              style:
                  theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ),
    );
  }
}

class _RouteSummaryBlock extends StatelessWidget {
  const _RouteSummaryBlock({required this.label, required this.routePlan, this.trailing});

  final String label;
  final RoutePlan routePlan;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final languageCode = Localizations.localeOf(context).languageCode;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style:
                  theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 8),
            Text(
              '${routePlan.startLocation} → ${routePlan.destination}',
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            Text(
              '${formatDateRange(languageCode, routePlan.startDate, routePlan.endDate)} · '
              '${l10n.hubInterestsCount(routePlan.interestsList.length)}',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            if (trailing != null) ...[
              const SizedBox(height: 4),
              Align(alignment: Alignment.centerRight, child: trailing!),
            ],
          ],
        ),
      ),
    );
  }
}

void _showComingSoon(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.hubComingSoon)));
}

TravelStatusChipVariant _chipVariant(TravelStatus status) => switch (status) {
      TravelStatus.routeCreated => TravelStatusChipVariant.routeCreated,
      TravelStatus.itineraryCreated => TravelStatusChipVariant.itineraryCreated,
      TravelStatus.travelStarted => TravelStatusChipVariant.travelStarted,
      TravelStatus.travelFinished => TravelStatusChipVariant.travelFinished,
    };

StepIconType _stepIconType(ItineraryStep step) => switch (step) {
      Stop() => StepIconType.stop,
      Hosting() => StepIconType.hosting,
      TravelSegment(:final transport) => switch (transport) {
          Airplane() => StepIconType.airplane,
          Bus() => StepIconType.bus,
          RentalCar() => StepIconType.rentalCar,
          _ => StepIconType.boundary,
        },
      _ => StepIconType.boundary,
    };

/// The step the client should see next: the earliest unfinished step, or
/// `null` when every step is done. Computed locally from `startDate` rather
/// than relying on `travelStatus`, which has no automatic transition into
/// `travel_started`/`travel_finished` on the backend yet.
ItineraryStep? nextUpcomingStep(List<ItineraryStep> steps) {
  final upcoming = steps.where((s) => !s.finished).toList()..sort((a, b) => a.startDate.compareTo(b.startDate));
  return upcoming.isEmpty ? null : upcoming.first;
}

/// Whole calendar days between today and [target] — comparing dates, not a
/// raw 24h `Duration`, so a step tomorrow morning still reads as "in 1 day"
/// even when checked late today, instead of truncating to "today".
int _calendarDaysUntil(DateTime target) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final targetDay = DateTime(target.year, target.month, target.day);
  return targetDay.difference(today).inDays;
}
