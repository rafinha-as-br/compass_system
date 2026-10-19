# ai-memory/ — Memória operacional dos agentes

Continuidade entre sessões: descobertas, dependências, tentativas, handoff. **Não** é
fonte de verdade do produto (Jira, Git, Confluence e `../context/` são).

Governança de mutação: skill `ai-memory-manager`.

```text
ai-memory/
├── active/
│   ├── <EPIC-KEY>/        epic.md + <ISSUE-KEY>.md das issues do Epic
│   └── isolated/          <ISSUE-KEY>.md de issues sem Epic (inclui Hotfix isolada)
└── history/               mesma forma; concluído ou cancelado — nunca apagar
```

- Arquivos nascem sob demanda; nome = chave Jira exata (`CPS-123.md`).
- Seções: Contexto · Descobertas · Dependências e impactos · Decisões e direcionamentos · Handoff.
- Sem log bruto, comandos, código versionado, secrets ou duplicação do Jira.
- Conhecimento técnico durável vai para `../context/`.
