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
    ├── home/
    │   ├── home_empty_no_routes.yaml            — cliente sem nenhuma viagem (cenário 1, CPS-128)
    │   ├── home_empty_no_trip_in_progress.yaml  — cliente com viagens mas nenhuma em andamento
    │   │                                           (cenário 2, CPS-128), inclui o link "See my
    │   │                                           trips" trocando para a aba Viagens
    │   └── home_trip_in_progress.yaml           — cliente com viagem em andamento mostra só o
    │                                               TravelCard dela, sem Upcoming/Completed (CPS-128)
    └── regression/
        ├── create_route_smoke.yaml             — abre o wizard de criação de rota
        └── home_screens_smoke.yaml             — navega pelas 3 abas da bottom nav
                                                    (Início/Roteiro/Conta) sem crash
```

## Atualização 2026-09-27 (QA da CPS-128 — Início mostra só a viagem em andamento)

Os 3 flows novos em `home/` usam usuários de teste criados nesta rodada de QA
(`diego.alves@teste.com`, `elisa.pinto@teste.com`, `carla.rocha@teste.com`,
todos com senha `senha123`) em vez de `joao.teste@teste.com` — que continua
com a senha divergente já documentada abaixo (`compass123`, não `senha123`),
confirmado novamente nesta rodada (`login_success.yaml` ainda falha por esse
motivo, não é regressão da CPS-128).

**Gotcha confirmado nesta rodada: locale do emulador é en-US, não pt-BR.**
Apesar do app ter chaves de l10n em `app_pt.arb`, o AVD `QA - Claude` roda em
inglês por padrão — todas as strings visíveis (`Email`/`Password`/`LOGIN`,
`No routes yet`, `In progress`, etc.) são as de `app_en.arb`. Os flows desta
pasta usam texto em inglês por esse motivo; se o locale do AVD mudar, os
flows precisam ser revisados.

**Gotcha confirmado nesta rodada: TravelCard não é matchável por texto.**
O card de viagem (usado tanto na Início quanto na aba Viagens) expõe
título+rota+datas como um único `Semantics`/label combinado com `\n`
(`"Viagem a X\nSao Paulo - SP → X\n1–5 Nov"`), não como nós de texto
separados — o matcher de `assertVisible`/`tapOn` do Maestro não encontra
substring dentro desse label combinado. É a mesma limitação já documentada
abaixo para a bottom nav, agora confirmada também no card de viagem. Os
flows desta pasta verificam o texto do estado (label da seção, mensagens de
estado vazio) e usam `takeScreenshot` como evidência visual de qual viagem
aparece, em vez de tentar casar o nome da viagem por texto. Se o
`TravelCard` ganhar um identificador estável (`Key`/semântica separada por
campo), os flows podem ser reforçados com uma asserção direta.

## Atualização 2026-09-06 (QA do épico CPS-83/84–97 — RouteCraft Redesign)

A CPS-84 substituiu a Home antiga (4 botões, `Navigator.push`) por
`go_router` com shell de bottom navigation (Início/Roteiro/Conta). Isso
quebrou as asserções `"RouteCraft Login"`/`"RouteCraft Home"` em quase
todos os flows de auth (textos removidos pelo redesenho de CPS-87) e todo
o corpo do antigo `home_screens_smoke.yaml` (ações "Visualize Routes &
Itineraries"/"User Account & Settings" não existem mais). Todos os flows
afetados foram corrigidos e reverificados nesta rodada — `login_success`,
`login_invalid_credentials`, `login_retry_after_error`,
`session_persists_on_restart`, `create_route_smoke` rodaram e passaram;
`reset_password_and_login` teve só a asserção de texto corrigida (mesmo
texto já confirmado em outras telas), sem re-execução E2E completa nesta
rodada (exigiria repetir o fluxo de token de reset).

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

  **Gotcha confirmado em 2026-09-08:** a senha real atual desse usuário no
  banco de QA é `compass123`, não `senha123` — os flows deste diretório
  (`login_success.yaml` e os demais em `auth/`) falham com "E-mail ou senha
  incorretos" até serem corrigidos ou até a senha ser resetada de volta.
  Suspeita: uma rodada de QA anterior usou o fluxo de reset de senha (ver
  `routecraft_app/.maestro/README.md`, que já documenta `compass123` como
  senha corrente) e a alterou no banco compartilhado, sem atualizar estes
  flows. Além disso, existe uma **segunda árvore de flows Maestro** em
  `routecraft_app/.maestro/` (common/home/itinerary/account), mais recente
  e com o `login_as_joao.yaml` já usando a senha correta — as duas árvores
  não foram consolidadas; decidir com Rafinha qual delas é a canônica antes
  da próxima rodada, em vez de as duas continuarem divergindo.

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

- **Bottom nav (CPS-84) não é tocável por texto:** os destinos do
  `NavigationBar` ("Início"/"Roteiro"/"Conta") só expõem o rótulo via um
  `content-desc` composto (`"Itinerary\nTab 2 of 3"`) — não existe um nó de
  `text` com só o rótulo. `tapOn: "Itinerary"` falha com "Element not
  found", confirmado empiricamente em 2026-09-06 (CLI Maestro 2.8.0), tanto
  isolado quanto full-flow. Não é um problema de acessibilidade real (um
  leitor de tela anuncia "Itinerary, Tab 2 of 3" normalmente) — é uma
  limitação do matcher de texto do Maestro para esse tipo de nó. Solução
  usada em `home_screens_smoke.yaml`: `tapOn: point: "X%, Y%"` (último
  recurso documentado na skill `jira-qa-executor`), mirando a faixa
  aproximada de cada aba (~17%/50%/83% horizontal, ~93% vertical). Se o
  layout da bottom nav mudar, esses percentuais precisam ser reajustados.
