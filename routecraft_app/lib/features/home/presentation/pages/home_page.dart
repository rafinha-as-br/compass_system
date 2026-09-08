import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/global_controllers/travel_sync_status_controller.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/home/presentation/controllers/home_controller.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/widgets/empty_state_view.dart';
import 'package:routecraft_app/shared/widgets/offline_banner.dart';
import 'package:routecraft_app/shared/widgets/skeleton_block.dart';
import 'package:routecraft_app/shared/widgets/travel_card.dart';
import 'package:routecraft_app/shared/widgets/travel_status_chip.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, this.controller});

  /// Injectable for widget tests with a fixed state, without depending on
  /// the real network/singleton wiring. In production, the call site
  /// (`HomePage()`) is unaffected — the default wiring is used.
  final HomeController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) =>
          controller ?? HomeController(onSyncStatusChanged: context.read<TravelSyncStatusController>().update),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final state = context.watch<HomeController>().state;

    return Scaffold(
      body: state.isLoading
          ? const _HomeSkeleton()
          : state.isError
              ? _HomeError(onRetry: () => context.read<HomeController>().retry())
              : SafeArea(
                  child: Column(
                    children: [
                      if (state.isOffline) OfflineBanner(syncedAt: state.syncedAt!),
                      _HomeHeader(clientName: state.clientName),
                      Expanded(
                        child: state.isEmpty ? const _EmptyHome() : _TravelSectionsList(state: state),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: (state.isLoading || state.isError || state.isEmpty)
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _pushAndRefresh(context, AppRoutes.homeCreateRoute),
              icon: const Icon(Icons.add),
              label: Text(l10n.createRouteNav),
              backgroundColor: Theme.of(context).colorScheme.secondary,
              foregroundColor: Theme.of(context).colorScheme.onSecondary,
            ),
    );
  }
}

/// Greeting + client avatar, shown above both the travel list and the empty
/// state — wireframe 2b keeps the same header in both.
class _HomeHeader extends StatelessWidget {
  const _HomeHeader({required this.clientName});

  final String? clientName;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final name = clientName ?? '';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: theme.colorScheme.primary,
            child: Text(
              _initials(name),
              style: TextStyle(color: theme.colorScheme.onPrimary, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.homeGreeting(_firstName(name)),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                Text(
                  l10n.visualizationTitle,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Awaits the push before refreshing — the shell keeps [HomeController]
/// alive across navigation, so a route created (or an itinerary edited) in a
/// child screen would otherwise never show up back on Início.
Future<void> _pushAndRefresh(BuildContext context, String location, {Object? extra}) async {
  await context.push(location, extra: extra);
  if (context.mounted) {
    context.read<HomeController>().refresh();
  }
}

String _firstName(String fullName) {
  final trimmed = fullName.trim();
  return trimmed.isEmpty ? '' : trimmed.split(RegExp(r'\s+')).first;
}

String _initials(String fullName) {
  final parts = fullName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return '';
  if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
  return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
}

class _TravelSectionsList extends StatelessWidget {
  const _TravelSectionsList({required this.state});

  final HomeState state;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
      children: [
        if (state.inProgress.isNotEmpty)
          _TravelSection(title: l10n.homeSectionInProgress, travels: state.inProgress),
        if (state.upcoming.isNotEmpty)
          _TravelSection(title: l10n.homeSectionUpcoming, travels: state.upcoming),
        if (state.completed.isNotEmpty)
          _TravelSection(title: l10n.homeSectionCompleted, travels: state.completed),
      ],
    );
  }
}

class _TravelSection extends StatelessWidget {
  const _TravelSection({required this.title, required this.travels});

  final String title;
  final List<Travel> travels;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title.toUpperCase(),
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          ...travels.map(
            (travel) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TravelCard(
                travelName: travel.travelName,
                route: _routeText(travel),
                period: _periodText(context, travel),
                status: _chipVariant(travel.travelStatus),
                onTap: () => _pushAndRefresh(context, AppRoutes.homeFollowTravel, extra: travel),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Sketches the shape of the header + travel cards while they load — no
/// spinner, per DESIGN.md's loading pattern (wireframe 2d).
class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SkeletonBlock(height: 48, width: 48, borderRadius: BorderRadius.all(Radius.circular(24))),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      SkeletonBlock(height: 14, width: 100),
                      SizedBox(height: 8),
                      SkeletonBlock(height: 20, width: 160),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            for (var i = 0; i < 3; i++) ...[
              const SkeletonBlock(height: 88),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _HomeError extends StatelessWidget {
  const _HomeError({required this.onRetry});

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

class _EmptyHome extends StatelessWidget {
  const _EmptyHome();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return EmptyStateView(
      icon: Icons.auto_awesome_outlined,
      title: l10n.noTravelsYet,
      message: l10n.homeEmptyMessage,
      ctaLabel: l10n.homeEmptyCta,
      onCtaPressed: () => _pushAndRefresh(context, AppRoutes.homeCreateRoute),
    );
  }
}

TravelStatusChipVariant _chipVariant(TravelStatus status) => switch (status) {
      TravelStatus.routeCreated => TravelStatusChipVariant.routeCreated,
      TravelStatus.itineraryCreated => TravelStatusChipVariant.itineraryCreated,
      TravelStatus.travelStarted => TravelStatusChipVariant.travelStarted,
      TravelStatus.travelFinished => TravelStatusChipVariant.travelFinished,
    };

// ponytail: hand-rolled month abbreviations instead of intl's DateFormat —
// DateFormat needs initializeDateFormatting() per locale, unused anywhere
// else in this app; wiring it up for one date range isn't worth the setup.
// Upgrade: switch to DateFormat if a second locale-aware date format shows up.
const _monthAbbreviationsEn = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec', //
];
const _monthAbbreviationsPt = [
  'jan', 'fev', 'mar', 'abr', 'mai', 'jun', 'jul', 'ago', 'set', 'out', 'nov', 'dez', //
];

String _monthAbbreviation(String languageCode, int month) {
  final names = languageCode == 'pt' ? _monthAbbreviationsPt : _monthAbbreviationsEn;
  return names[month - 1];
}

String _period(String languageCode, DateTime start, DateTime end) {
  final endLabel = '${end.day} ${_monthAbbreviation(languageCode, end.month)}';
  if (start.year == end.year && start.month == end.month) {
    return '${start.day}–$endLabel';
  }
  final startLabel = '${start.day} ${_monthAbbreviation(languageCode, start.month)}';
  return '$startLabel–$endLabel';
}

String _routeText(Travel travel) {
  final route = travel.routePlan;
  return '${route.startLocation} → ${route.destination}';
}

String _periodText(BuildContext context, Travel travel) {
  final languageCode = Localizations.localeOf(context).languageCode;
  final route = travel.routePlan;
  return _period(languageCode, route.startDate, route.endDate);
}
