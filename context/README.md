# context/ — Contexto de engenharia do Compass System

Conhecimento técnico **atual e durável** cujo *porquê*, restrição ou relação não se
descobre barato lendo o código. Responde "como o sistema funciona e por quê?".

Governança de mutação: skill `engineering-context-manager`. Leitura é livre.
Continuidade operacional (handoff, tentativas) fica em [`../ai-memory/`](../ai-memory/README.md), não aqui.

## Topologia

Monorepo (`.release/project.yml`). Este `context/` e o `ai-memory/` vivem na raiz do repositório.

| Componente | Pasta | Stack |
|---|---|---|
| compass_api | `compass-api/` | Java 17, Spring Boot 3.2.4, PostgreSQL |
| routecraft_app | `routecraft_app/` | Flutter (mobile, cliente) |
| travel_matrix | `travel_matrix/` | Flutter (web + mobile, agente) |

## Estrutura

Criada **sob demanda** — nenhum arquivo/pasta existe sem conteúdo real.

```text
context/
├── README.md          este índice
├── architecture.md    arquitetura transversal e pontos não óbvios
├── constraints.md     invariantes, restrições transversais, armadilhas
├── modules/           módulos com custo relevante de redescoberta
├── integrations/      integrações não óbvias (comportamento, restrições)
└── decisions/         decisões técnicas duráveis (preserva o porquê)
```

Organize por conceito técnico estável — nunca por issue, sprint, agente ou data.
Histórico de mudança = Git.

## Formato da nota

```yaml
---
type: module            # module | integration | decision | constraints | architecture
scope: <conceito>
status: active          # active | review-needed
last-reviewed: AAAA-MM-DD
related-context: []
code-refs: []
---
```

## Índice

_Nenhuma nota ainda._ Adicione cada nota aqui ao criá-la.
