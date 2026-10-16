import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:travel_matrix/app/global_controllers/sidebar_controller.dart';
import 'package:travel_matrix/core/services/settings_storage_service.dart';
import 'package:travel_matrix/shared/widgets/responsive_layout_builder.dart';

void main() {
  Future<SidebarController> newController([Map<String, Object> stored = const {}]) async {
    SharedPreferences.setMockInitialValues(stored);
    SettingsStorageService.resetForTesting();
    await SettingsStorageService.init();
    return SidebarController();
  }

  test('começa no padrão de cada breakpoint: sidebar, rail e top bar', () async {
    final controller = await newController();

    expect(controller.modeFor(ScreenSize.desktop), SidebarMode.expanded);
    expect(controller.modeFor(ScreenSize.tablet), SidebarMode.collapsed);
    expect(controller.modeFor(ScreenSize.mobile), SidebarMode.expanded);
  });

  test('o ciclo do desktop passa por expandida, recolhida e oculta', () async {
    final controller = await newController();
    final seen = <SidebarMode>[];
    for (var i = 0; i < 3; i++) {
      controller.cycle(ScreenSize.desktop);
      seen.add(controller.modeFor(ScreenSize.desktop));
    }

    expect(seen, [SidebarMode.collapsed, SidebarMode.hidden, SidebarMode.expanded]);
  });

  test('tablet alterna só rail e oculta; mobile só top bar e oculta', () async {
    final controller = await newController();

    controller.cycle(ScreenSize.tablet);
    expect(controller.modeFor(ScreenSize.tablet), SidebarMode.hidden);
    controller.cycle(ScreenSize.tablet);
    expect(controller.modeFor(ScreenSize.tablet), SidebarMode.collapsed);

    controller.cycle(ScreenSize.mobile);
    expect(controller.modeFor(ScreenSize.mobile), SidebarMode.hidden);
    controller.cycle(ScreenSize.mobile);
    expect(controller.modeFor(ScreenSize.mobile), SidebarMode.expanded);
  });

  test('cada breakpoint guarda a própria preferência e a restaura ao reabrir', () async {
    final controller = await newController();
    controller.cycle(ScreenSize.desktop); // recolhida
    controller.cycle(ScreenSize.tablet); // oculta

    final reopened = SidebarController();

    expect(reopened.modeFor(ScreenSize.desktop), SidebarMode.collapsed);
    expect(reopened.modeFor(ScreenSize.tablet), SidebarMode.hidden);
    expect(reopened.modeFor(ScreenSize.mobile), SidebarMode.expanded);
  });

  test('valor salvo inválido cai no padrão do breakpoint', () async {
    final controller = await newController({'sidebar_mode_desktop': 'bogus'});

    expect(controller.modeFor(ScreenSize.desktop), SidebarMode.expanded);
  });

  test('notifica os ouvintes a cada troca de estado', () async {
    final controller = await newController();
    var notified = 0;
    controller.addListener(() => notified++);

    controller.cycle(ScreenSize.desktop);

    expect(notified, 1);
  });
}
