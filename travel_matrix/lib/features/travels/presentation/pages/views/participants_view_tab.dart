import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';

/// Participants tab of `TravelViewPage` — add and remove participants,
/// persisted through [TravelsController.addParticipant]/[removeParticipant]
/// (`PUT /travels/{travelId}/participants`, a full-list upsert).
///
/// The list itself, the submitting/removing-in-flight flags and the error
/// message all live in [TravelsController] (shared with the rest of the
/// travel view) — only the add-participant form's own field state is local
/// to [_AddParticipantDialog].
class ParticipantsViewTab extends StatelessWidget {
  const ParticipantsViewTab({super.key, required this.travel, this.onTravelUpdated});

  final TravelViewModel travel;

  /// Called after a successful add/remove with the travel carrying the
  /// fresh participants list, so the owner ([TravelViewWrapper]) can
  /// rebuild the header count along with this tab.
  final ValueChanged<TravelViewModel>? onTravelUpdated;

  Future<void> _addParticipant(BuildContext context) async {
    final newParticipant = await showDialog<PersonViewModel>(
      context: context,
      builder: (_) => const _AddParticipantDialog(),
    );
    if (newParticipant == null || !context.mounted) return;

    await _submitAdd(context, newParticipant);
  }

  Future<void> _submitAdd(BuildContext context, PersonViewModel newParticipant) async {
    final controller = context.read<TravelsController>();
    final updated = await controller.addParticipant(travel.localId, travel.participants, newParticipant);
    if (!context.mounted) return;

    if (updated != null) {
      onTravelUpdated?.call(travel.copyWith(participants: updated));
    } else {
      _showError(context, () => _submitAdd(context, newParticipant));
    }
  }

  Future<void> _removeParticipant(BuildContext context, PersonViewModel person) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.removeParticipantConfirmTitle),
        content: Text(l10n.removeParticipantConfirmMessage(person.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancelButton),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            child: Text(l10n.deleteButton),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    await _submitRemove(context, person);
  }

  Future<void> _submitRemove(BuildContext context, PersonViewModel person) async {
    final controller = context.read<TravelsController>();
    final updated = await controller.removeParticipant(travel.localId, travel.participants, person.id);
    if (!context.mounted) return;

    if (updated != null) {
      onTravelUpdated?.call(travel.copyWith(participants: updated));
    } else {
      _showError(context, () => _submitRemove(context, person));
    }
  }

  void _showError(BuildContext context, VoidCallback onRetry) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.failedToUpdateParticipants),
        backgroundColor: Theme.of(context).colorScheme.error,
        action: SnackBarAction(
          label: l10n.retryButton,
          textColor: Theme.of(context).colorScheme.onError,
          onPressed: onRetry,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Consumer<TravelsController>(
      builder: (context, controller, _) {
        final isSubmitting = controller.isSubmittingParticipants;
        final removingId = controller.removingParticipantId;

        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.travelersCount(travel.participants.length),
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: isSubmitting ? null : () => _addParticipant(context),
                    icon: const Icon(Icons.person_add_alt),
                    label: Text(l10n.addParticipantButton),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.primary,
                      foregroundColor: theme.colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: travel.participants.isEmpty
                  ? _EmptyState(l10n: l10n, onAdd: isSubmitting ? null : () => _addParticipant(context))
                  : ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                      itemCount: travel.participants.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final person = travel.participants[index];
                        return _ParticipantTile(
                          key: ValueKey(person.id),
                          person: person,
                          isRemoving: removingId == person.id,
                          onRemove: isSubmitting ? null : () => _removeParticipant(context, person),
                        );
                      },
                    ),
            ),
          ],
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n, required this.onAdd});

  final AppLocalizations l10n;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.people_outline, size: 64, color: theme.disabledColor),
            const SizedBox(height: 16),
            Text(l10n.noParticipantsTitle, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(
              l10n.noParticipantsMessage,
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.colorScheme.onSurface.withValues(alpha: 0.6)),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.person_add_alt),
              label: Text(l10n.addParticipantButton),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: theme.colorScheme.onPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({super.key, required this.person, required this.isRemoving, required this.onRemove});

  final PersonViewModel person;
  final bool isRemoving;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final subtitleParts = [
      if (person.age.trim().isNotEmpty) l10n.participantAgeYears(person.age.trim()),
      if (person.sex.trim().isNotEmpty) _sexLabel(l10n, person.sex),
    ];

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
          child: Text(
            _initials(person.name),
            style: TextStyle(fontWeight: FontWeight.w700, color: theme.colorScheme.primary),
          ),
        ),
        title: Text(person.name, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: subtitleParts.isEmpty ? null : Text(subtitleParts.join(' · ')),
        trailing: isRemoving
            ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2))
            : IconButton(
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
                tooltip: l10n.removeParticipantTooltip,
                color: theme.colorScheme.error,
              ),
      ),
    );
  }

  String _sexLabel(AppLocalizations l10n, String sex) {
    switch (sex) {
      case 'M':
        return l10n.maleGenderLabel;
      case 'F':
        return l10n.femaleGenderLabel;
      default:
        return l10n.otherOptionLabel;
    }
  }

  String _initials(String name) {
    final tokens = name.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    if (tokens.isEmpty) return '';
    if (tokens.length == 1) return tokens.first.substring(0, 1).toUpperCase();
    return (tokens.first.substring(0, 1) + tokens.last.substring(0, 1)).toUpperCase();
  }
}

/// Local, ephemeral form state for a brand-new participant — deliberately
/// not routed through [TravelsController] (see the class doc on
/// [ParticipantsViewTab]).
class _AddParticipantDialog extends StatefulWidget {
  const _AddParticipantDialog();

  @override
  State<_AddParticipantDialog> createState() => _AddParticipantDialogState();
}

class _AddParticipantDialogState extends State<_AddParticipantDialog> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _sex = 'F';
  bool _nameTouched = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final name = _nameController.text.trim();
    final nameError = _nameTouched && name.isEmpty ? l10n.fieldRequiredError : null;

    return AlertDialog(
      title: Text(l10n.addParticipantDialogTitle),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: InputDecoration(labelText: l10n.participantNameFieldLabel, errorText: nameError),
              onChanged: (_) => setState(() {}),
              onTapOutside: (_) => setState(() => _nameTouched = true),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: l10n.participantAgeFieldLabel),
            ),
            const SizedBox(height: 16),
            Text(l10n.sexFieldLabel, style: theme.textTheme.bodySmall),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: [
                ButtonSegment(value: 'F', label: Text(l10n.femaleGenderLabel)),
                ButtonSegment(value: 'M', label: Text(l10n.maleGenderLabel)),
                ButtonSegment(value: 'O', label: Text(l10n.otherOptionLabel)),
              ],
              selected: {_sex},
              onSelectionChanged: (selection) => setState(() => _sex = selection.first),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.cancelButton),
        ),
        ElevatedButton(
          onPressed: name.isEmpty
              ? null
              : () => Navigator.of(context).pop(
                    PersonViewModel.fromLocal(name, _ageController.text.trim(), _sex),
                  ),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
          ),
          child: Text(l10n.addParticipantButton),
        ),
      ],
    );
  }
}
