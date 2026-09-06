# CPS-96 — Execution State

Estado: EM_EXECUÇÃO
Branch: feat/CPS-96-claude (nova, a partir de develop)

Objetivo: padronizar skeleton de carregamento (sem spinner) e estado de
erro de rede com "tentar de novo" — escopo reduzido para a Home (única
tela com fetch de rede de verdade; hub/timeline só recebem Travel já
carregado via navegação, decidido com Rafinha).

Decisão de escopo confirmada com Rafinha (2026-09-06): implementar só na
Home. Hub/timeline ficam de fora por não terem fetch próprio.

Progresso:
- HomeState ganhou `isError`; HomeController.retry() adicionado.
- HomeController: falha de repositório/exceção agora vira isError:true em
  vez de degradar silenciosamente para "lista vazia" (bug real corrigido).
- HomePage: _HomeSkeleton (SkeletonBlock) e _HomeError (EmptyStateView +
  retry) substituem o CircularProgressIndicator.
- l10n: networkErrorTitle/Message/RetryCta (en/pt).
- Testes: home_controller_test.dart e home_page_test.dart atualizados/
  ampliados. flutter analyze e flutter test (não-golden) passando.
- Goldens novos (home_skeleton, home_error) adicionados a
  screens_golden_test.dart, gerados localmente no Windows.

Próxima ação: regenerar os 4 PNGs novos no runner Linux do CI (mesmo
mecanismo de job temporário usado em CPS-87/88/89/90/91/94/95) antes de
finalizar — os goldens gerados localmente no Windows não batem com o
runner Linux do CI.
