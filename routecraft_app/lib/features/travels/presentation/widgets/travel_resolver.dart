import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:routecraft_app/app/router/app_routes.dart';
import 'package:routecraft_app/features/travels/domain/entities/travel.dart';
import 'package:routecraft_app/features/travels/presentation/controllers/travel_resolver_controller.dart';
import 'package:routecraft_app/l10n/app_localizations.dart';
import 'package:routecraft_app/shared/widgets/empty_state_view.dart';

/// Resolves the [Travel] a route needs before handing it to [builder] —
/// `extra` when the navigation carried it directly, otherwise a fetch by
/// [travelId] (the route's own fallback for deep link/state restoration,
/// where `extra` never survives). Shows a treated error state, with retry,
/// when neither is available or the fetch fails.
class TravelResolver extends StatelessWidget {
  const TravelResolver({super.key, required this.travel, required this.travelId, required this.builder});

  final Travel? travel;
  final String? travelId;
  final Widget Function(BuildContext context, Travel travel) builder;

  @override
  Widget build(BuildContext context) {
    final travel = this.travel;
    if (travel != null) return builder(context, travel);

    final travelId = this.travelId;
    if (travelId == null) return const _TravelResolverError(onRetry: null);

    return ChangeNotifierProvider(
      create: (_) => TravelResolverController(travelId: travelId),
      child: Consumer<TravelResolverController>(
        builder: (context, controller, _) {
          final state = controller.state;
          if (state.isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          final resolved = state.travel;
          if (state.isError || resolved == null) {
            return _TravelResolverError(onRetry: controller.retry);
          }
          return builder(context, resolved);
        },
      ),
    );
  }
}

class _TravelResolverError extends StatelessWidget {
  const _TravelResolverError({required this.onRetry});

  /// `null` when there's no id to retry with at all (route reached without
  /// `extra` and without a travel id) — the only way forward is Home.
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: EmptyStateView(
          icon: Icons.error_outline,
          title: l10n.travelNotFoundTitle,
          message: l10n.travelNotFoundMessage,
          ctaLabel: onRetry != null ? l10n.networkErrorRetryCta : l10n.hubGoToHomeCta,
          onCtaPressed: onRetry ?? () => context.go(AppRoutes.home),
        ),
      ),
    );
  }
}
