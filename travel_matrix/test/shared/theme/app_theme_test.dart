import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/src/google_fonts_base.dart' as google_fonts_base;
import 'package:travel_matrix/shared/theme/app_theme.dart';

/// Faz o `google_fonts` enxergar Inter Regular/Medium/SemiBold como já
/// disponíveis nos assets do app, evitando que o teste dispare uma busca de
/// rede real (que sempre falha em `flutter test`, já que o HttpClient é
/// interceptado pelo próprio framework).
class _FakeInterAssetManifest extends AssetManifest {
  @override
  List<String> listAssets() => const <String>[
        'assets/fonts/Inter-Regular.ttf',
        'assets/fonts/Inter-Medium.ttf',
        'assets/fonts/Inter-SemiBold.ttf',
      ];

  @override
  List<AssetMetadata>? getAssetVariants(String key) => null;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    google_fonts_base.assetManifest = _FakeInterAssetManifest();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (ByteData? message) async {
      return ByteData(4);
    });
  });

  group('TravelAppColors', () {
    test('paleta Compass System (Travel Matrix) aplicada corretamente', () {
      expect(TravelAppColors.primary, const Color(0xFF4B0082));
      expect(TravelAppColors.accentGold, const Color(0xFFDAA520));
      expect(TravelAppColors.success, const Color(0xFF2EBB57));
      expect(TravelAppColors.textSecondary, const Color(0xFF708090));
      expect(TravelAppColors.background, const Color(0xFFF8F9FA));
    });
  });

  group('AppSemanticColors dark theme', () {
    test('nao usa mais os literais antigos do Midnight Terminal', () {
      final dark = AppTheme.darkTheme.semanticColors;
      expect(dark.success, isNot(const Color(0xFF65C18C)));
      expect(dark.warning, isNot(const Color(0xFFE4B363)));
      expect(dark.info, isNot(const Color(0xFF7BB2D9)));
    });
  });

  group('AppTheme typography', () {
    test('lightTheme usa Inter no bodyMedium', () {
      final fontFamily = AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily;
      expect(fontFamily, contains('Inter'));
    });

    test('darkTheme usa Inter no bodyMedium', () {
      final fontFamily = AppTheme.darkTheme.textTheme.bodyMedium?.fontFamily;
      expect(fontFamily, contains('Inter'));
    });

    test('headlineSmall e titleLarge usam peso SemiBold (w600)', () {
      final textTheme = AppTheme.lightTheme.textTheme;
      expect(textTheme.headlineSmall?.fontWeight, FontWeight.w600);
      expect(textTheme.titleLarge?.fontWeight, FontWeight.w600);
    });

    test('bodyMedium usa peso Regular (w400) e labelMedium usa Medium (w500)', () {
      final textTheme = AppTheme.lightTheme.textTheme;
      expect(textTheme.bodyMedium?.fontWeight, FontWeight.w400);
      expect(textTheme.labelMedium?.fontWeight, FontWeight.w500);
    });
  });
}
