import 'dart:math';

/// How many characters the participant avatar catalog has (CPS-175).
///
/// The catalog is append-only and shared with travel_matrix: the API stores
/// only the 1-based index, which is also the number in the asset file name
/// (`assets/avatars/animal_<n>.png`). Never reorder or remove an index.
const int participantAvatarCount = 6;

/// Asset path of the character at the 1-based [index].
String participantAvatarAsset(int index) => 'assets/avatars/animal_$index.png';

/// Whether [index] points at a character this build ships. An index written by
/// a newer build of the other app is unknown here and falls back to initials.
bool isKnownParticipantAvatar(int? index) => index != null && index >= 1 && index <= participantAvatarCount;

/// Random character index, used when a participant is added without a choice.
int randomParticipantAvatarIndex([Random? random]) => (random ?? Random()).nextInt(participantAvatarCount) + 1;
