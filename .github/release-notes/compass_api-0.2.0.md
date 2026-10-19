## Novidades

O sistema agora trabalha por empresa. Cada agente pertence a uma empresa, com papel de dono ou membro: o dono convida novos agentes, promove, rebaixa e remove. Remover um agente desativa a conta dele em vez de apagá-la, e o e-mail continua reservado.

Viagens, clientes e o painel passam a ser isolados por empresa: quem pertence a outra empresa não enxerga nem acessa esses dados (a resposta é "não encontrado").

Agentes convidados precisam trocar a senha no primeiro acesso. Enquanto a troca não é feita, só é possível trocar a senha ou consultar o próprio perfil. A nova senha precisa ter ao menos 8 caracteres e ser diferente da atual.

A viagem gera notificações automaticamente — itinerário publicado ou alterado, rota criada ou editada — com listagem, contagem de não lidas e marcação como lida. Elas também chegam como push: no RouteCraft via UnifiedPush/ntfy e no navegador via Web Push, por uma fila assíncrona que não atrasa a ação que originou o aviso.

Os campos de lugar (endereço, cidade, ponto de interesse) têm um autocomplete por trás, com cache e limite de taxa. As sugestões agora trazem só o nome curto do lugar. Rotas e etapas do itinerário — hospedagem, voo, ônibus, carro alugado — passam a guardar coordenadas geográficas, aplicadas automaticamente, sem migração manual.

## Correções

Pedir uma rota que não existe agora responde "não encontrado" em vez de erro interno.

Corrigida uma falha que impedia atualizar o banco de instalações que já tinham viagens, ao definir o status inicial de um itinerário novo.

Criar um roteiro novo agora também notifica o agente responsável.

## Mudanças que exigem atenção

- O cadastro de cliente pelo próprio cliente foi removido; clientes passam a ser criados dentro da empresa.
- O cadastro do primeiro agente passa a exigir a chave de bootstrap configurada no ambiente. Sem ela, a resposta é acesso negado.
- Agentes que já existiam precisam estar vinculados a uma empresa; e agentes convidados trocam a senha no primeiro login.

---
Issues: CPS-145, CPS-146, CPS-152, CPS-153, CPS-162, CPS-166, CPS-168, CPS-195, CPS-196, CPS-201
