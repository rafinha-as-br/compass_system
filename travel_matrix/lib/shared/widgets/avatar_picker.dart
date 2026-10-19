import 'package:flutter/material.dart';
import 'package:travel_matrix/l10n/app_localizations.dart';
import 'package:travel_matrix/shared/utils/participant_avatars.dart';
import 'package:travel_matrix/shared/widgets/participant_avatar.dart';

/// Grid with every character of the participant avatar catalog, three per row
/// (`cps.candidate.avatar-picker`). Fixed-size cells keep it safe inside an
/// [AlertDialog], whose intrinsic sizing rules out lazy or layout-driven grids.
class AvatarPicker extends StatelessWidget {
  const AvatarPicker({super.key, required this.selectedIndex, required this.onChanged});

  final int? selectedIndex;
  final ValueChanged<int> onChanged;

  static const double _cellSize = 72;
  static const double _spacing = 10;
  static const int _perRow = 3;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return SizedBox(
      width: _cellSize * _perRow + _spacing * (_perRow - 1),
      child: Wrap(
        spacing: _spacing,
        runSpacing: _spacing,
        children: [
          for (var index = 1; index <= participantAvatarCount; index++)
            Semantics(
              button: true,
              selected: index == selectedIndex,
              label: l10n.participantAvatarOptionSemantics(index),
              child: InkWell(
                key: Key('avatar_picker_option_$index'),
                borderRadius: BorderRadius.circular(10),
                onTap: () => onChanged(index),
                child: Container(
                  width: _cellSize,
                  height: _cellSize,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: index == selectedIndex ? theme.colorScheme.primary.withValues(alpha: 0.03) : null,
                    border: Border.all(
                      width: 2,
                      color: index == selectedIndex ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                    ),
                  ),
                  child: ParticipantAvatar(name: '', avatarIndex: index, radius: _cellSize * 0.35),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Lets the user pick a character in a small dialog; resolves to the picked
/// index, or null when dismissed.
Future<int?> showAvatarPickerDialog(BuildContext context, {required int? current}) {
  final l10n = AppLocalizations.of(context)!;
  return showDialog<int>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(l10n.participantAvatarFieldLabel),
      content: AvatarPicker(selectedIndex: current, onChanged: (index) => Navigator.of(dialogContext).pop(index)),
    ),
  );
}

/// A participant's avatar that opens the character picker when tapped; [onChanged]
/// receives the newly picked index. A null [onChanged] disables the button.
class ParticipantAvatarButton extends StatelessWidget {
  const ParticipantAvatarButton({
    super.key,
    required this.name,
    required this.avatarIndex,
    required this.onChanged,
    this.radius = 20,
  });

  final String name;
  final int? avatarIndex;
  final double radius;
  final ValueChanged<int>? onChanged;

  @override
  Widget build(BuildContext context) {
    final onChanged = this.onChanged;
    return Tooltip(
      message: AppLocalizations.of(context)!.changeParticipantAvatarTooltip,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onChanged == null
            ? null
            : () async {
                final index = await showAvatarPickerDialog(context, current: avatarIndex);
                if (index != null && index != avatarIndex) onChanged(index);
              },
        child: ParticipantAvatar(name: name, avatarIndex: avatarIndex, radius: radius),
      ),
    );
  }
}
