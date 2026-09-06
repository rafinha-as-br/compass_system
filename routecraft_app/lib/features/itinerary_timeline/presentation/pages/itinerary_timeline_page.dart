import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/travels/domain/entities/itinerary_step.dart';
import 'package:routecraft_app/features/travels/domain/entities/transport.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/utils/date_formatting.dart';
import 'package:routecraft_app/shared/utils/step_icon_mapping.dart';
import 'package:routecraft_app/shared/widgets/empty_state_view.dart';
import 'package:routecraft_app/shared/widgets/step_icon.dart';

/// Read-only, day-paginated view of a trip's full itinerary — wireframe 1f.
/// Building/reordering steps stays exclusive to the agent in Travel Matrix;
/// this page only lays out what the agent already published, one day at a
/// time, including the free-time gaps between steps. Tapping a step is a
/// stub for now — the step-detail screen is CPS-92, not yet built.
class ItineraryTimelinePage extends StatefulWidget {
  const ItineraryTimelinePage({super.key, required this.travel});

  final Travel? travel;

  @override
  State<ItineraryTimelinePage> createState() => _ItineraryTimelinePageState();
}

class _ItineraryTimelinePageState extends State<ItineraryTimelinePage> {
  int _selectedDay = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final travel = widget.travel;
    final itinerary = travel?.itinerary;

    if (travel == null || itinerary == null) {
      return Scaffold(
        body: SafeArea(
          child: EmptyStateView(
            icon: Icons.map_outlined,
            title: l10n.hubEmptyTitle,
            message: l10n.hubEmptyMessage,
            ctaLabel: l10n.hubGoToHomeCta,
            onCtaPressed: () => context.go(AppRoutes.home),
          ),
        ),
      );
    }

    final days = buildDayItineraries(
      tripStart: travel.routePlan.startDate,
      tripEnd: travel.routePlan.endDate,
      steps: itinerary.itinerarySteps,
    );
    final selectedIndex = _selectedDay.clamp(0, days.length - 1);
    final selectedDay = days[selectedIndex];
    final languageCode = Localizations.localeOf(context).languageCode;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.itineraryLabel)),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    travel.travelName,
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    formatDateRange(languageCode, travel.routePlan.startDate, travel.routePlan.endDate),
                    style: theme.textTheme.bodyMedium
                        ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ),
            ),
            _DayChipStrip(
              days: days,
              selectedIndex: selectedIndex,
              onSelected: (index) => setState(() => _selectedDay = index),
            ),
            Expanded(child: _DayAgenda(day: selectedDay, languageCode: languageCode)),
            _DayNavigationBar(
              canGoBack: selectedIndex > 0,
              canGoForward: selectedIndex < days.length - 1,
              onBack: () => setState(() => _selectedDay = selectedIndex - 1),
              onForward: () => setState(() => _selectedDay = selectedIndex + 1),
            ),
          ],
        ),
      ),
    );
  }
}

// ponytail: a plain scrollable chip strip instead of a fixed-N-then-"+X"
// overflow pill — every day is reachable by scrolling, nothing is ever cut
// off mid-chip, and it needs no width measurement/state. Upgrade: add an
// explicit "+N" trailing pill if Rafinha wants the exact wireframe visual.
class _DayChipStrip extends StatelessWidget {
  const _DayChipStrip({required this.days, required this.selectedIndex, required this.onSelected});

  final List<DayItinerary> days;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return ChoiceChip(
            label: Text('D${days[index].dayNumber}'),
            selected: index == selectedIndex,
            onSelected: (_) => onSelected(index),
          );
        },
      ),
    );
  }
}

class _DayAgenda extends StatelessWidget {
  const _DayAgenda({required this.day, required this.languageCode});

  final DayItinerary day;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${l10n.timelineDayLabel(day.dayNumber)} · ${weekdayName(languageCode, day.day.weekday)}',
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          Text(l10n.stepsCount(day.steps.length), style: mutedStyle),
          const SizedBox(height: 16),
          if (day.steps.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(l10n.timelineNoStepsForDay, style: mutedStyle),
            )
          else
            for (final step in day.steps) ...[
              _StepTile(step: step),
              const SizedBox(height: 12),
            ],
          if (day.freeTimeUntil != null)
            _FreeTimeBlock(dayOfBlock: day.day, until: day.freeTimeUntil!, languageCode: languageCode),
        ],
      ),
    );
  }
}

class _StepTile extends StatelessWidget {
  const _StepTile({required this.step});

