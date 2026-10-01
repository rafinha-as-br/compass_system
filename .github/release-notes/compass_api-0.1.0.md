## Novidades

A viagem agora gera notificações automaticamente — itinerário publicado ou alterado, rota criada ou editada — com endpoints para listar, contar as não lidas e marcar como lida.

Essas notificações também chegam como push de verdade: no RouteCraft via UnifiedPush/ntfy, e no navegador via Web Push, sempre por uma fila assíncrona que não bloqueia a ação que originou o aviso.

Os campos de lugar (endereço, cidade, ponto de interesse) agora têm um endpoint de autocomplete por trás, com cache e limite de taxa para não sobrecarregar o provedor de mapas.

Rotas e as etapas de um itinerário — hospedagem, voo, ônibus, carro alugado — passam a guardar coordenadas geográficas, aplicadas automaticamente, sem exigir nenhuma migração manual de banco.

## Correções

Corrigida uma falha que impedia a aplicação de uma atualização de banco em instalações que já tinham viagens cadastradas, ao definir o status inicial de um itinerário recém-criado.

---
Issues: CPS-145, CPS-146, CPS-152, CPS-153, CPS-166
