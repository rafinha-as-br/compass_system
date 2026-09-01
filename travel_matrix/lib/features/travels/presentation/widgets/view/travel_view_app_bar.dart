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
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                  // Edit Route Button
                  ElevatedButton.icon(
                    onPressed: () {
                      context.go(
                        '${AppRoutes.travels}/${travel.localId}/${AppRoutes.routeCreate}',
                        extra: {
                          'travel': travel,
                          'controller': context.read<TravelsController>(),
                        },
                      );
                    },
                    icon: const Icon(Icons.edit_road, size: 16),
                    label: Text(l10n.editRouteTitle),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Edit Itinerary Button
                  ElevatedButton.icon(
                    onPressed: () {
                      final steps = travel.itinerary?.steps;
                      final ItineraryStepsBuildModel? itineraryStepsBuildModel;
                      if(steps == null || steps.length < 2){
                        itineraryStepsBuildModel = null;
                      } else{
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
                    icon: const Icon(Icons.edit_calendar, size: 16),
                    label: Text(l10n.editItineraryTitle),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),

                  // Mark as Ready Button (only visible if notReady)
                  if (travel.status == TravelStatusViewModel.notReady)
                    Tooltip(
                      message: travel.itinerary == null
                          ? l10n.needsItineraryFirstTooltip
                          : l10n.markAsReadyTooltip,
                      child: ElevatedButton.icon(
                        onPressed: travel.itinerary == null ? null : () async {
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

                          if (confirm == true) {
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
                          }
                        },
                        icon: const Icon(Icons.check_circle_outline, size: 16),
                        label: Text(l10n.markAsReadyButton),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                          backgroundColor: theme.colorScheme.primaryContainer,
                          foregroundColor: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
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
              // Date and travelers row
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 14,
                    color: mutedColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${_formatDate(travel.route.startDate)} - ${_formatDate(travel.route.endDate)}',
                    style: TextStyle(
                      color: mutedColor,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(width: 8),
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

  @override
  Size get preferredSize => const Size.fromHeight(190);

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