  final ItineraryStep step;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final keyInfo = _keyInfoLine(step, l10n);

    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: () => _showComingSoon(context),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              StepIcon(type: stepIconType(step)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formatTime(step.startDate),
                      style: theme.textTheme.labelMedium
                          ?.copyWith(color: theme.colorScheme.primary, fontWeight: FontWeight.w600),
                    ),
                    Text(step.title, style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                    if (keyInfo != null)
                      Text(
                        keyInfo,
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreeTimeBlock extends StatelessWidget {
  const _FreeTimeBlock({required this.dayOfBlock, required this.until, required this.languageCode});

  final DateTime dayOfBlock;
  final DateTime until;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(Icons.schedule_outlined, size: 18, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _freeTimeLabel(l10n, languageCode, dayOfBlock, until),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DayNavigationBar extends StatelessWidget {
  const _DayNavigationBar({
    required this.canGoBack,
    required this.canGoForward,
    required this.onBack,
    required this.onForward,
  });

  final bool canGoBack;
  final bool canGoForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: canGoBack ? onBack : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [const Icon(Icons.chevron_left), Text(l10n.timelinePreviousDay)],
            ),
          ),
          TextButton(
            onPressed: canGoForward ? onForward : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [Text(l10n.timelineNextDay), const Icon(Icons.chevron_right)],
            ),
          ),
        ],
      ),
    );
  }
}

void _showComingSoon(BuildContext context) {
  final l10n = AppLocalizations.of(context)!;
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.comingSoonMessage)));
}

/// One calendar day of the trip: which steps are active that day (sorted by
/// `startDate`), and the trailing free-time gap to the next step overall,
/// when there is one.
@immutable
class DayItinerary {
  const DayItinerary({required this.day, required this.dayNumber, required this.steps, required this.freeTimeUntil});

  /// Midnight of this calendar day.
  final DateTime day;

  /// 1-based position within the trip (`D1`, `D2`, ...).
  final int dayNumber;

  final List<ItineraryStep> steps;

  /// When the day's last activity ends before the next step in the whole
  /// itinerary starts (possibly on a later day), this is that next step's
  /// start. `null` when there's no gap or this day has no later step at all.
  final DateTime? freeTimeUntil;
}

/// Buckets [steps] by every calendar day from [tripStart] to [tripEnd]
/// (inclusive) — a multi-day step (e.g. a multi-night `Hosting`) appears on
/// every day it spans, not just the day it starts.
///
/// ponytail: the trailing free-time gap is computed from the day's
/// latest-finishing step to the next step overall by start date; it does not
/// model gaps *between* two steps on the same day (only shown in the
/// wireframe as a single block after the day's last activity). Upgrade: a
/// full per-slot gap list if a design ever calls for showing every gap.
List<DayItinerary> buildDayItineraries({
  required DateTime tripStart,
  required DateTime tripEnd,
  required List<ItineraryStep> steps,
}) {
  final firstDay = _dateOnly(tripStart);
  final lastDay = _dateOnly(tripEnd);
  final totalDays = lastDay.difference(firstDay).inDays + 1;
  final sortedSteps = [...steps]..sort((a, b) => a.startDate.compareTo(b.startDate));

  return List.generate(totalDays, (index) {
    final day = firstDay.add(Duration(days: index));
    final nextDayStart = day.add(const Duration(days: 1));
    final stepsForDay = sortedSteps
        .where((s) => _dateOnly(s.startDate).isBefore(nextDayStart) && !_dateOnly(s.finishDate).isBefore(day))
        .toList();

    DateTime? freeTimeUntil;
    if (stepsForDay.isNotEmpty) {
      final lastStep = stepsForDay.reduce((a, b) => a.finishDate.isAfter(b.finishDate) ? a : b);
      for (final candidate in sortedSteps) {
        if (candidate.startDate.isAfter(lastStep.finishDate)) {
          freeTimeUntil = candidate.startDate;
          break;
        }
      }
    }

    return DayItinerary(day: day, dayNumber: index + 1, steps: stepsForDay, freeTimeUntil: freeTimeUntil);
  });
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

String? _keyInfoLine(ItineraryStep step, AppLocalizations l10n) => switch (step) {
      TravelSegment(:final transport) => switch (transport) {
          Airplane(:final flightNumber) => '${_formatDuration(step)} · $flightNumber',
          RentalCar() => '${l10n.timelineRentalCarLabel} · ${_formatDuration(step)}',
          Bus(:final travelCompany) => '$travelCompany · ${_formatDuration(step)}',
          _ => _formatDuration(step),
        },
      Hosting(:final address) => address,
      Stop(:final description) => description.isEmpty ? null : description,
      PlaceholderStep(:final description) => description.isEmpty ? null : description,
      _ => null,
    };

String _formatDuration(ItineraryStep step) {
  final duration = step.finishDate.difference(step.startDate);
  final hours = duration.inHours;
  final minutes = duration.inMinutes % 60;
  if (hours <= 0) return '${minutes}min';
  if (minutes == 0) return '${hours}h';
  return '${hours}h${minutes.toString().padLeft(2, '0')}';
}

String _freeTimeLabel(AppLocalizations l10n, String languageCode, DateTime dayOfBlock, DateTime until) {
  final untilDay = _dateOnly(until);
  final time = formatTime(until);

  final String untilLabel;
  if (untilDay == dayOfBlock) {
    untilLabel = time;
  } else if (untilDay.difference(dayOfBlock).inDays == 1) {
    untilLabel = '${l10n.timelineTomorrow} $time';
  } else {
    untilLabel = '${formatDate(languageCode, until)} $time';
  }
  return l10n.timelineFreeTimeUntil(untilLabel);
}
