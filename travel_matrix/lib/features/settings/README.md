# Settings Feature (Travel Matrix)

Este módulo é responsável por gerenciar as configurações locais e as preferências de interface do usuário do painel do agente (Travel Matrix). Diferentemente do módulo `account` (que gerencia dados de identidade e credenciais via API), o módulo `settings` é **100% local** e foca em customizações da experiência no dispositivo atual.

## Estrutura do Módulo

O módulo segue a arquitetura padrão do projeto, atualmente contendo apenas a camada de apresentação (`presentation`), uma vez que o controle de estado global e persistência residem nos controladores base da aplicação.

```text
lib/features/settings/
└── presentation/
    └── pages/
        └── settings_page.dart  # Tela principal de configurações
```

## Componentes Principais

### 1. `SettingsPage` (`presentation/pages/settings_page.dart`)
A tela de configurações apresenta uma interface dividida em "Cards" minimalistas, seguindo a linguagem visual *Midnight Terminal* do Compass System (bordas sutis `outlineVariant` e `elevation: 0`). 

A tela possui duas seções principais:
- **Aparência**: Permite a seleção do tema da aplicação com três opções através de `RadioListTile`:
  - **Claro** (`ThemeMode.light`)
  - **Escuro** (`ThemeMode.dark`)
  - **Seguir sistema** (`ThemeMode.system`)
- **Idioma**: Permite a seleção explícita da linguagem da interface (Português/Inglês).

### 2. Integração com o `SettingsController` (Global)
Embora a tela resida nesta feature, o estado que ela manipula vive no controlador global `SettingsController` (`lib/app/global_controllers/settings_controller.dart`). 
- **Motivação**: O tema e o idioma precisam afetar toda a raiz da árvore do Flutter (`MaterialApp`), logo, o controlador precisa estar acessível globalmente (injetado no `AppBootstrap`).
- **Persistência**: O controlador utiliza o pacote `shared_preferences` para salvar a escolha do usuário (`theme_mode` e `locale`), garantindo que as preferências sejam mantidas entre sessões.

## Rotas
O módulo de configurações é acessado através da rota `/settings`, sendo registrado como uma *Branch* independente (`Branch 4`) no sistema de navegação `StatefulShellRoute` do `GoRouter` (`lib/app/router/private_shell.dart`).

## Localização (i18n)
O módulo utiliza as strings de tradução através da classe `AppLocalizations`, extraídas dos arquivos `.arb` (`app_en.arb` e `app_pt.arb`):
- `settingsTitle`
- `appearanceSection`
- `themeLight` / `themeDark` / `themeSystem`
- `languageSection`

---
*Módulo criado como parte da issue CPS-13.*
