# Settings Feature (Travel Matrix)

Este módulo é responsável por gerenciar as preferências locais de interface do
usuário do painel do agente (Travel Matrix): tema (claro/escuro) e idioma
(Português/Inglês). É **100% local** — sem chamada de API, sem `domain`/`data`,
consistente com a decisão original da CPS-13.

> **Nota (auditoria CPS-36):** este diretório não contém nenhum arquivo Dart —
> a funcionalidade não vive em `features/settings/`, e sim distribuída em dois
> lugares, descritos abaixo. Uma versão anterior deste README descrevia uma
> `SettingsPage` dedicada (com `RadioListTile` de tema e seletor de idioma
> próprio) que nunca chegou a ser implementada; o texto foi corrigido para
> refletir o que existe de fato no código.

## Onde a funcionalidade vive

* **Estado global:** `SettingsController`
  (`lib/app/global_controllers/settings_controller.dart`) — `ChangeNotifier`
  injetado no topo da árvore (`AppBootstrap`), pois tema e idioma precisam
  afetar a raiz do `MaterialApp` inteiro.
* **UI:** `PreferencesCard`
  (`lib/features/account/presentation/widgets/preferences_card.dart`),
  renderizada dentro da `AccountPage`. Não existe uma tela dedicada nem rota
  `/settings` — o item de navegação lateral rotulado "Settings" leva à mesma
  rota `/account` (`AppRoutes.account`, Branch 3 do `StatefulShellRoute`).

A UI atual é bem mais simples do que a descrita anteriormente:
* Um `SwitchListTile` alterna entre `ThemeMode.light` e `ThemeMode.dark` (sem
  opção "Seguir sistema").
* Um `ListTile` alterna o idioma entre `en`/`pt` a cada toque (sem tela de
  seleção dedicada).

## Persistência

O `SettingsController` persiste a escolha do usuário via
`SettingsStorageService` (`lib/core/services/settings_storage_service.dart`),
que envolve `shared_preferences` (mesmo padrão do `AuthStorageService`,
usado para o token de autenticação). As chaves salvas são `theme_mode`
(nome do enum `ThemeMode`) e `locale` (código do idioma). A leitura ocorre em
`SettingsController.initialize()`, aguardado em `AppBootstrap` antes do
primeiro frame, para que o tema/idioma corretos já apareçam sem "flash" do
valor padrão.

## Localização (i18n)

O módulo utiliza as strings de tradução através da classe `AppLocalizations`,
extraídas dos arquivos `.arb` (`app_en.arb` e `app_pt.arb`):
- `systemPreferences`, `adminDarkMode`, `languageLabel`.

---
*Módulo originado na issue CPS-13; README corrigido na auditoria CPS-36 para
refletir o estado real do código (a persistência descrita aqui foi
implementada nessa mesma auditoria, antes disso o tema/idioma resetavam a
cada reinício do app).*
