import 'package:flutter_test/flutter_test.dart';
import 'package:routecraft_app/app/controllers/settings_controller.dart';

void main() {
  group('SettingsController locale', () {
    test('defaults to Portuguese regardless of the system language', () {
      final controller = SettingsController();

      expect(controller.locale.languageCode, 'pt');
    });

    test('toggleLanguage flips between pt and en and notifies', () {
      final controller = SettingsController();
      var notifications = 0;
      controller.addListener(() => notifications++);

      controller.toggleLanguage();
      expect(controller.locale.languageCode, 'en');

      controller.toggleLanguage();
      expect(controller.locale.languageCode, 'pt');
      expect(notifications, 2);
    });
  });
}
