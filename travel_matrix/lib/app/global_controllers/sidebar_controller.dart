import 'package:flutter/foundation.dart';
import 'package:travel_matrix/core/services/settings_storage_service.dart';
import 'package:travel_matrix/shared/widgets/responsive_layout_builder.dart';

enum SidebarMode { expanded, collapsed, hidden }

/// Estado do menu lateral por breakpoint (CPS-200). Cada breakpoint guarda a
/// própria preferência, persistida localmente e lida de forma síncrona.
class SidebarController extends ChangeNotifier {
  final SettingsStorageService _storage = SettingsStorageService.instance;
  final Map<ScreenSize, SidebarMode> _modes = {};

  /// Padrão de cada breakpoint: sidebar no desktop, rail no tablet, top bar
  /// (`expanded`) no mobile.
  static SidebarMode defaultFor(ScreenSize size) => size == ScreenSize.tablet ? SidebarMode.collapsed : SidebarMode.expanded;

  /// Próximo estado do ciclo. Desktop: expandida → recolhida → oculta. Tablet
  /// (sem "expandida") e mobile (sem rail) alternam só entre dois estados.
  static SidebarMode next(ScreenSize size, SidebarMode mode) => switch (mode) {
        SidebarMode.expanded => size == ScreenSize.desktop ? SidebarMode.collapsed : SidebarMode.hidden,
        SidebarMode.collapsed => SidebarMode.hidden,
        SidebarMode.hidden => defaultFor(size),
      };

  SidebarMode modeFor(ScreenSize size) => _modes.putIfAbsent(size, () {
        final stored = _storage.getSidebarMode(size.name);
        return SidebarMode.values.asNameMap()[stored] ?? defaultFor(size);
      });

  void cycle(ScreenSize size) {
    final mode = next(size, modeFor(size));
    _modes[size] = mode;
    _storage.saveSidebarMode(size.name, mode.name);
    notifyListeners();
  }
}
