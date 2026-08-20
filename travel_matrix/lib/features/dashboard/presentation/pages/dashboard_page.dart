import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/app/global_controllers/auth_controller.dart';
import 'package:travel_matrix/features/dashboard/presentation/controllers/dashboard_controller.dart';
import 'package:travel_matrix/features/dashboard/presentation/view_models/dashboard_view_model.dart';
import 'package:travel_matrix/features/dashboard/presentation/widgets/kpi_cards_section.dart';
import 'package:travel_matrix/features/dashboard/presentation/widgets/welcome_banner.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/theme/app_theme.dart';

class DashboardPage extends StatelessWidget {
  final DashboardController? controller;

  const DashboardPage({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    final providedController = controller;
    return providedController != null
        ? ChangeNotifierProvider.value(
            value: providedController,
            child: const _DashboardView(),
          )
        : ChangeNotifierProvider(
            create: (_) => DashboardController(),
            child: const _DashboardView(),
          );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<DashboardController>().state;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.hasError
              ? Center(
                  child: Text(
                    l10n.failedToLoadDashboard,
                    style: TextStyle(color: theme.colorScheme.error),
                  ),
                )
              : _DashboardContent(dashboard: state.dashboard!, l10n: l10n),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  final DashboardViewModel dashboard;
  final AppLocalizations l10n;

  const _DashboardContent({
    required this.dashboard,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final agentName =
        context.watch<AuthController>().userName?.split(' ').first ?? 'Agent';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          WelcomeBanner(agentName: agentName, dashboard: dashboard, l10n: l10n),
          const SizedBox(height: 24),
          KpiCardsSection(dashboard: dashboard, l10n: l10n),
          const SizedBox(height: 28),
          _RecentTravelsTable(travels: dashboard.recentTravels, l10n: l10n),
          const SizedBox(height: 28),
          _ActiveClientsList(clients: dashboard.activeClientsList, l10n: l10n),
        ],
      ),
    );
  }
}

class _RecentTravelsTable extends StatelessWidget {
  final List<DashboardTravelRowViewModel> travels;
  final AppLocalizations l10n;

  const _RecentTravelsTable({
    required this.travels,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd(l10n.localeName);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.recentTravels,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (travels.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(l10n.noTravelsCreated),
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minWidth: constraints.maxWidth),
                      child: DataTable(
                        headingRowColor: WidgetStatePropertyAll(
                          theme.colorScheme.surfaceContainerHighest,
                        ),
                        columns: [
                          DataColumn(label: Text(l10n.travelNameColumn)),
                          DataColumn(label: Text(l10n.clientLabel)),
                          DataColumn(label: Text(l10n.routeColumn)),
                          DataColumn(label: Text(l10n.startDateLabel)),
                          DataColumn(label: Text(l10n.statusColumn)),
                        ],
                        rows: travels.map((travel) {
                          return DataRow(
                            cells: [
                              DataCell(Text(travel.travelName)),
                              DataCell(Text(travel.clientName)),
                              DataCell(Text(travel.route)),
                              DataCell(Text(dateFormat.format(travel.startDate))),
                              DataCell(_StatusChip(travel: travel, l10n: l10n)),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final DashboardTravelRowViewModel travel;
  final AppLocalizations l10n;

  const _StatusChip({required this.travel, required this.l10n});

  static String _statusLabel(AppLocalizations l10n, String status) {
    switch (status) {
      case 'route_created':
        return l10n.routeOnly;
      case 'itinerary_created':
        return l10n.itineraryReady;
      case 'travel_started':
        return l10n.travelInProgress;
      case 'travel_finished':
        return l10n.travelCompleted;
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final semantic = theme.semanticColors;
    final color = travel.hasItinerary ? semantic.success : semantic.warning;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        _statusLabel(l10n, travel.status),
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _ActiveClientsList extends StatelessWidget {
  final List<DashboardClientRowViewModel> clients;
  final AppLocalizations l10n;

  const _ActiveClientsList({
    required this.clients,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.activeClientsListTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            for (final client in clients)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundColor:
                      theme.colorScheme.primary.withValues(alpha: 0.12),
                  child: Text(
                    _initials(client.name),
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(client.name),
                subtitle: Text(client.email),
                trailing: Text(
                  client.phoneNumber,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.62),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }
}
