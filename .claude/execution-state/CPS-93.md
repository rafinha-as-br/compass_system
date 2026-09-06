# CPS-93 — Execution State

Estado: EM_EXECUÇÃO
Branch: feat/CPS-93-claude (nova, a partir de develop)

Objetivo: modo de acompanhamento "Hoje" para viagem em andamento (RouteCraft),
com etapa em foco + "depois disso" calculados localmente por data, caindo
para o hub (CPS-90) fora do período da viagem.

Decisão de escopo confirmada com Rafinha (2026-09-06):
- Atalho "Endereço" no card da etapa em foco: só exibição do texto, sem
  ação de abrir mapa (sem depender de url_launcher, dependência nova).

Nota (não é bloqueio, apenas observação): CTA "Ver etapa" usa o stub
"Coming soon." (mesmo padrão que a timeline usava antes de CPS-92) porque
CPS-92 (bottom sheet de detalhe) ainda não está mergeada em develop nesta
sessão — CPS-93 não lista CPS-92 como dependência formal.

Próxima ação: implementação concluída (ItineraryTodayPage + wiring no
router + testes) — próximo passo é code review automatizado (5.3c) e gate
de qualidade (5.4).
