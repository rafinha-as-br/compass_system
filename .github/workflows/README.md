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

## Quality gates

Todas as etapas acima são obrigatórias (**BLOCK** em caso de falha) — falha em qualquer uma delas reprova o check do job e, com branch protection ativa (ver abaixo), bloqueia o merge do PR.

## Módulo fora da pipeline: `routecraft_app`

`routecraft_app` **não está incluído** nesta pipeline. O `pubspec.yaml` declara uma dependência de path local:

```yaml
mock_repository:
  path: ../fake_api
```

`fake_api` está no `.gitignore` e não existe no repositório — um clone limpo (incluindo o runner do CI) não consegue nem rodar `flutter pub get` neste módulo. Antes de incluir `routecraft_app` na pipeline, é preciso resolver essa dependência (versionar `fake_api`, publicá-lo como pacote, ou substituir por um mock real).

## Secrets

Nenhum secret é utilizado por esta pipeline atualmente.

## Cache

- Dependências Maven (`actions/setup-java`, chave por `pom.xml`)
- SDK e dependências Flutter (`subosito/flutter-action`, `cache: true`)

## Artefatos

Nenhum artefato é preservado atualmente (nem APK, nem build web). A avaliar se `flutter build web` do `travel_matrix` deve virar artefato quando houver deploy automatizado.

## Branch protection

`develop` exige que os seguintes checks passem antes do merge:

- `compass-api`
- `travel_matrix`

## Comportamento esperado em falhas

Qualquer falha em teste, análise estática ou build faz o job correspondente falhar. Com branch protection ativa, isso bloqueia o merge do PR até a correção.
