# Compass System

Monorepo (`.release/project.yml`): `compass-api/` (Java 17 / Spring Boot), `routecraft_app/` e `travel_matrix/` (Flutter). Visão geral em `README.md`.

## Antes de implementar

- `context/README.md` — índice do conhecimento técnico durável (arquitetura, restrições, decisões). Leitura direta; mutação via skill `engineering-context-manager`.
- `ai-memory/` — handoff e continuidade operacional por issue/Epic (`active/`, `history/`). Mutação via skill `ai-memory-manager`.
- `context/` e `ai-memory/` não substituem Jira, Git, Confluence nem o código: confirme o ponto crítico na fonte autoritativa.

## Workflow

Workflow Rafinha-Claude: skill `workflow-development-flow` (contratos, gates, modelo de branches). Release: `.release/` e skill `jira-release-executor`.
