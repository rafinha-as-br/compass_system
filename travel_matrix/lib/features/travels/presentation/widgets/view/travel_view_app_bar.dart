import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';
import 'package:travel_matrix/shared/widgets/back_icon_button.dart';

/// This appBar is used in the Travel_View_page, responsible for showing:
/// - Travel Name
/// - Travel Status (right next to the travel name)
/// - Travel Start and Finish Date
/// - Number of Travelers
class TravelViewAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TravelViewAppBar({
    super.key,
    required this.travel,
  });

  final TravelViewModel travel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final mutedColor = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final statusColor = travel.status.color(theme);
    final dateFormat = DateFormat.yMMMd(l10n.localeName);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outlineVariant,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Travel Status and title
              Row(
                spacing: 16,
                children: [
                  // Back button
                  BackIconButton(
                    onPressed: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.go(AppRoutes.travels);
                      }
                    },
                  ),
                  // Title
                  Expanded(
                    child: Text(
                      travel.travelTitle,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: theme.colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Actions menu — a single trigger instead of one
                  // ElevatedButton per action, so the row never needs more
                  // horizontal space than it has, regardless of window width.
                  _TravelActionsMenu(travel: travel),

                  // travel Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      travel.statusString,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              // Date and travelers row — Wrap instead of Row so it drops to
              // a second line instead of overflowing when there isn't
              // enough width for both pieces of text.
              Wrap(
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 8,
                runSpacing: 4,
                children: [
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 280),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 14,
                          color: mutedColor,
                        ),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            '${dateFormat.format(travel.route.startDate)} - ${dateFormat.format(travel.route.endDate)}',
                            style: TextStyle(
                              color: mutedColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '• ${l10n.travelersCount(travel.participants.length)}',
                    style: TextStyle(
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TabBar(
                dividerColor: Colors.transparent,
                indicatorSize: TabBarIndicatorSize.tab,
                unselectedLabelColor: mutedColor,
                tabs: [
                  Tab(icon: const Icon(Icons.dashboard_outlined), text: l10n.overviewViewTab),
                  Tab(icon: const Icon(Icons.map), text: l10n.routeViewTab),
                  Tab(icon: const Icon(Icons.view_timeline), text: l10n.itineraryViewTab),
                  Tab(icon: const Icon(Icons.people_outline), text: l10n.participantsViewTab),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ponytail: PreferredSizeWidget.preferredSize has no access to the
  // available width, so this can't measure the actual content — it's sized
  // for the worst case (date/travelers row wrapping to 2 lines on a narrow
  // window). Upgrade path if this ever falls short again: convert this
  // widget into a body-level header instead of a fixed-height `appBar:`.
  @override
  Size get preferredSize => const Size.fromHeight(220);
}

/// One entry of the actions menu (either top-level or inside the "Editar"
/// flyout) — building both groups from a list, instead of hardcoded widgets
/// in sequence, is what lets a future action be added without touching the
/// layout (CPS-115).
class _MenuAction {
  const _MenuAction({
    required this.icon,
    required this.label,
    required this.onSelected,
    this.enabled = true,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback onSelected;
  final bool enabled;
  final String? tooltip;
}

/// The `⋮` trigger and its `MenuAnchor` — a native Material menu instead of
/// a hand-rolled overlay: it already flips the "Editar" flyout to the left
/// when the trigger sits at the right edge of the window (CPS-115's "abre à
/// esquerda"), and closes on outside tap/Esc/selection for free.
class _TravelActionsMenu extends StatelessWidget {
  const _TravelActionsMenu({required this.travel});

  final TravelViewModel travel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final editActions = <_MenuAction>[
      _MenuAction(
        icon: Icons.edit_road,
        label: l10n.editRouteTitle,
        onSelected: () => context.go(
          '${AppRoutes.travels}/${travel.localId}/${AppRoutes.routeCreate}',
          extra: {
            'travel': travel,
            'controller': context.read<TravelsController>(),
          },
        ),
      ),
      _MenuAction(
        icon: Icons.edit_calendar,
        label: l10n.editItineraryTitle,
        onSelected: () => _openEditItinerary(context, travel),
      ),
    ];

    final bottomActions = <_MenuAction>[
      if (travel.status == TravelStatusViewModel.notReady)
        _MenuAction(
          icon: Icons.rocket_launch_outlined,
          label: l10n.prepareTravelButton,
          enabled: travel.itinerary != null,
          tooltip: travel.itinerary == null ? l10n.needsItineraryFirstTooltip : l10n.prepareTravelTooltip,
          onSelected: () => _handlePrepareTravel(context, travel),
        ),
    ];

    return MenuAnchor(
      menuChildren: [
        SubmenuButton(
          leadingIcon: const Icon(Icons.edit_outlined),
          menuChildren: editActions
              .map((action) => MenuItemButton(
                    leadingIcon: Icon(action.icon),
                    onPressed: action.onSelected,
                    child: Text(action.label),
                  ))
              .toList(),
          child: Text(l10n.editMenuLabel),
        ),
        if (bottomActions.isNotEmpty) const Divider(height: 1),
        for (final action in bottomActions)
          Tooltip(
            message: action.tooltip ?? '',
            child: MenuItemButton(
              leadingIcon: Icon(action.icon),
              style: ButtonStyle(
                foregroundColor: WidgetStateProperty.resolveWith(
                  (states) => states.contains(WidgetState.disabled)
                      ? TravelAppColors.disabled
                      : theme.colorScheme.onSurface,
                ),
              ),
              onPressed: action.enabled ? action.onSelected : null,
              child: Text(action.label),
            ),
          ),
      ],
      builder: (context, controller, child) {
        return Tooltip(
          message: l10n.travelActionsMenuTooltip,
          child: InkWell(
            onTap: () => controller.isOpen ? controller.close() : controller.open(),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.more_vert, color: theme.colorScheme.primary),
            ),
          ),
        );
      },
    );
  }

  void _openEditItinerary(BuildContext context, TravelViewModel travel) {
    final steps = travel.itinerary?.steps;
    final ItineraryStepsBuildModel? itineraryStepsBuildModel;
    if (steps == null || steps.length < 2) {
      itineraryStepsBuildModel = null;
    } else {
      itineraryStepsBuildModel = ItineraryStepsBuildModel(
        startStep: steps.first,
        finishStep: steps.last,
        normalSteps: steps.sublist(1, steps.length - 1),
      );
    }

    context.go(
      '${AppRoutes.travels}/${travel.localId}/${AppRoutes.itineraryCreate}',
      extra: {
        'travelId': travel.localId,
        'itineraryBuildModel': ItineraryBuildModel(
          travelName: travel.travelTitle,
          interestsPoints: travel.route.interests,
          steps: itineraryStepsBuildModel,
          hasExistingItinerary: travel.itinerary != null,
        ),
      },
    );
  }

  Future<void> _handlePrepareTravel(BuildContext context, TravelViewModel travel) async {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => _PrepareTravelDialog(travel: travel),
    );

    if (confirm != true) return;
    if (!context.mounted) return;
    final controller = context.read<TravelsController>();
    final success = await controller.markTravelAsReady(travel.backEndId!);
    if (!context.mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.prepareTravelSuccess)),
      );
      context.go(AppRoutes.travels);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.prepareTravelFailure),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    }
  }
}

