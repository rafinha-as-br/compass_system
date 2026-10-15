# CPS-178 — Travel Matrix: layout responsivo

## Contexto
CPS-181 (orquestrador) e CPS-182 (escala desktop) foram promovidas para `develop` (PR #188) e reprovadas no QA de 2026-10-15; ambas voltaram a `Fazer - Claude`. Detalhes em `CPS-181.md` e `CPS-182.md`.

## Dependências e impactos
- A branch do Epic foi recriada pela Preparação técnica a partir de `develop` (`7c30a43`); os PRs do retrabalho apontam para ela e nenhum foi mergeado.
- O shell de navegação (rail/top bar) entrou na CPS-181 por decisão de Rafinha; o recolhimento do menu lateral é issue própria do Epic, com `requires-design`, ainda não criada (`jira-issue-creator`).

## Retrabalho (Fazer - Claude, 2026-10-15)
Escopo: CPS-181, CPS-182, CPS-198, CPS-199. Todas movidas para `Análise - Rafinha`, cada uma com PR contra a branch do Epic:
- CPS-181 tentativa 2 — PR #189 (shell responsivo). Ver `CPS-181.md`.
- CPS-182 tentativa 2 — PR #190 (texto cortado com escala ×1,15). Ver `CPS-182.md`.
- CPS-198 — PR #191 (landing/login). Ver `CPS-198.md`.
- CPS-199 — PR #192 (KPIs do dashboard). Ver `CPS-199.md`.

Handoff: revisão de Rafinha → Integração (Modo A) → QA web (1024–1320 px, 411 dp) e Android. Pendente: criar a issue do recolhimento do menu lateral.
