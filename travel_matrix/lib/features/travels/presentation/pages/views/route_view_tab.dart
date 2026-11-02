import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/travels/domain/entities/route.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/route_view_model.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// Displays route data for the selected travel.
///
/// Consumes a [TravelViewModel] and shows the route details like locations,
/// dates, and interest points. The agent edits each point's observation
/// inline here (CPS-180), saved through
/// [TravelsController.changeInterestObservation].
///
/// Layout: Scrollable column with a list of info tiles and interest point cards.
class RouteViewTab extends StatelessWidget {
  final TravelViewModel travel;

  /// Called after a successful observation edit with the travel carrying the
  /// saved route, so the owner can rebuild this tab with it.
  final ValueChanged<TravelViewModel>? onTravelUpdated;

  const RouteViewTab({super.key, required this.travel, this.onTravelUpdated});

  /// Returns whether the observation was saved, so the field knows when to leave edit mode.
  Future<bool> _submitObservation(BuildContext context, InterestPointViewModel point, String observation) async {
    final controller = context.read<TravelsController>();
    final updated = await controller.changeInterestObservation(travel.localId, travel.route, point.id, observation);
    if (!context.mounted) return false;

    if (updated != null) {
      onTravelUpdated?.call(travel.copyWith(route: updated));
      return true;
    }
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.failedToUpdateInterestObservation),
        backgroundColor: theme.colorScheme.error,
        action: SnackBarAction(
          label: l10n.retryButton,
          textColor: theme.colorScheme.onError,
          onPressed: () => _submitObservation(context, point, observation),
        ),
      ),
    );
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final route = travel.route;
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.routeDetails,
              style: theme.textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          _infoTile(theme, Icons.location_on, l10n.fromLabel,
              route.start),
          _infoTile(theme, Icons.flag, l10n.toLabel, route.destination),
          _infoTile(
            theme,
            Icons.calendar_today,
            l10n.startDateLabel,
            '${route.startDate.day}/${route.startDate.month}/${route.startDate.year}',
          ),
          _infoTile(
            theme,
            Icons.event,
            l10n.endDateLabel,
            '${route.endDate.day}/${route.endDate.month}/${route.endDate.year}',
          ),
          const SizedBox(height: 24),
          Text(l10n.interestPointsCount(route.interests.length),
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          if (route.interests.isEmpty)
            Text(l10n.noInterestPoints)
          else
            ...route.interests.map(
                  (poi) => Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: Column(
                  children: [
                    ListTile(
                      leading: Icon(Icons.place,
                          color: theme.colorScheme.secondary),
                      title: Text(poi.name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600)),
                      subtitle: Text(poi.description),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                      child: _InterestObservationField(
                        key: ValueKey('interest_observation_${poi.id}'),
                        pointId: poi.id,
                        observation: poi.observation,
                        onSave: (text) => _submitObservation(context, poi, text),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 24),
          Text(l10n.observationsLabel,
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                travel.observations?.trim().isNotEmpty == true
                    ? travel.observations!
                    : l10n.noObservations,
                style: travel.observations?.trim().isNotEmpty == true
                    ? null
                    : TextStyle(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile(
      ThemeData theme, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 100,
            child: Text(label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                )),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}

/// Inline observation of an interest point in three states: none (add
/// button), shown (tap to edit) and editing (free-text field with
/// Save/Cancel). Leaves edit mode only once [onSave] reports the text was
/// persisted.
class _InterestObservationField extends StatefulWidget {
  const _InterestObservationField({
    super.key,
    required this.pointId,
    required this.observation,
    required this.onSave,
  });

  final String pointId;

  /// Empty when the point has no observation.
  final String observation;
  final Future<bool> Function(String observation) onSave;

  @override
  State<_InterestObservationField> createState() => _InterestObservationFieldState();
}

class _InterestObservationFieldState extends State<_InterestObservationField> {
  final _controller = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    _controller.text = widget.observation;
    setState(() => _editing = true);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final saved = await widget.onSave(_controller.text);
    if (!mounted) return;
    setState(() {
      _saving = false;
      if (saved) _editing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.6);
    final id = widget.pointId;

    if (_editing) {
      return Container(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.primary, width: 1.5),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.interestObservationFieldLabel, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            TextField(
              key: Key('interest_observation_field_$id'),
              controller: _controller,
              autofocus: true,
              minLines: 2,
              maxLines: 4,
              maxLength: InterestPoint.observationMaxLength,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  key: Key('interest_observation_cancel_$id'),
                  onPressed: _saving ? null : () => setState(() => _editing = false),
                  child: Text(l10n.cancelButton),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  key: Key('interest_observation_save_$id'),
                  onPressed: _saving ? null : _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: theme.colorScheme.onPrimary,
                  ),
                  child: Text(l10n.saveButton),
                ),
              ],
            ),
          ],
        ),
      );
    }

    final border = Border.all(color: theme.colorScheme.outlineVariant);

    if (widget.observation.isEmpty) {
      return InkWell(
        key: Key('interest_observation_add_$id'),
        onTap: _startEditing,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(border: border, borderRadius: BorderRadius.circular(8)),
          child: Text(l10n.interestObservationAddButton, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
        ),
      );
    }

    return InkWell(
      key: Key('interest_observation_view_$id'),
      onTap: _startEditing,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
          border: border,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.interestObservationLabel, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            const SizedBox(width: 8),
            Expanded(child: Text(widget.observation, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
  }
}
