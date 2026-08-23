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
