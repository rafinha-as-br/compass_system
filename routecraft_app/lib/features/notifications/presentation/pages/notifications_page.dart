import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/notifications/domain/entities/travel_notification.dart';
import 'package:routecraft_app/features/notifications/presentation/controllers/notifications_controller.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/utils/date_formatting.dart';
import 'package:routecraft_app/shared/widgets/empty_state_view.dart';

/// Client-derived notification list — wireframe 2c. There is no
/// notifications endpoint on the backend, so every entry here was generated
/// on-device by comparing travel state between fetches (see
/// `TravelNotificationsChecker`); a notification only ever appears once the
/// app has actually queried the corresponding travel.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key, this.controller});

  /// Injectable for widget tests with a fixed state, without depending on
  /// the real storage/network wiring. In production the call site is
  /// unaffected — the default wiring is used.
  final NotificationsController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller ?? NotificationsController(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final controller = context.watch<NotificationsController>();
    final state = controller.state;
    final hasUnread = state.notifications.any((n) => !n.read);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => context.pop()),
        title: Text(l10n.notificationsTitle),
        actions: [
          TextButton(
            onPressed: hasUnread ? controller.markAllRead : null,
            child: Text(l10n.notificationsMarkAllRead),
          ),
        ],
      ),
      body: SafeArea(
        child: state.isLoading
            ? const Center(child: CircularProgressIndicator())
            : state.notifications.isEmpty
                ? EmptyStateView(
                    icon: Icons.notifications_none_outlined,
                    title: l10n.notificationsTitle,
                    message: l10n.notificationsEmptyMessage,
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      for (final group in groupNotificationsByDay(state.notifications)) ...[
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
                          child: Text(
                            group.label(context).toUpperCase(),
                            style: Theme.of(context)
                                .textTheme
                                .labelMedium
                                ?.copyWith(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)),
                          ),
                        ),
                        for (final notification in group.notifications)
                          _NotificationTile(notification: notification),
                      ],
                    ],
                  ),
      ),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification});

  final TravelNotification notification;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final controller = context.read<NotificationsController>();

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: notification.read ? null : theme.colorScheme.primary.withValues(alpha: 0.06),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconFor(notification.type), color: theme.colorScheme.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _messageFor(notification, l10n),
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: notification.read ? FontWeight.normal : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatTime(notification.createdAt),
                    style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => _openTrip(context, controller, notification.travelId),
                      child: Text(l10n.notificationViewTripLink),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openTrip(BuildContext context, NotificationsController controller, String travelId) async {
    final travel = await controller.resolveTravel(travelId);
    if (!context.mounted) return;
    if (travel == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(AppLocalizations.of(context)!.notificationOpenTripError)));
      return;
    }
    // `push` would stack this route on top of the current branch (Conta,
    // branch 2) even though `/home/follow` belongs to Início (branch 0) — the
    // screen would render outside its own StatefulShellBranch stack, with no
    // local Navigator entry to pop back to. `go` re-resolves the location
    // against the shell's branches, switching to Início and pushing there.
    context.go('${AppRoutes.homeFollowTravel}?${AppRoutes.travelIdQuery(travelId)}', extra: travel);
  }

  IconData _iconFor(TravelNotificationType type) => switch (type) {
        TravelNotificationType.itineraryPublished => Icons.map_outlined,
        TravelNotificationType.itineraryChanged => Icons.edit_calendar_outlined,
        TravelNotificationType.routeReceived => Icons.route_outlined,
      };

  String _messageFor(TravelNotification notification, AppLocalizations l10n) => switch (notification.type) {
        TravelNotificationType.itineraryPublished => l10n.notificationItineraryPublished(notification.travelName),
        TravelNotificationType.itineraryChanged => l10n.notificationItineraryChanged(notification.travelName),
        TravelNotificationType.routeReceived => l10n.notificationRouteReceived(notification.travelName),
      };
}

/// One day's worth of notifications, in the order they should render.
class NotificationDayGroup {
  const NotificationDayGroup({required this.day, required this.notifications});

  final DateTime day;
  final List<TravelNotification> notifications;

  /// "Today" for today's group, "d MMM" (e.g. "2 Sep") otherwise.
  String label(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    if (day.year == now.year && day.month == now.month && day.day == now.day) return l10n.hubToday;
    return '${day.day} ${monthAbbreviation(Localizations.localeOf(context).languageCode, day.month)}';
  }
}

/// Buckets [notifications] (assumed already sorted newest-first) into
/// consecutive same-day groups, preserving that order.
List<NotificationDayGroup> groupNotificationsByDay(List<TravelNotification> notifications) {
  final groups = <NotificationDayGroup>[];

  for (final notification in notifications) {
    final day = DateTime(notification.createdAt.year, notification.createdAt.month, notification.createdAt.day);
    if (groups.isNotEmpty && groups.last.day == day) {
      groups.last.notifications.add(notification);
    } else {
      groups.add(NotificationDayGroup(day: day, notifications: [notification]));
    }
  }

  return groups;
}
