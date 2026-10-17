# Maestro test flows — Travel Matrix (Android)

Flows automatizados de QA Android para o **Travel Matrix**, mantidos pela
skill `jira-qa-executor`. Primeira execução de ponta a ponta do Travel Matrix
no Android, feita durante o QA de CPS-158/CPS-159 (2026-09-29) — antes disso
o Travel Matrix só era testado via Web (Claude in Chrome).

## Estrutura

```
.maestro/travel_matrix/
├── README.md
├── auth/
│   └── login_qa_agent.yaml              — login com agente fixo de QA
└── travels/
    ├── overview_and_participants_smoke.yaml  — navega às abas Overview/Participants
    └── participants_add_remove.yaml          — CRUD completo de participante
```

## Usuário de teste

`qa.claude.cps114@compass.test` / `QaClaude123!` — agente criado via
`POST /api/auth/cadastrar/agente` durante o QA de CPS-158/CPS-159
especificamente para ter uma credencial estável, sem depender de nenhum
agente pré-existente no seed do banco. Reutilizar em execuções futuras.

Para recriar a conta: rode `python compass-api/scripts/seed_test_data.py`. Ele cadastra a
empresa `compass.test` e este agente via `POST /api/auth/cadastrar/agente` (header
`X-Bootstrap-Key`, valor de `COMPASS_BOOTSTRAP_KEY`; no `compass-api/docker-compose.yml` o
default é `dev-bootstrap-key`; objeto `company` no corpo — sem a chave, 403; sem `company`, 400),
e em seguida cria os clientes e as viagens da mesma empresa. Viagens e clientes são isolados por
empresa: um agente só vê os dados da própria empresa, então os dados de QA precisam ser criados
a partir da empresa deste agente (o seed já faz isso).

## Viagem de teste usada nos flows

`QA Trip CPS-89` (id `8faace8e-d568-4e15-8a15-60c653dcc587`) — primeira linha
da lista "All Travels" no seed atual do banco, com 0 participantes. Os flows
assumem que ela continua sendo a primeira linha e que fica com 0 participantes
entre execuções (o flow de CRUD adiciona e remove, sem deixar resíduo).

## Como rodar

```bash
cd compass_system
maestro test .maestro/travel_matrix/                                    # suíte inteira
maestro test .maestro/travel_matrix/travels/participants_add_remove.yaml # um flow específico
```

Pré-requisitos: AVD `QA - Claude` (`QA_-_Claude`) já de pé e com boot
completo, `adb reverse tcp:8081 tcp:8081` configurado, backend local via
docker compose de pé, APK debug instalado (`flutter build apk --debug` dentro
de `travel_matrix/`, depois `adb install -r`).

## Atualização 2026-10-16 (QA do Epic CPS-178 — layout responsivo)

O shell responsivo (CPS-181: top bar no mobile) e a landing/login em coluna única
(CPS-198) já estão em `develop`. Consequências para os flows:

* `auth/login_qa_agent.yaml` foi reescrito: agora os campos expõem o hint
  (`Email`/`Password`) e são tocados por texto, sem coordenadas percentuais (as de
  83%,58% / 83%,65% deixaram de valer). Validado no emulador em 2026-10-16.
* Os flows de `travels/` ainda usam coordenadas calibradas para a sidebar antiga
  (nav lateral por `point`) e **precisam ser recalibrados** para a top bar do mobile;
  não foram reexecutados nesta rodada.
* O banco local pode ser recriado: se o login falhar com "E-mail ou senha incorretos",
  rode `compass-api/scripts/seed_test_data.py` (recria o agente, a empresa, os clientes e as viagens).
* Testabilidade: a top bar e o botão de recolher/reabrir menu (CPS-200) não têm
  `content-desc` próprio; só são tocáveis por `point`. Nenhum flow permanente foi criado
  para eles.

A seção abaixo (CPS-167) descreve o estado anterior ao shell responsivo e fica como
histórico das coordenadas.

## ⚠️ Bug de shell conhecido — CPS-167 (histórico, shell anterior)

