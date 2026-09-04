# Maestro test flows — Compass System

Flows automatizados de QA para Android, mantidos pela skill `jira-qa-executor`.
Cobrem apenas o **RouteCraft** (`routecraft_app`) — o Travel Matrix é testado
via Web (Claude in Chrome), não tem executor Android.

## O que é patrimônio permanente vs. exploração pontual

Todo arquivo `.yaml` dentro desta pasta é reaproveitável entre issues futuras
que tocam no mesmo fluxo — nunca recrie um flow equivalente a um que já
existe aqui. Screenshots tirados durante `maestro test` (via `takeScreenshot`)
não ficam versionados; servem como evidência da execução, não como artefato
permanente.

## Estrutura

```
.maestro/
├── README.md
└── routecraft/
    ├── auth/
    │   ├── login_success.yaml                 — login com credenciais válidas
    │   ├── login_invalid_credentials.yaml      — mensagem de erro genérica
    │   ├── login_retry_after_error.yaml        — retry após erro limpa o estado (bug fix CPS-43)
    │   ├── forgot_password.yaml                — solicita código de redefinição
    │   ├── reset_password_and_login.yaml       — continuação do forgot_password: aplica o
    │   │                                          código e loga com a nova senha. Requer o
    │   │                                          token do PasswordResetToken (consultar a
    │   │                                          tabela `password_reset_token` no Postgres
    │   │                                          logo após rodar forgot_password.yaml — não
    │   │                                          roda sozinho, App precisa estar na tela
    │   │                                          "Enter your code")
    │   └── session_persists_on_restart.yaml    — sessão válida sobrevive a restart do app
    └── regression/
        ├── create_route_smoke.yaml             — abre o wizard de criação de rota
        └── home_screens_smoke.yaml             — navega pelas 4 opções da Home sem crash
```

## Gotcha: `clearState` não limpa o Keychain

`launchApp: clearState: true` limpa os dados do app, mas **não** o
Android Keystore-backed secure storage usado pelo `flutter_secure_storage`
(onde o RouteCraft guarda o token JWT). Todo flow que assume estado
deslogado no início precisa também de `- clearKeychain` logo após o
`launchApp` — sem isso, se um flow anterior na mesma execução deixou uma
sessão válida salva, o app abre direto na Home e o flow falha tentando
encontrar "Email" (elemento só visível na tela de login). Confirmado em
2026-09-04 durante QA de CPS-43: `login_invalid_credentials.yaml`,
`login_retry_after_error.yaml`, `session_persists_on_restart.yaml` e
`forgot_password.yaml` estavam sem esse passo (só `login_success.yaml` o
tinha) — corrigido nesta mesma rodada.

## Como rodar

```bash
cd compass_system
maestro test .maestro/routecraft/                       # suíte inteira
maestro test .maestro/routecraft/auth/login_success.yaml # um flow específico
```

## Pré-requisitos de ambiente (ver skill `jira-qa-executor` para o passo a passo completo)

- AVD `QA - Claude` (identificador real `QA_-_Claude`) já criado no Android Studio.
- Backend local de pé (`docker compose up -d` dentro de `compass-api/`) e
  `adb reverse tcp:8081 tcp:8081` configurado antes de abrir o app — o
  RouteCraft fala com a API real via `HttpApiClient`.
- APK debug buildado a partir de `develop` atualizado
  (`flutter build apk --debug` dentro de `routecraft_app/`).
- Usuários de teste precisam existir no backend antes de rodar os flows de
  auth — não há flow de cadastro automatizado aqui ainda. Usuário CLIENTE de
  referência usado nestes flows: `joao.teste@teste.com` / `senha123`.

## Testabilidade — limitações conhecidas

- **Expiração de JWT (CPS-45):** o token expira em 24h
  (`jwt.expiration-ms`, default `86400000`). Não há flow E2E aqui testando o
  caso "token expirado é tratado como sessão inválida" — isso exigiria
  esperar 24h ou manipular o secure storage do app diretamente por fora do
  Maestro. A lógica de fronteira (`exp` futuro/passado/ausente/não-numérico)
  é coberta pelos testes unitários de `JwtPayloadDecoder.isExpired`
  (`routecraft_app/test/`), não por este suite. `session_persists_on_restart.yaml`
  cobre o caminho inverso: token válido não é invalidado incorretamente.
  **Atualização (CPS-82):** a compass-api agora expõe um mecanismo real de
  invalidação manual (`POST /users/{id}/force-logout`, verificado via
  `sessionInvalidatedAt` no `JwtAuthenticationFilter`) — viabiliza testar
  "sessão forçadamente expirada" sem esperar 24h, mas ainda não existe um
  flow Maestro E2E para esse caminho aqui (requer chamar o endpoint como
  agente pelo Travel Matrix ou via API enquanto o RouteCraft está logado).
