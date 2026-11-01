import 'package:flutter/material.dart';
import 'package:routecraft_app/shared/utils/participant_avatars.dart';

/// Round avatar of a participant: the chosen character when there is a known
/// [avatarIndex], the name's initials otherwise (`cps.candidate.participant-avatar`).
class ParticipantAvatar extends StatelessWidget {
  const ParticipantAvatar({super.key, required this.name, this.avatarIndex, this.radius = 14});

  final String name;
  final int? avatarIndex;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final index = avatarIndex;
    if (!isKnownParticipantAvatar(index)) return _initials(context);

    final size = radius * 2;
    return ClipOval(
      child: Image.asset(
        participantAvatarAsset(index!),
        width: size,
        height: size,
        fit: BoxFit.cover,
        // The source art is ~1250px; decode it at display size only.
        cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
        errorBuilder: (context, _, _) => _initials(context),
      ),
    );
  }

  Widget _initials(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    final tokens = name.trim().split(RegExp(r'\s+')).where((t) => t.isNotEmpty).toList();
    final text = tokens.isEmpty
        ? ''
        : tokens.length == 1
            ? tokens.first.substring(0, 1).toUpperCase()
            : (tokens.first.substring(0, 1) + tokens.last.substring(0, 1)).toUpperCase();

    return CircleAvatar(
      radius: radius,
      backgroundColor: color.withValues(alpha: 0.12),
      child: Text(text, style: TextStyle(fontSize: radius * 0.8, fontWeight: FontWeight.w700, color: color)),
    );
  }
}