/// Summary dialog shown before confirming "Preparar viagem" — replaces the
/// old plain confirm/cancel: shows the data the agent needs to double-check
/// (dates, participants, first/last itinerary step) before finalizing the
/// first itinerary version (CPS-115).
class _PrepareTravelDialog extends StatelessWidget {
  const _PrepareTravelDialog({required this.travel});

  final TravelViewModel travel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final dateFormat = DateFormat.yMMMd(l10n.localeName);
    final steps = travel.itinerary?.steps ?? const [];

    return AlertDialog(
      title: Text(l10n.prepareTravelDialogTitle),
      content: SizedBox(
        width: 420,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.prepareTravelDialogSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            const SizedBox(height: 16),
            _SummaryRow(label: l10n.prepareTravelSummaryTravelLabel, value: travel.travelTitle),
            _SummaryRow(label: l10n.prepareTravelSummaryStatusLabel, value: travel.statusString),
            _SummaryRow(
              label: l10n.prepareTravelSummaryParticipantsLabel,
              value: '${travel.participants.length}',
            ),
            _SummaryRow(
              label: l10n.prepareTravelSummaryStartDateLabel,
              value: dateFormat.format(travel.route.startDate),
            ),
            _SummaryRow(
              label: l10n.prepareTravelSummaryEndDateLabel,
              value: dateFormat.format(travel.route.endDate),
            ),
            if (steps.isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: TravelAppColors.background,
                  border: Border.all(color: theme.colorScheme.outlineVariant),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.itinerarySummarySectionTitle,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _StepSummaryRow(color: theme.semanticColors.success, title: steps.first.title),
                    if (steps.length > 1)
                      _StepSummaryRow(color: theme.colorScheme.primary, title: steps.last.title),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.cancelButton),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: Text(l10n.prepareTravelButton),
        ),
      ],
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
          ),
          Text(value, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _StepSummaryRow extends StatelessWidget {
  const _StepSummaryRow({required this.color, required this.title});

  final Color color;
  final String title;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(title, style: theme.textTheme.bodySmall)),
        ],
      ),
    );
  }
}
