import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/router/app_routes.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/build_models/itinerary_build_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
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

                  // Actions menu — a single icon button instead of one
                  // ElevatedButton per action, so the row never needs more
                  // horizontal space than it has, regardless of window width.
                  PopupMenuButton<VoidCallback>(
                    icon: const Icon(Icons.more_vert),
                    tooltip: l10n.travelActionsMenuTooltip,
                    onSelected: (action) => action(),
                    itemBuilder: (context) => [
                      PopupMenuItem<VoidCallback>(
                        value: () => context.go(
                          '${AppRoutes.travels}/${travel.localId}/${AppRoutes.routeCreate}',
                          extra: {
                            'travel': travel,
                            'controller': context.read<TravelsController>(),
                          },
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.edit_road),
                          title: Text(l10n.editRouteTitle),
                        ),
                      ),
                      PopupMenuItem<VoidCallback>(
                        value: () {
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
                        },
                        child: ListTile(
                          leading: const Icon(Icons.edit_calendar),
                          title: Text(l10n.editItineraryTitle),
                        ),
                      ),
                      if (travel.status == TravelStatusViewModel.notReady)
                        PopupMenuItem<VoidCallback>(
                          enabled: travel.itinerary != null,
                          value: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(l10n.markAsReadyButton),
                                content: Text(l10n.markAsReadyConfirm),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(context).pop(false),
                                    child: Text(l10n.cancelButton),
                                  ),
                                  ElevatedButton(
                                    onPressed: () => Navigator.of(context).pop(true),
                                    child: Text(l10n.confirmButton),
                                  ),
                                ],
                              ),
                            );

                            if (confirm != true) return;
                            if (!context.mounted) return;
                            final controller = context.read<TravelsController>();
                            final success = await controller.markTravelAsReady(travel.backEndId!);
                            if (!context.mounted) return;

                            if (success) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.markAsReadySuccess)),
                              );
                              context.go(AppRoutes.travels);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(l10n.markAsReadyFailure),
                                  backgroundColor: theme.colorScheme.error,
                                ),
                              );
                            }
                          },
                          child: Tooltip(
                            message: travel.itinerary == null
                                ? l10n.needsItineraryFirstTooltip
                                : l10n.markAsReadyTooltip,
                            child: ListTile(
                              leading: const Icon(Icons.check_circle_outline),
                              title: Text(l10n.markAsReadyButton),
                            ),
                          ),
                        ),
                    ],
                  ),

                  // travel Status
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getTravelStatusBgColor(context),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      travel.statusString,
                      style: TextStyle(
                        color: _getTravelStatusFgColor(context),
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
                            '${_formatDate(travel.route.startDate)} - ${_formatDate(travel.route.endDate)}',
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
                  Tab(icon: const Icon(Icons.map), text: l10n.routeViewTab),
                  Tab(icon: const Icon(Icons.view_timeline), text: l10n.itineraryViewTab),
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

  String _formatDate(DateTime date) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  Color _getTravelStatusBgColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (travel.status) {
      case TravelStatusViewModel.notReady:
        return scheme.errorContainer;
      case TravelStatusViewModel.ready:
        return scheme.primaryContainer;
      case TravelStatusViewModel.inProgress:
        return scheme.secondaryContainer;
      case TravelStatusViewModel.completed:
        return scheme.tertiaryContainer;
    }
  }

  Color _getTravelStatusFgColor(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    switch (travel.status) {
      case TravelStatusViewModel.notReady:
        return scheme.onErrorContainer;
      case TravelStatusViewModel.ready:
        return scheme.onPrimaryContainer;
      case TravelStatusViewModel.inProgress:
        return scheme.onSecondaryContainer;
      case TravelStatusViewModel.completed:
        return scheme.onTertiaryContainer;
    }
  }
}
