import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// Read-only consolidated summary of the travel — route, status,
/// participants and itinerary — as the landing tab of `TravelViewPage`.
///
/// Consumes a [TravelViewModel]; every value is derived from it, no
/// separate loading state (the page already shows a central loader before
/// this tab is reachable).
class OverviewViewTab extends StatelessWidget {
  const OverviewViewTab({super.key, required this.travel});

  final TravelViewModel travel;

  /// Tab index of "Itinerário" within this issue's own TravelViewAppBar
  /// (Visão Geral=0, Roteiro=1, Itinerário=2).
  static const _itineraryTabIndex = 2;

  /// Tab index "Participantes" will occupy once CPS-159 lands (Visão
  /// Geral=0, Roteiro=1, Itinerário=2, Participantes=3). This branch alone
  /// only has 3 tabs, so [_goToTab] guards the index and the action below
  /// is a no-op until that tab exists.
  static const _participantsTabIndex = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isNarrow = constraints.maxWidth < 900;

        final routeCard = _RouteSummaryCard(travel: travel, l10n: l10n);
        final statusCard = _StatusCard(travel: travel, l10n: l10n);
        final participantsCard = _ParticipantsCard(
          travel: travel,
          l10n: l10n,
          onViewParticipants: () => _goToTab(context, _participantsTabIndex),
        );
        final itineraryCard = _ItinerarySummaryCard(
          travel: travel,
          l10n: l10n,
          onViewItinerary: () => _goToTab(context, _itineraryTabIndex),
        );

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 18 : 24,
            vertical: isNarrow ? 18 : 22,
          ),
          child: isNarrow
              ? Column(
                  children: [
                    routeCard,
                    const SizedBox(height: 12),
                    statusCard,
                    const SizedBox(height: 12),
                    participantsCard,
                    const SizedBox(height: 12),
                    itineraryCard,
                  ],
                )
              : Column(
                  children: [
                    routeCard,
                    const SizedBox(height: 16),
                    IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(child: statusCard),
                          const SizedBox(width: 16),
                          Expanded(child: participantsCard),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    itineraryCard,
                  ],
                ),
        );
      },
    );
  }

  static void _goToTab(BuildContext context, int index) {
    final controller = DefaultTabController.of(context);
    if (index < controller.length) {
      controller.animateTo(index);
    }
  }
}

/// Shared card chrome for every Overview block — radius 14, 1px outline,
/// no elevation, matching the app's existing Card theme.
class _OverviewCard extends StatelessWidget {
  const _OverviewCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        child: child,
      ),
    );
  }
}

class _CardLabel extends StatelessWidget {
  const _CardLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        letterSpacing: 1,
        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
      ),
    );
  }
}

class _RouteSummaryCard extends StatelessWidget {
  const _RouteSummaryCard({required this.travel, required this.l10n});

  final TravelViewModel travel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final route = travel.route;
    final dateFormat = DateFormat.yMMMd(l10n.localeName);
    final durationInDays = route.endDate.difference(route.startDate).inDays;

