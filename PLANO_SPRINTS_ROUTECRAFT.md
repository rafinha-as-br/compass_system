# Plano de Implementação — RouteCraft (5 Sprints)

> Documento gerado a partir da análise completa da documentação do Compass System no Confluence (espaço `CS`): Arquitetura da Solução, compass_modules (RouteCraft), Regras de Negócio, Convenções e Regras de Codificação, Casos de Uso, Critérios de Aceitação e Pendências, e Módulo - Pacotes de Viagem. Referências ao final.
>
> Corresponde à issue [CPS-10 — Entregas do RouteCraft](https://rafinha84dev.atlassian.net/browse/CPS-10) (subtask de CPS-2), cujo objetivo é "definir as entregas do RouteCraft por módulo, via documentação" e criar branches de sprint para a matéria de Projeto Integrador II.
>
> **v2:** reestruturado a pedido de Rafinha — cada sprint entrega um módulo funcional completo (não mais uma sprint de "fundação" separada). A fundação arquitetural (`Result<T>`, `HttpApiClient`, padrão `domain`/`data`/`UseCase`) entra dentro da Sprint 1, porque é pré-requisito inseparável do primeiro módulo migrado (`auth`) — as sprints seguintes só reaproveitam o que já foi construído ali.

---

## 1. Panorama Atual (onde o RouteCraft está hoje)

O `routecraft_app` é o app Flutter mobile do cliente, com 5 features: `auth`, `home`, `route_creation`, `visualization`, `account`. Diferente do `travel_matrix` (app do agente, já maduro), o RouteCraft tem **um único gap estrutural que explica quase todas as suas pendências**: nenhuma feature possui as camadas `domain`/`data` — os controllers chamam `CompassService` diretamente, que por sua vez delega para o `MockApiService` (pacote `mock_repository`), **nunca** para o `compass-api` real.

Isso foi confirmado de forma consistente em várias páginas:

| Fonte | Constatação |
| --- | --- |
| Arquitetura da Solução | "RouteCraft ainda usa uma API mockada... inclusive o login não chama `/api/auth/login` real" |
| Critérios de Aceitação e Pendências | "Pendência #1: RouteCraft não está integrado ao backend real" — maior gap arquitetural do projeto |
| Convenções e Regras de Codificação (§3.1, §4) | "RouteCraft não segue [a regra de camadas]... todas as features chamam `CompassService` direto do controller" |
| Casos de Uso | Casos de uso descritos são o comportamento **pretendido**, não o real |

Consequência prática: o fluxo fim-a-fim "cliente cria rota no RouteCraft → agente vê e monta itinerário no Travel Matrix" **não é validável hoje** — são dois mundos de dados desconectados (mock vs. Postgres real).

### Pendências específicas por módulo (já documentadas)

| Módulo | Pendência conhecida |
| --- | --- |
| `auth` | Login mockado; sem tela de cadastro; sem checagem de papel (`userType`); `GateAuth` só verifica presença de token, não validade |
| `route_creation` | `clientId`/`agentId` hardcoded (`'client_1'`/`'agent_1'`) com comentário `// Will be resolved from logged-in user`; grava local mesmo se o envio ao backend falhar |
| `visualization` | `clientId` hardcoded; fallback mock ("Mock Travel: New York to Tokyo") injetado quando a lista vem vazia — tela nunca mostra um empty state real |
| `home` (`FollowTravelPage`) | Busca por Travel ID é só UI — não dispara nenhuma consulta real |
| `account` | Feature menos desenvolvida — sem integração com `GET /users/me`, sem edição de dados, sem troca de senha |
| Transversal | Navegação via `Navigator` imperativo sem rotas nomeadas (sem deep-link); zero testes automatizados no frontend |

### Ordem das sprints (por módulo, seguindo o fluxo de uso do cliente)

```
Sprint 1: Autenticação completa (auth) — inclui a fundação arquitetural
Sprint 2: Criação de Rota (route_creation) real
Sprint 3: Visualização de Viagens (visualization) real
Sprint 4: Acompanhamento de Viagem (home / FollowTravelPage) real
Sprint 5: Conta (account) + Roteamento + Qualidade (hardening)
```

**Por que essa ordem:** segue o próprio fluxo do cliente documentado em [Fluxo do Cliente (RouteCraft)](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32407613) — login, depois criar uma viagem (a ação de maior valor do app), depois consultar o que já foi criado (lista, depois busca específica por ID), e por último a conta, que é acessível a qualquer momento e não bloqueia nenhuma outra funcionalidade. A fundação (`Result<T>`, `HttpApiClient`, padrão `domain`/`data`) entra na Sprint 1 porque não existe módulo `auth` real sem ela — nas sprints seguintes, essa infraestrutura já está pronta e é só reaproveitada.

---

## 2. Sprint 1 — Autenticação Completa (auth)

**Objetivo:** entregar o módulo `auth` inteiro e funcional contra o `compass-api` real — login, cadastro e validação de sessão — e, no processo, construir a fundação arquitetural (`Result<T>`, `HttpApiClient`, padrão `domain`/`data`/`UseCase`) que todas as sprints seguintes vão reaproveitar sem precisar recriar.

**Por que tudo junto:** login e cadastro são as duas metades do mesmo módulo e dependem exatamente da mesma infraestrutura de rede — separar em duas sprints obrigaria a tocar os mesmos arquivos duas vezes.

### Entregas

**Fundação (pré-requisito do módulo, construída aqui pela primeira vez):**

* `core/entities/result.dart` — tipo `Result<T>` (`Result.success(data)` / `Result.failure(error)`), espelhando o já usado no Travel Matrix. Nenhum use case novo (desta ou de sprints futuras) deve retornar `Map` cru.
* `core/network/http_api_client.dart` — adaptação do `HttpApiClient` do Travel Matrix para o RouteCraft (mesmo client HTTP, mesma base URL do `compass-api`, tratamento de erro padronizado). Esta classe passa a ser reutilizada por todas as features nas sprints seguintes.

**Login real:**

* `auth/domain/entities/auth_session.dart`
* `auth/domain/repositories/auth_repository.dart` — interface: `Future<Result<AuthSession>> login(String email, String password);`
* `auth/data/datasources/auth_remote_datasource.dart` — chama `POST /api/auth/login` real via `HttpApiClient`.
* `auth/data/repositories/auth_repository_impl.dart`
* `auth/domain/usecases/login_usecase.dart` — `Future<Result<AuthSession>> call(String email, String password)`
* Refatorar `LoginController.login()` para chamar `LoginUseCase` em vez de `CompassService.instance.login()` diretamente.
* `AuthService`: passar a extrair e persistir o claim `userType` do JWT retornado (hoje só guarda o token bruto).
* Remover a dependência de `MockApiService` do fluxo de login.

**Cadastro (tela inexistente hoje no RouteCraft):**

* `auth/presentation/pages/register_page.dart`
* `auth/presentation/controllers/register_controller.dart` — `RegisterState` (`isLoading`, `errorMessage`, `isSuccess`), método `register({name, email, password, cpf, age, gender, phone})`.
* `auth/domain/usecases/register_client_usecase.dart` — chama `POST /api/auth/cadastrar/cliente`.
* Extensão de `AuthRepository`/`AuthRemoteDataSource` com `registerClient(...)`.

**Sessão:**

* `GateAuth`: além de checar presença do token, decodificar o JWT localmente para validar expiração (`exp`) antes de considerar o usuário autenticado — hoje só verifica se existe algo salvo, "sem validar assinatura/expiração".
* **Decisão de arquitetura a confirmar antes de implementar:** o Travel Matrix bloqueia login de `CLIENTE`; o RouteCraft hoje aceita qualquer papel. Por simetria, `LoginUseCase`/`LoginController` poderia rejeitar `userType == 'AGENTE'` no app do cliente — mas isso **não está nos Critérios de Aceitação documentados**, é uma extensão proposta. Não implementar sem validar essa decisão primeiro.

**Testes:** `LoginUseCase`, `RegisterClientUseCase` e a decisão de papel (se aprovada) — primeiros testes automatizados do RouteCraft, endereçando a pendência "cobertura de testes é o maior gap de qualidade do projeto".

### Critérios de Aceitação da Sprint

* Login e cadastro funcionam contra o `compass-api` real (Postgres), não contra `mock_repository`.
* Cliente novo consegue se cadastrar pelo app e, em seguida, logar com as credenciais criadas — ciclo completo cadastro→login validado manualmente.
* Falha de login exibe a mensagem genérica já definida pela RN ("E-mail ou senha incorretos."), sem revelar qual campo está errado.
* Duplicidade de e-mail no cadastro retorna erro tratado na UI (nunca stack trace), conforme já garantido pelo backend (`BusinessException` + `GlobalExceptionHandler`).

---

## 3. Sprint 2 — Criação de Rota (route_creation)

**Objetivo:** migrar `route_creation` para o backend real e eliminar o hardcode de identidade, que é o débito técnico mais citado na documentação (`Convenções e Regras de Codificação §4` cita isso explicitamente como "não replicar").

### Entregas

* Estrutura `domain`/`data` da feature (reaproveitando `HttpApiClient`/`Result<T>` da Sprint 1):
  * `route_creation/domain/entities/route_plan.dart`
  * `route_creation/domain/repositories/route_repository.dart`
  * `route_creation/data/datasources/route_remote_datasource.dart` — `POST /travels` real.
  * `route_creation/domain/usecases/create_travel_usecase.dart` — `Future<Result<Travel>> call(RoutePlan plan)`.
* Refatorar `RouteCreationController.submitRoute()`:
  1. Resolver `clientId` a partir da sessão autenticada (`AuthSession` da Sprint 1), eliminando o literal `'client_1'`.
  2. Chamar `CreateTravelUseCase` em vez de `CompassService.instance.createTravel` direto.
  3. Manter `LocalDbService.saveRouteLocally` (persistência otimista já é um padrão correto do projeto), mas adicionar um status de sincronização (`synced` / `pendingSync`) para não mascarar silenciosamente uma falha de rede — hoje "a rota permanece salva localmente... criando uma potencial divergência" sem qualquer sinalização.
* **Decisão de negócio em aberto:** `agentId` não tem, hoje, nenhuma regra de atribuição documentada (o cliente cria a rota sem escolher ou receber um agente). Antes de resolver esse hardcode, é preciso decidir a estratégia: atribuição automática no backend, campo opcional, ou vínculo fixo por enquanto. **Registrar essa decisão na documentação (Confluence) antes de codar.**
* Testes unitários: `CreateTravelUseCase`.

### Critérios de Aceitação da Sprint

* Uma rota criada pelo RouteCraft aparece, via `GET /travels`, como uma `Travel` real no backend — pré-condição para o fluxo fim-a-fim "cliente cria rota → agente vê no Travel Matrix".
* `clientId` da viagem corresponde ao usuário de fato autenticado, nunca ao literal `'client_1'`.

---

## 4. Sprint 3 — Visualização de Viagens (visualization)

**Objetivo:** migrar a listagem de viagens do cliente para o backend real e eliminar o fallback mock que hoje mascara qualquer estado vazio genuíno.

### Entregas

* Estrutura `domain`/`data` da feature:
  * `visualization/domain/repositories/travel_repository.dart` (ou reaproveitamento do repositório de `route_creation` se fizer sentido consolidar em um único `TravelRepository` — avaliar ao implementar, para não duplicar o mesmo contrato de `Travel` em dois lugares).
  * `visualization/domain/usecases/get_travels_for_client_usecase.dart` — `GET /travels` (ou endpoint equivalente filtrado), usando o `clientId` real da sessão (não mais hardcoded).
* Remoção do fallback mock hardcoded ("Mock Travel: New York to Tokyo") do `VisualizationController` — se for necessário manter um estado de demonstração para a apresentação da matéria, isolar atrás de uma flag de ambiente explícita (`--dart-define=DEMO_MODE=true`), nunca no caminho padrão de produção.
* Refatorar `VisualizationController` para expor os 3 estados obrigatórios (loading, sucesso, erro) via `VisualizationState` imutável.
* Testes unitários: `GetTravelsForClientUseCase`.

### Critérios de Aceitação da Sprint

* Lista de viagens do `VisualizationPage` reflete exatamente o que está no backend para aquele cliente — inclusive o estado vazio genuíno (sem viagens) sendo exibido corretamente, sem fallback mock.
* `clientId` usado na consulta é sempre o do usuário autenticado.

---

## 5. Sprint 4 — Acompanhamento de Viagem (home / FollowTravelPage)

**Objetivo:** implementar de fato a busca de uma viagem específica por ID, hoje um placeholder de UI dentro do módulo `home`.

### Entregas

* `home/domain/usecases/get_travel_by_id_usecase.dart` — implementa a busca que `FollowTravelPage` hoje só simula com um `SnackBar` ("Following Travel ID: $travelId") sem nenhuma consulta real.
* Reaproveitar o `TravelRepository`/`HttpApiClient` já criados nas sprints 2–3 (não recriar uma nova camada de dados para o mesmo tipo `Travel`).
* Refatorar `FollowTravelPage` para consumir o use case, com os 3 estados obrigatórios do projeto: loading, sucesso, erro (`FollowTravelState` como objeto único, não flags soltas).
* Testes unitários: `GetTravelByIdUseCase`.

### Critérios de Aceitação da Sprint

* Buscar uma viagem por ID em `FollowTravelPage` retorna dados reais (nome, rota, status, contagem de viajantes) ou um erro tratado ("viagem não encontrada"), nunca apenas fecha a tela.
* `HomePage` continua funcionando como hub de navegação sem alterações de comportamento fora do fluxo de busca.

---

## 6. Sprint 5 — Conta, Roteamento e Qualidade (account + hardening)

**Objetivo:** fechar a feature mais incompleta (`account`), eliminar o último débito estrutural transversal (navegação sem rotas nomeadas) e consolidar qualidade antes de qualquer entrega/avaliação da matéria.

### Entregas

* `account/domain/usecases/get_client_profile_usecase.dart` — integra `GET /users/me` (hoje `AccountPage` não busca nenhum dado real).
* `account/domain/usecases/logout_usecase.dart` — `AuthService.instance.clearToken()` + navegação para `GateAuth`, encerrando a sessão de forma explícita.
* Migração de navegação: `Navigator` imperativo → `go_router` com rotas nomeadas (`AppRoutes`), no mesmo padrão já usado pelo Travel Matrix — resolve a pendência "sem deep-linking nem estado de navegação restaurável".
* Auditoria final de arquitetura: garantir que nenhuma feature migrada (sprints 1–4) chama `CompassService`/HTTP fora de um `UseCase`/`Repository`.
* `analysis_options.yaml`: zerar warnings de lint no `routecraft_app`.
* Testes unitários cobrindo todos os use cases criados nas sprints 1–5 (meta mínima: 1 teste por use case).

### Critérios de Aceitação da Sprint

* `AccountPage` exibe dados reais do cliente autenticado.
* Fechar e reabrir o app em uma rota profunda (ex.: `/visualization`) não perde o contexto de navegação (uma vez migrado para `go_router`).
* `flutter analyze` roda sem warnings; suíte de testes roda sem falhas.

---

## 7. Riscos Transversais (válidos para todas as sprints)

| Risco | Mitigação |
| --- | --- |
| Trocar mock por API real expõe inconsistências de contrato (campos, formatos de data) já mascaradas pelo mock | Validar cada endpoint manualmente (Postman/Insomnia) antes de integrar no Flutter, sprint a sprint |
| Autorização por papel não é garantida no backend, só no frontend (RN de Autenticação) | Não assumir que o app é a única barreira de segurança — deixar explícito na documentação de qualquer decisão de bloqueio de papel no RouteCraft |
| Falta de migrations versionadas (`ddl-auto=update`) pode gerar inconsistência de schema ao evoluir entidades ligadas a `ClientUser` | Fora do escopo deste plano (é pendência do backend), mas deve ser comunicada — qualquer alteração de schema motivada por este plano deve ser testada em ambiente isolado antes |
| `Travel` acaba sendo consultada por três features diferentes (route_creation, visualization, home) | Consolidar um único `TravelRepository`/conjunto de DTOs reaproveitado entre as sprints 2, 3 e 4, em vez de recriar o mesmo contrato três vezes |
| Escopo "Pacotes de Viagem" (Vitrine de Pacotes no RouteCraft) já está desenhado no Confluence, mas depende de um módulo de backend ainda não implementado (`travelpackage`) | Não incluído neste plano de 5 sprints — é backlog subsequente, condicionado à conclusão do backend de pacotes pelo Travel Matrix |

---

## 8. Referências (Confluence, espaço CS)

* [Arquitetura da Solução](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32342027)
* [compass_modules - RouteCraft (Cliente)](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32440341)
* [Módulo - Autenticação (RouteCraft)](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32342048)
* [Módulo - Home (RouteCraft)](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32342068)
* [Módulo - Criação de Rota (RouteCraft)](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32211060)
* [Módulo - Visualização e Acompanhamento (RouteCraft)](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32276555)
* [Módulo - Conta (RouteCraft)](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32047202)
* [Fluxo do Cliente (RouteCraft)](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32407613)
* [Casos de Uso](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32407573)
* [Regras de Negócio](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32210957) e [Regra de Negócio - Autenticação e Perfis de Usuário](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32211019)
* [Convenções e Regras de Codificação](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32342137)
* [Critérios de Aceitação e Pendências](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/32407593)
* [Módulo - Pacotes de Viagem (Travel Packages)](https://rafinha84dev.atlassian.net/wiki/spaces/CS/pages/9469954) (contexto de backlog futuro, fora deste plano)
* [CPS-10 — Entregas do RouteCraft](https://rafinha84dev.atlassian.net/browse/CPS-10) (Jira)