O shell do Travel Matrix **não é responsivo no Android**: a navegação lateral
(Dashboard/Booking/Users, estilo desktop) nunca colapsa para um formato
mobile, consumindo boa parte da largura mesmo num phone normal. Isso causa
overflow (`RenderFlex "RIGHT/BOTTOM OVERFLOWED BY N PIXELS"`) e sobreposição
de elementos em praticamente toda tela do app — rastreado em
[CPS-167](https://rafinha84dev.atlassian.net/browse/CPS-167). Confirmado em
telas pré-existentes (Dashboard, All Travels, Route View, Itinerary View) e
não apenas nas abas novas do épico CPS-114 — não é regressão de CPS-158/159,
é causa raiz no shell.

**Consequência direta para os flows desta pasta**: os elementos afetados
mudam de posição/tamanho de forma imprevisível conforme a quantidade de
conteúdo em cada linha (o wrap caractere-por-caractere faz a altura de cada
linha da lista de participantes variar). As coordenadas percentuais
(`tapOn: point`) documentadas abaixo são válidas **apenas enquanto o shell
permanecer no layout atual** — quando CPS-167 for corrigido, este flow
provavelmente precisa ser reescrito com coordenadas novas (e, na melhor das
hipóteses, menos elementos vão precisar de coordenada, já que o motivo raiz
de vários rótulos sumirem é o próprio overflow).

## Testabilidade — limitações conhecidas

* **Nav lateral (Dashboard/Booking/Users) não é tocável por texto.** Nenhum
  desses três itens aparece na árvore de semântica do Android (confirmado via
  `maestro hierarchy` em telas diferentes) — nem mesmo como `content-desc`
  composto (diferente do caso já documentado do RouteCraft). Navegados por
  `tapOn: point` percentual, último recurso.
* **Lista "All Travels" não é tocável por texto.** Pelo mesmo motivo do item
  acima (nomes de viagem/cliente não aparecem na árvore de semântica) e
  agravado pelo bug de CPS-167 (cada célula quebra caractere-por-caractere).
  A primeira linha é tocada por coordenada percentual, assumindo a ordem
  estável do seed atual.
* **As 4 abas da tela de viagem (Overview/Route View/Itinerary View/
  Participants) TÊM rótulo de acessibilidade**, mas cada rótulo é multi-linha
  (ex.: `"Participants\nTab 4 of 4"`) — **o Maestro faz match de regex contra
  a STRING INTEIRA do nó, não substring** (confirmado isolando o caso: um
  seletor com só o texto visível falha sistematicamente se houver texto
  adicional depois, mesmo com o texto procurado sendo um prefixo exato). Por
  isso os seletores destes flows usam sufixo `[\s\S]*` (equivalente a
  `DOTALL`) em vez do nome puro da aba.
* **`assertVisible`/`extendedWaitUntil: visible` só funcionam de forma
  confiável em elementos CLICÁVEIS neste app.** Nós de texto puro (`View` sem
  `clickable`), mesmo com `accessibilityText` presente e bounds válidos no
  hierarchy dump, falham a asserção sistematicamente (confirmado isolando o
  caso: `assertVisible` num botão passa, no mesmo tipo de nó sem `clickable`
  falha sempre). Por isso as confirmações de estado nestes flows sempre miram
  um elemento clicável (botão, aba) em vez de texto de conteúdo.
* **Campo "Name" do modal "Add participant" (e "Email"/"Password" da tela de
  login) não expõem hint/rótulo como semântica.** Sintoma adicional do bug de
  CPS-167 — o hint text não tem espaço para renderizar e desaparece por
  completo, em vez de truncar. Preenchidos por coordenada percentual.
* **Teclado cobre o campo seguinte se não for fechado.** Depois de
  `inputText` num campo, se o próximo passo for `tapOn: point` num campo
  abaixo, o teclado on-screen pode estar cobrindo a posição — usar `back`
  para fechar o teclado antes do próximo `tapOn: point` resolve.
* **Botão "Remove participant" tem rótulo exato (sem sufixo)** — `tapOn:
  "Remove participant"` funciona normalmente, sem precisar do sufixo
  `[\s\S]*`. Com só um participante na viagem de teste, o seletor é
  inambíguo; se a viagem usada tiver mais de um participante, o seletor
  sempre mira o primeiro match.