    return _OverviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel(l10n.overviewRouteLabel),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _RoutePoint(label: l10n.fromLabel, value: route.start),
              ),
              Icon(Icons.arrow_forward, size: 18, color: theme.colorScheme.primary),
              Expanded(
                child: _RoutePoint(
                  label: l10n.toLabel,
                  value: route.destination,
                  alignEnd: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _LabeledValue(label: l10n.startDateLabel, value: dateFormat.format(route.startDate)),
              ),
              Expanded(
                child: _LabeledValue(label: l10n.endDateLabel, value: dateFormat.format(route.endDate)),
              ),
              Expanded(
                child: _LabeledValue(
                  label: l10n.overviewDurationLabel,
                  value: l10n.overviewDurationInDays(durationInDays),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RoutePoint extends StatelessWidget {
  const _RoutePoint({required this.label, required this.value, this.alignEnd = false});

  final String label;
  final String value;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 11, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _LabeledValue extends StatelessWidget {
  const _LabeledValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 2),
        Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.travel, required this.l10n});

  final TravelViewModel travel;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = travel.status.color(theme);

    return _OverviewCard(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(_statusIcon(travel.status), color: color),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  travel.status.label(l10n),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  travel.status.supportLine(l10n),
                  style: TextStyle(
                    fontSize: 11.5,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _statusIcon(TravelStatusViewModel status) {
    switch (status) {
      case TravelStatusViewModel.notReady:
        return Icons.hourglass_empty;
      case TravelStatusViewModel.ready:
        return Icons.check_circle_outline;
      case TravelStatusViewModel.inProgress:
        return Icons.flight_takeoff;
      case TravelStatusViewModel.completed:
        return Icons.flag_outlined;
    }
  }
}

class _ParticipantsCard extends StatelessWidget {
  const _ParticipantsCard({
    required this.travel,
    required this.l10n,
    required this.onViewParticipants,
  });

  final TravelViewModel travel;
  final AppLocalizations l10n;
  final VoidCallback onViewParticipants;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final participants = travel.participants;
    final preview = participants.take(3).toList();
    final remaining = participants.length - preview.length;

    return _OverviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel(l10n.overviewParticipantsLabel),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                participants.length.toString(),
                style: const TextStyle(fontSize: 38, fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 8),
              Text(
                l10n.overviewParticipantsCaption,
                style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (preview.isNotEmpty)
            Row(
              children: [
                SizedBox(
                  height: 28,
                  child: Stack(
                    children: [
                      for (var i = 0; i < preview.length; i++)
                        Padding(
                          padding: EdgeInsets.only(left: i * 19.0),
                          child: _InitialsAvatar(name: preview[i].name),
                        ),
                    ],
                  ),
                ),
                if (remaining > 0) ...[
                  const SizedBox(width: 8),
                  Text(
                    l10n.overviewParticipantsMore(remaining),
                    style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                ],
              ],
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: onViewParticipants,
            style: TextButton.styleFrom(padding: EdgeInsets.zero, alignment: Alignment.centerLeft),
            child: Text(l10n.overviewViewParticipantsAction),
          ),
        ],
      ),
    );
  }
}

class _InitialsAvatar extends StatelessWidget {
  const _InitialsAvatar({required this.name});

  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = name.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final initials = tokens.isEmpty
        ? ''
        : tokens.length == 1
            ? tokens.first.substring(0, 1).toUpperCase()
            : (tokens.first.substring(0, 1) + tokens.last.substring(0, 1)).toUpperCase();

    return CircleAvatar(
      radius: 14,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      child: Text(
        initials,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
      ),
    );
  }
}

class _ItinerarySummaryCard extends StatelessWidget {
  const _ItinerarySummaryCard({
    required this.travel,
    required this.l10n,
    required this.onViewItinerary,
  });

  final TravelViewModel travel;
  final AppLocalizations l10n;
  final VoidCallback onViewItinerary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final itinerary = travel.itinerary;

    return _OverviewCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CardLabel(l10n.overviewItineraryLabel),
          const SizedBox(height: 12),
          if (itinerary != null)
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                  child: Icon(Icons.view_timeline, color: theme.colorScheme.primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    l10n.overviewItineraryStepsSummary(itinerary.steps.length, itinerary.agentName),
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: onViewItinerary,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: Text(l10n.overviewViewItineraryAction),
                ),
              ],
            )
          else
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: theme.colorScheme.onSurface.withValues(alpha: 0.08),
                  child: Icon(Icons.event_busy, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.overviewNoItineraryTitle,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        l10n.overviewNoItinerarySupport,
                        style: TextStyle(fontSize: 12, color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () => context.go(
                    '${AppRoutes.travels}/${travel.localId}/${AppRoutes.itineraryCreate}',
                    extra: {
                      'travelId': travel.localId,
                      'itineraryBuildModel': ItineraryBuildModel(
                        travelName: travel.travelTitle,
                        interestsPoints: travel.route.interests,
                        steps: null,
                      ),
                    },
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(l10n.overviewCreateItineraryAction),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
