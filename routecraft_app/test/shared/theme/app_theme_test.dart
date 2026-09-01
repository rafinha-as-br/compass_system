import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/src/google_fonts_base.dart' as google_fonts_base;
import 'package:routecraft_app/shared/theme/app_theme.dart';

/// Faz o `google_fonts` enxergar Poppins Regular/SemiBold como já disponíveis nos
/// assets do app, evitando que o teste dispare uma busca de rede real (que sempre
/// falha em `flutter test`, já que o HttpClient é interceptado pelo próprio framework).
class _FakePoppinsAssetManifest extends AssetManifest {
  @override
  List<String> listAssets() => const <String>[
    'assets/fonts/Poppins-Regular.ttf',
    'assets/fonts/Poppins-SemiBold.ttf',
  ];

  @override
  List<AssetMetadata>? getAssetVariants(String key) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    google_fonts_base.assetManifest = _FakePoppinsAssetManifest();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
          return ByteData(4);
        });
  });

  group('TravelAppColors', () {
    test('paleta Compass System (RouteCraft) aplicada corretamente', () {
      expect(TravelAppColors.primary, const Color(0xFF4B0082));
      expect(TravelAppColors.accentGold, const Color(0xFFDAA520));
      expect(TravelAppColors.tertiary, const Color(0xFF2EBB57));
      expect(TravelAppColors.success, const Color(0xFF2EBB57));
      expect(TravelAppColors.textSecondary, const Color(0xFF708090));
      expect(TravelAppColors.background, const Color(0xFFF8F9FA));
    });
  });

  group('AppTheme typography', () {
    test('lightTheme usa Poppins no bodyMedium', () {
      final fontFamily = AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily;
      expect(fontFamily, contains('Poppins'));
    });

    test('darkTheme usa Poppins no bodyMedium', () {
      final fontFamily = AppTheme.darkTheme.textTheme.bodyMedium?.fontFamily;
      expect(fontFamily, contains('Poppins'));
    });

    test('headlineLarge e titleLarge usam peso SemiBold (w600)', () {
      final textTheme = AppTheme.lightTheme.textTheme;
      expect(textTheme.headlineLarge?.fontWeight, FontWeight.w600);
      expect(textTheme.titleLarge?.fontWeight, FontWeight.w600);
    });

    test('bodyMedium e labelMedium usam peso Regular (w400)', () {
      final textTheme = AppTheme.lightTheme.textTheme;
      expect(textTheme.bodyMedium?.fontWeight, FontWeight.w400);
      expect(textTheme.labelMedium?.fontWeight, FontWeight.w400);
    });
  });
}
