# Pipeline CI — Compass System

Documentação da pipeline conforme o padrão *GitHub Actions Pipeline Standard — Workflow Rafinha-Claude*.

## Objetivo

Validar tecnicamente, em ambiente independente, as alterações enviadas via Pull Request antes da integração em `develop`. A pipeline pertence à etapa **Integração** do Workflow Rafinha-Claude — ela não substitui code review, QA ou validação funcional.

## Triggers

- `pull_request` com destino `develop` ou `main`
- `push` em `develop` (segunda verificação após merge)

## Jobs

### `backend` (compass-api)

| Etapa | Comando |
| --- | --- |
| Testes automatizados | `./mvnw -B test` (usa H2 em memória, ver `src/test/resources/application-test.properties` — não depende de Postgres) |
| Build | `./mvnw -B package -DskipTests` |

Sem análise estática configurada neste módulo (nenhum plugin Checkstyle/Spotbugs no `pom.xml`) — gate não aplicável até que uma ferramenta seja adotada.

### `travel-matrix` (travel_matrix)

| Etapa | Comando |
| --- | --- |
| Instalar dependências | `flutter pub get` |
| Análise estática | `flutter analyze` |
| Testes automatizados | `flutter test` |
| Build | `flutter build web` |

Versão do Flutter pinada em `3.35.5` (stable) para reprodutibilidade.

### `routecraft` (routecraft_app)

| Etapa | Comando |
| --- | --- |
| Instalar dependências | `flutter pub get` |
| Análise estática | `flutter analyze` |
| Testes automatizados | `flutter test` |
| Build | `flutter build web` |

Mesmo padrão do job `travel-matrix` (Flutter `3.35.5` stable). Inclui testes golden (`test/golden/screens_golden_test.dart`) — rodam no runner `ubuntu-latest`, diferente do Windows usado localmente; se surgir mismatch de golden por rasterização de fonte entre SOs, regenerar os goldens a partir do runner Linux (ou de um container equivalente) em vez de aceitar o golden gerado localmente.

## Quality gates

Todas as etapas acima são obrigatórias (**BLOCK** em caso de falha) — falha em qualquer uma delas reprova o check do job e, com branch protection ativa (ver abaixo), bloqueia o merge do PR.

## Secrets

Nenhum secret é utilizado por esta pipeline atualmente.

## Cache

- Dependências Maven (`actions/setup-java`, chave por `pom.xml`)
- SDK e dependências Flutter (`subosito/flutter-action`, `cache: true`, um cache por job)

## Artefatos

Nenhum artefato é preservado atualmente (nem APK, nem build web). A avaliar se os `flutter build web` de `travel_matrix`/`routecraft_app` devem virar artefato quando houver deploy automatizado.

## Branch protection

`develop` exige que os seguintes checks passem antes do merge:

- `compass-api`
- `travel_matrix`
- `routecraft_app`

(Requer atualização manual da branch protection rule no GitHub para incluir o novo check `routecraft_app` — a pipeline em si já valida o job independente disso.)

## Comportamento esperado em falhas

Qualquer falha em teste, análise estática ou build faz o job correspondente falhar. Com branch protection ativa, isso bloqueia o merge do PR até a correção.
