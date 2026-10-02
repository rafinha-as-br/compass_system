# Relatório — Fila de notificação não dispara ao criar roteiro (RouteCraft)

**Data:** 2026-10-02
**Contexto:** investigação de "notificações não aparecem na fila (mobile/web) quando um roteiro é alterado", feita em sessão de chat com Claude. Este arquivo documenta o estado atual e o que falta implementar, para retomar numa sessão separada.

---

## Resumo

Existem **dois bugs distintos** na mesma funcionalidade (fila de notificação de roteiro). O primeiro já foi corrigido e validado. O segundo foi encontrado durante a validação do primeiro e **ainda não foi corrigido** — é o assunto principal deste relatório.

| # | Bug | Status |
|---|---|---|
| 1 | Runtime Package (`.release/runtime/`) não tinha RabbitMQ/ntfy | ✅ **Corrigido** — commit `984b38a`, promovido para `release/current` em `9b4cec8` |
| 2 | `POST /travels` (criação de roteiro pelo RouteCraft) nunca publica notificação, e a travel criada fica sem `clientId`/`agentId` | ❌ **Pendente** — assunto deste relatório |

---

## Bug 1 (já corrigido) — RabbitMQ ausente no Runtime Package

O Runtime Package (`.release/runtime/docker-compose.yml`), usado pra rodar a pré-release localmente, nunca ganhou os serviços `rabbitmq`/`ntfy` que a CPS-146 (mensageria de notificações) exige — só existiam em `compass-api/docker-compose.yml` (ambiente de dev). Sem o broker, `NotificationEventRelay` falhava silenciosamente ao publicar (só logava erro, nunca derrubava a operação), e a fila ficava sempre vazia.

**Corrigido** adicionando `rabbitmq` + `ntfy` ao `.release/runtime/docker-compose.yml` (commit `984b38a` em `develop`, promovido para `release/current` em `9b4cec8`). Confirmado rodando: `docker ps` mostra `compass-runtime-rabbitmq-1` e `compass-runtime-ntfy-1` no ar, e os logs do backend mostram a conexão AMQP estabelecida com sucesso (depois de um retry automático nos primeiros ~10s de boot — corrida normal entre os containers, sem healthcheck no `rabbitmq`, não é um problema real).

---

## Bug 2 (pendente) — criação de roteiro no RouteCraft não notifica ninguém

### Evidência

Criei um roteiro de teste no RouteCraft (emulador) contra a pré-release rodando localmente. Resultado na tabela `travel`:

```sql
id                                   | travel_name | client_name | client_id | agent_id | travel_status
1c6333f0-7115-47af-a375-e360d85dd181 | RRota 2     | João Teste  |  (vazio)  | (vazio)  | route_created
```

`client_id` e `agent_id` saíram **nulos**, e nenhuma notificação foi publicada.

### Causa raiz (duas partes que se somam)

**Parte A — o endpoint de criação não publica evento nenhum.**

Criar um roteiro novo no RouteCraft chama [`RouteCreationController.submitRoute()`](routecraft_app/lib/features/route_creation/presentation/controllers/route_creation_controller.dart:322) → `POST /travels` → [`TravelController.createTravel()`](compass-api/src/main/java/com/compass/compass_system/travel/TravelController.java:46):

```java
@PostMapping
public ResponseEntity<Travel> createTravel(@RequestBody Travel travel) {
    Travel saved = travelRepository.save(travel);
    return ResponseEntity.ok(saved);
}
```

Compare com [`upsertRoutePlan`](compass-api/src/main/java/com/compass/compass_system/travel/TravelController.java:143) (usado para *editar* um roteiro já existente), que é `@Transactional` e publica `NotificationEvent`. O `createTravel` nunca ganhou essa lógica — provavelmente porque a notificação (CPS-146) foi implementada depois, e só foi aplicada aos endpoints PUT de upsert, sem revisitar o POST de criação.

**Parte B — mesmo publicando, não haveria destinatário.**

A entidade `Travel` do RouteCraft não tem (e nunca teve) campos `clientId`/`agentId`:
- [`travel.dart`](routecraft_app/lib/features/travels/domain/entities/travel.dart) (entidade de domínio) — sem esses campos.
- [`travel_dto.dart`](routecraft_app/lib/features/travels/data/dtos/travel_dto.dart) (`toJson()`) — sem esses campos.
- [`api_fields.dart`](routecraft_app/lib/core/constants/api_fields.dart) (`TravelApiFields`) — sem constantes para eles.

Isso é por design original: o comentário em [`Travel.java:18-20`](compass-api/src/main/java/com/compass/compass_system/travel/Travel.java:18) diz "*Set at creation from the payload Travel Matrix already sends (clientId/agentId)*" — ou seja, só o fluxo de criação pelo **Travel Matrix** (agente cria a viagem para um cliente, em [`travel_creation_page.dart:118-134`](travel_matrix/lib/features/travels/presentation/pages/builds/travel_creation_page.dart:118), lendo `AuthController.userId`) sempre populou os dois IDs. O fluxo de criação pelo **RouteCraft** (cliente, self-service) nunca foi atualizado para fazer o mesmo.

