import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travel_matrix/features/travels/presentation/controllers/travels_controller.dart';
import 'package:travel_matrix/features/travels/presentation/models/view_models/travel_view_model.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/utils/participant_avatars.dart';
import 'package:travel_matrix/shared/widgets/avatar_picker.dart';

/// Participants tab of `TravelViewPage` — add and remove participants and
/// edit each one's free-text note, persisted through
/// [TravelsController.addParticipant]/[removeParticipant]/[changeParticipantNote]
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

  Future<void> _submitAvatar(BuildContext context, PersonViewModel person, int index) async {
    final controller = context.read<TravelsController>();
    final updated = await controller.changeParticipantAvatar(travel.localId, travel.participants, person.id, index);
    if (!context.mounted) return;

    if (updated != null) {
      onTravelUpdated?.call(travel.copyWith(participants: updated));
    } else {
      _showError(context, () => _submitAvatar(context, person, index));
    }
  }

  /// Returns whether the note was saved, so the note field knows when to leave edit mode.
  Future<bool> _submitNote(BuildContext context, PersonViewModel person, String note) async {
    final controller = context.read<TravelsController>();
    final updated = await controller.changeParticipantNote(travel.localId, travel.participants, person.id, note);
    if (!context.mounted) return false;

    if (updated != null) {
      onTravelUpdated?.call(travel.copyWith(participants: updated));
      return true;
    }
    _showError(context, () => _submitNote(context, person, note));
    return false;
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
                    key: const Key('participants_add_button'),
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
                          onChangeAvatar: isSubmitting ? null : (index) => _submitAvatar(context, person, index),
                          onSaveNote: isSubmitting ? null : (note) => _submitNote(context, person, note),
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
              key: const Key('participants_empty_add_button'),
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

/// Design System ID: cps.candidate.participant-tile (candidate, not yet official).
///
/// Participant row with character, data and the inline note.
class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    super.key,
    required this.person,
    required this.isRemoving,
    required this.onRemove,
    required this.onChangeAvatar,
    required this.onSaveNote,
  });

  final PersonViewModel person;
  final bool isRemoving;
  final VoidCallback? onRemove;
  final ValueChanged<int>? onChangeAvatar;
  final Future<bool> Function(String note)? onSaveNote;

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
      child: Column(
        children: [
          ListTile(
            leading: ParticipantAvatarButton(
              key: Key('participant_avatar_button_${person.id}'),
              name: person.name,
              avatarIndex: person.avatarIndex,
              onChanged: onChangeAvatar,
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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: _ParticipantNoteField(personId: person.id, note: person.note, onSave: onSaveNote),
          ),
        ],
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
}

/// Design System ID: cps.candidate.note-field (candidate, not yet official).
///
/// Inline note of a participant in three states: no note (add button), note
/// shown (tap to edit) and editing (free-text field with Save/Cancel). Leaves
/// edit mode only once [onSave] reports the note was persisted. A null
/// [onSave] disables editing while another participants request is in flight.
class _ParticipantNoteField extends StatefulWidget {
  const _ParticipantNoteField({required this.personId, required this.note, required this.onSave});

  /// Mirrors the API column size of the note.
  static const maxLength = 2000;

  final String personId;
  final String? note;
  final Future<bool> Function(String note)? onSave;

  @override
  State<_ParticipantNoteField> createState() => _ParticipantNoteFieldState();
}

class _ParticipantNoteFieldState extends State<_ParticipantNoteField> {
  final _controller = TextEditingController();
  bool _editing = false;
  bool _saving = false;

  @override
  void didUpdateWidget(_ParticipantNoteField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A retry from the error snackbar can persist the note while the field is still open.
    if (_editing && oldWidget.note != widget.note) _editing = false;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startEditing() {
    _controller.text = widget.note ?? '';
    setState(() => _editing = true);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final saved = await widget.onSave!(_controller.text);
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
    final id = widget.personId;

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
            Text(l10n.participantNoteFieldLabel, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            TextField(
              key: Key('participant_note_field_$id'),
              controller: _controller,
              autofocus: true,
              minLines: 2,
              maxLines: 6,
              maxLength: _ParticipantNoteField.maxLength,
              decoration: const InputDecoration(border: InputBorder.none, isDense: true, counterText: ''),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  key: Key('participant_note_cancel_$id'),
                  onPressed: _saving ? null : () => setState(() => _editing = false),
                  child: Text(l10n.cancelButton),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  key: Key('participant_note_save_$id'),
                  onPressed: _saving || widget.onSave == null ? null : _save,
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

    final note = widget.note;
    final onTap = widget.onSave == null ? null : _startEditing;
    final border = Border.all(color: theme.colorScheme.outlineVariant);

    if (note == null) {
      return InkWell(
        key: Key('participant_note_add_$id'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
          decoration: BoxDecoration(border: border, borderRadius: BorderRadius.circular(8)),
          child: Text(l10n.participantNoteAddButton, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
        ),
      );
    }

    return InkWell(
      key: Key('participant_note_view_$id'),
      onTap: onTap,
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
            Text(l10n.participantNoteLabel, style: theme.textTheme.bodySmall?.copyWith(color: muted)),
            const SizedBox(width: 8),
            Expanded(child: Text(note, style: theme.textTheme.bodyMedium)),
          ],
        ),
      ),
    );
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
  // Pre-selected by lot; the user may keep it or pick another one.
  int _avatarIndex = randomParticipantAvatarIndex();
  bool _avatarPicked = false;

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
            const SizedBox(height: 16),
            Text(
              _avatarPicked
                  ? l10n.participantAvatarFieldLabel
                  : '${l10n.participantAvatarFieldLabel} · ${l10n.participantAvatarRandomHint}',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            AvatarPicker(
              selectedIndex: _avatarIndex,
              onChanged: (index) => setState(() {
                _avatarIndex = index;
                _avatarPicked = true;
              }),
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
          key: const Key('participants_add_dialog_submit'),
          onPressed: name.isEmpty
              ? null
              : () => Navigator.of(context).pop(
                    PersonViewModel.fromLocal(name, _ageController.text.trim(), _sex, avatarIndex: _avatarIndex),
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
