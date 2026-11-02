import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:travel_matrix/shared/utils/participant_avatars.dart';
import 'package:travel_matrix/shared/widgets/participant_avatar.dart';

void main() {
  test('only indexes 1..participantAvatarCount are known characters', () {
    expect(isKnownParticipantAvatar(null), isFalse);
    expect(isKnownParticipantAvatar(0), isFalse);
    expect(isKnownParticipantAvatar(1), isTrue);
    expect(isKnownParticipantAvatar(participantAvatarCount), isTrue);
    expect(isKnownParticipantAvatar(participantAvatarCount + 1), isFalse);
  });

  test('a random pick is always a known character and eventually covers the whole catalog', () {
    final random = Random(42);
    final picks = {for (var i = 0; i < 200; i++) randomParticipantAvatarIndex(random)};

    expect(picks.every(isKnownParticipantAvatar), isTrue);
    expect(picks, {for (var i = 1; i <= participantAvatarCount; i++) i});
  });

  test('every catalog index has its image file shipped with the app', () {
    for (var i = 1; i <= participantAvatarCount; i++) {
      expect(File(participantAvatarAsset(i)).existsSync(), isTrue, reason: participantAvatarAsset(i));
    }
  });

  test('the catalog size matches the image files in assets/avatars (keeps the two apps in step)', () {
    final files = Directory('assets/avatars').listSync().whereType<File>().map((f) => f.uri.pathSegments.last).toSet();

    expect(files, {for (var i = 1; i <= participantAvatarCount; i++) 'animal_$i.png'});
  });

  testWidgets('an unknown index falls back to the initials', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: ParticipantAvatar(name: 'Ana Silva', avatarIndex: participantAvatarCount + 1)),
    );

    expect(find.text('AS'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('a known index renders its character image instead of the initials', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ParticipantAvatar(name: 'Ana Silva', avatarIndex: 2)));

    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as ResizeImage).imageProvider, isA<AssetImage>());
    expect(find.text('AS'), findsNothing);
  });
}
