import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/itinerary_hub/presentation/pages/itinerary_hub_page.dart';
import 'package:routecraft_app/features/itinerary_timeline/presentation/pages/itinerary_timeline_page.dart'
    show buildDayItineraries;
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/utils/date_formatting.dart';
import 'package:routecraft_app/shared/utils/step_icon_mapping.dart';
import 'package:routecraft_app/shared/widgets/app_button.dart';
import 'package:routecraft_app/shared/widgets/step_icon.dart';

/// Real-time "Today" tracking view for an in-progress trip — wireframe 1g,
/// DESIGN.md §4's "My Itinerary". The focused step reuses [nextUpcomingStep]
/// (CPS-90) — derived from `ItineraryStep.finished`, never from
/// `travelStatus`, since no backend endpoint triggers
/// `travel_started`/`travel_finished`. Falls back to [ItineraryHubPage] when
/// there's no selected trip, no itinerary yet, or `now` falls outside the
/// trip's date range.
class ItineraryTodayPage extends StatelessWidget {
  const ItineraryTodayPage({super.key, required this.travel, this.now});

  final Travel? travel;

  /// Injectable clock for tests; defaults to [DateTime.now] in production.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    final travel = this.travel;
    final itinerary = travel?.itinerary;
    if (travel == null || itinerary == null) {
      return ItineraryHubPage(travel: travel);
    }

    final clock = now ?? DateTime.now();
    final today = buildTodayItinerary(
      tripStart: travel.routePlan.startDate,
      tripEnd: travel.routePlan.endDate,
      steps: itinerary.itinerarySteps,
      now: clock,
    );
    if (today == null) {
      return ItineraryHubPage(travel: travel);
    }

    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.itineraryLabel)),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.todayDayProgress(today.dayNumber, today.totalDays),
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
              const SizedBox(height: 4),
              Text(l10n.todayInProgressLabel, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              if (today.focusedStep != null) _FocusedStepCard(step: today.focusedStep!, now: clock),
              if (today.otherStepsToday.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  l10n.todayAfterThatLabel,
                  style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                ),
                const SizedBox(height: 8),
                for (final step in today.otherStepsToday) ...[
                  _OtherStepTile(step: step),
                  const SizedBox(height: 8),
                ],
              ],
              const SizedBox(height: 24),
              SizedBox(
                height: 50,
                child: AppButton(
                  onPressed: () => _openFullItinerary(context, travel),
                  child: Text(l10n.hubOpenFullItineraryButton),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FocusedStepCard extends StatelessWidget {
  const _FocusedStepCard({required this.step, required this.now});

  final ItineraryStep step;
  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final address = switch (step) { Hosting(:final address) => address, _ => null };

    return Card(
      margin: EdgeInsets.zero,
      color: theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              now.isBefore(step.startDate)
                  ? l10n.todayStartsIn(formatDuration(step.startDate.difference(now)))
                  : l10n.todayHappeningNow,
              style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                StepIcon(type: stepIconType(step)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(step.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                      Text(
                        '${formatTime(step.startDate)} – ${formatTime(step.finishDate)}',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                      if (address != null)
                        Text(
                          '${l10n.todayAddressLabel}: $address',
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
                child: Text(l10n.todayViewStepCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtherStepTile extends StatelessWidget {
  const _OtherStepTile({required this.step});

  final ItineraryStep step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final done = step.finished;
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: done ? 0.5 : 0.8);

    return Row(
      children: [
        Icon(
          done ? Icons.check_circle : Icons.circle_outlined,
          size: 20,
          color: done ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            step.title,
            style: theme.textTheme.bodyMedium
                ?.copyWith(color: mutedColor, decoration: done ? TextDecoration.lineThrough : null),
          ),
        ),
        Text(formatTime(step.startDate), style: theme.textTheme.bodySmall?.copyWith(color: mutedColor)),
      ],
    );
  }
}

// ponytail: `_showComingSoon` mirrors the exact stub the timeline page used
// before CPS-92 built the real step-detail sheet — CPS-93 doesn't depend on
// CPS-92, so this stub is the honest interim state, not a shortcut. Upgrade:
// wire to CPS-92's `StepDetailSheet` once that branch merges.
void _showComingSoon(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoonMessage)));
}

void _openFullItinerary(BuildContext context, Travel travel) {
  final currentLocation = GoRouterState.of(context).matchedLocation;
  context.push(
    '$currentLocation/${AppRoutes.itineraryTimeline}?${AppRoutes.travelIdQuery(travel.backEndId!)}',
    extra: travel,
  );
}

@immutable
class TodayItinerary {
  const TodayItinerary({
    required this.dayNumber,
    required this.totalDays,
    required this.focusedStep,
    required this.otherStepsToday,
  });

  /// 1-based position of `now`'s calendar day within the trip.
  final int dayNumber;
  final int totalDays;

  /// The earliest unfinished step in the whole itinerary — may belong to a
  /// later day than today's, when every one of today's steps is done.
  final ItineraryStep? focusedStep;

  /// Today's steps other than [focusedStep], in start-time order.
  final List<ItineraryStep> otherStepsToday;
}

/// `null` when `now`'s calendar day falls outside [tripStart]/[tripEnd] —
/// the caller should fall back to [ItineraryHubPage].
TodayItinerary? buildTodayItinerary({
  required DateTime tripStart,
  required DateTime tripEnd,
  required List<ItineraryStep> steps,
  required DateTime now,
}) {
  final days = buildDayItineraries(tripStart: tripStart, tripEnd: tripEnd, steps: steps);
  final today = DateTime(now.year, now.month, now.day);
  final todayIndex = days.indexWhere((d) => d.day == today);
  if (todayIndex == -1) return null;

  final focusedStep = nextUpcomingStep(steps);
  final otherStepsToday = [...days[todayIndex].steps]..remove(focusedStep);

  return TodayItinerary(
    dayNumber: todayIndex + 1,
    totalDays: days.length,
    focusedStep: focusedStep,
    otherStepsToday: otherStepsToday,
  );
}