Mesmo que o `createTravel` publicasse o evento, [`NotificationService.notify()`](compass-api/src/main/java/com/compass/compass_system/notification/NotificationService.java:19) descarta silenciosamente quando `recipientId` é nulo (comportamento intencional, não é bug nessa parte).

> Confirmação de arquitetura: o comentário em [`travel.dart:39-40`](routecraft_app/lib/features/travels/domain/entities/travel.dart:39) ("*The client creates and refines the route; the itinerary is read-only here — building it is exclusive to the agent in Travel Matrix*") confirma que o cliente criar o roteiro direto no RouteCraft **é o fluxo certo**, não um desvio. O que falta é só a identificação (client/agent) e a notificação.

### De onde viria o `clientId` no RouteCraft

O JWT que o RouteCraft já guarda (via `AuthService`) carrega o claim `userId` (ver [`JwtUtil.java:38`](compass-api/src/main/java/com/compass/compass_system/security/JwtUtil.java:38): `.claim("userId", userId)`). O decoder já existe e já é usado em `AuthService.isAuthenticated()` ([`auth_service.dart:70-76`](routecraft_app/lib/core/services/auth_service.dart:70), `JwtPayloadDecoder.decode(token)`). Não precisa de chamada nova ao backend — só decodificar o token já guardado e ler `claims['userId']`.

---

## Decisão já tomada por Rafinha (nesta conversa)

- ✅ RouteCraft **deve** enviar `clientId` na criação (extraído do JWT, claim `userId`, igual ao Travel Matrix faz com o agente).
- ⚠️ **Stopgap temporário**: todo roteiro criado pelo RouteCraft usa `agentId = 1` fixo, só para a notificação ter um destinatário e o fluxo "funcionar" enquanto não existe atribuição real de agente.
- ❌ **Fora de escopo por agora** (decidir depois, em outra sessão): como um agente de verdade fica sabendo de um roteiro sem agente — não existe hoje nenhum mecanismo de fila/pool de atribuição, nem notificação broadcast para "todos os agentes". O hardcode do agente `1` é só pra desbloquear o teste local, **não é a solução final**.

---

## Plano de implementação sugerido (para a próxima sessão)

### 1. `routecraft_app` — enviar `clientId` e `agentId` fixo na criação

- `routecraft_app/lib/core/constants/api_fields.dart`: adicionar `clientId` e `agentId` em `TravelApiFields`.
- `routecraft_app/lib/features/travels/domain/entities/travel.dart`: adicionar campos `clientId`/`agentId` (`String?`/`int?`, conferir tipo — backend usa `Long`).
- `routecraft_app/lib/features/travels/data/dtos/travel_dto.dart`: incluir os dois campos em `toJson()`/`fromJson()`/`fromDomain()`.
- `routecraft_app/lib/core/services/auth_service.dart`: adicionar um método (ex. `getClientId()`) que decodifica o token já guardado e devolve `claims['userId']` — mesmo padrão de `isAuthenticated()`.
- `routecraft_app/lib/features/route_creation/presentation/controllers/route_creation_controller.dart` (`submitRoute()`, linha ~297-320): ler o `clientId` via `AuthService.instance.getClientId()` e setar `agentId` fixo em `1`.
  - `# ponytail: agentId fixo = 1, trocar por atribuição real de agente quando existir fila/pool de atribuição.`

### 2. `compass-api` — publicar notificação na criação

- `compass-api/src/main/java/com/compass/compass_system/travel/TravelController.java` (`createTravel`, linha 46): tornar `@Transactional` (igual aos outros upserts) e publicar `NotificationEvent` após o save, mesmo padrão de `upsertRoutePlan`:
  ```java
  eventPublisher.publishEvent(new NotificationEvent(
          NotificationRecipientType.AGENT,
          saved.getAgentId(),
          NotificationType.ROUTE_CREATED,
          saved.getId(),
          "O cliente criou uma rota para a viagem \"" + saved.getTravelName() + "\"."));
  ```
  (reaproveita o `NotificationType.ROUTE_CREATED` que já existe, usado hoje só dentro de `upsertRoutePlan` para o caso "primeira rota de uma travel já existente" — semanticamente é a mesma mensagem.)

### 3. Testar de ponta a ponta

- Criar roteiro no RouteCraft → confirmar `client_id` preenchido e `agent_id = 1` na tabela `travel`.
- Confirmar `insert into notification` nos logs do backend.
- Confirmar que a notificação aparece em `GET /notifications` autenticado como o usuário agente de id `1` (Travel Matrix).

---

## Estado do ambiente usado nesta investigação

Pré-release `compass_system-0.2.0-rc.1` rodando localmente via Runtime Package (`.release/runtime/`), containers:
`compass-runtime-backend-1`, `compass-runtime-db-1`, `compass-runtime-travel-matrix-1`, `compass-runtime-rabbitmq-1`, `compass-runtime-ntfy-1` — todos saudáveis no momento da investigação.
