import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/global_controllers/settings_controller.dart';
import 'package:travel_matrix/core/services/settings_storage_service.dart';

void main() {
  setUp(() {
    SettingsStorageService.resetForTesting();
  });

  group('SettingsController.initialize', () {
    test('falls back to light theme and Portuguese locale when nothing was saved', () async {
      SharedPreferences.setMockInitialValues({});
      await SettingsStorageService.init();
      final controller = SettingsController();

      await controller.initialize();

      expect(controller.themeMode, ThemeMode.light);
      expect(controller.locale.languageCode, 'pt');
    });

    test('loads the persisted theme mode and locale, which win over the default', () async {
      SharedPreferences.setMockInitialValues({'theme_mode': 'dark', 'locale': 'en'});
      await SettingsStorageService.init();
      final controller = SettingsController();

      await controller.initialize();

      expect(controller.themeMode, ThemeMode.dark);
      expect(controller.locale.languageCode, 'en');
    });
  });

  group('SettingsController.toggleTheme', () {
    test('flips between light and dark, notifies once, and persists the new value', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await SettingsStorageService.init();
      final controller = SettingsController();

      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.toggleTheme();
      expect(controller.themeMode, ThemeMode.dark);
      expect(notifications, 1);

      controller.toggleTheme();
      expect(controller.themeMode, ThemeMode.light);
      expect(notifications, 2);

      expect(await storage.getThemeMode(), ThemeMode.light.name);
    });
  });

  group('SettingsController.toggleLanguage', () {
    test('flips between pt and en, and persists the new value', () async {
      SharedPreferences.setMockInitialValues({});
      final storage = await SettingsStorageService.init();
      final controller = SettingsController();

      controller.toggleLanguage();
      expect(controller.locale.languageCode, 'en');

      controller.toggleLanguage();
      expect(controller.locale.languageCode, 'pt');

      expect(await storage.getLocale(), 'pt');
    });
  });
}
