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

## Integração Modo A (2026-10-15)
Escopo: Epic CPS-178 ∩ `Integração` = CPS-181, CPS-182, CPS-198, CPS-199. Mergeados nesta ordem em `epic/CPS-178-layout-responsivo` (topo `92ad3ec`):
- #189 CPS-181 → `d80449803fcab330700b46a3b9b5691dce253929`
- #190 CPS-182 → `38a9b7189b53f29b1436436121f9b87460999489`
- #191 CPS-198 → `2ad24b8aadde36d72999c74fc8ab3942dc629572`
- #192 CPS-199 → `92ad3ece210d26de58c8a3b97192902c377d6d2b`

R3 sem conflito em todas (`origin/epic` mergeado em cada branch, push normal); CI verde (compass-api, travel_matrix, routecraft_app) revalidada a cada reconciliação; sem subtarefas. Smoke no épico: analyze limpo, 285 testes do travel_matrix. `integrado-epico` aplicada nas 4; as issues seguem em `Integração`; branches das issues mantidas (Modo A).

Handoff: o QA web (1024–1320 px, 411 dp) e Android só vem depois da promoção do Epic para `develop` (Modo B), que exige a autorização do Gate 15. A issue do recolhimento do menu lateral é a CPS-200 (`requires-design`), hoje em `Preparação técnica - Claude`, fora deste lote e com PR ainda inexistente: o Modo B depende de decidir se ela entra no Epic antes da promoção ou se a promoção é parcial.
