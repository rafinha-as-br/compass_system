# Compass System — Runtime Package

Sobe `compass_api` (backend) + `travel_matrix` (web) localmente, a partir dos
artefatos já publicados desta distribuição. Único pré-requisito: **Docker
Desktop aberto** (e internet na primeira execução, para baixar as imagens base
e o build da API).

`routecraft_app` não faz parte deste pacote — é só mobile (APK), instala-se
direto no aparelho a partir da Release do componente.

## Como rodar

1. Abra o Docker Desktop e espere ficar verde.
2. Duplo-clique em **`INICIAR.bat`**.
   Na primeira vez ele builda a imagem da API e baixa a do Postgres/Nginx
   (alguns minutos). Depois é rápido.
3. O navegador abre sozinho no Travel Matrix.

| O quê | Onde |
| --- | --- |
| Travel Matrix | http://localhost:8082 |
| API | http://localhost:8081 |

## De onde vem cada parte

- **API**: a imagem é buildada localmente (`docker compose up --build`) a
  partir do jar já publicado em `artifacts/compass_api/` — não builda do
  código-fonte, que não existe dentro desta distribuição.
- **Travel Matrix**: o `INICIAR.bat` extrai `artifacts/travel_matrix/travel_matrix-web.zip`
  para `web/travel_matrix/` na primeira execução, e o Nginx serve esse
  diretório.
- **Banco**: Postgres 15 limpo, populado pela própria aplicação (não há seed
  de dados de exemplo neste pacote).

## Parar

**`PARAR.bat`**. Os dados do banco ficam salvos num volume do Docker — o
próximo `INICIAR.bat` traz tudo de volta.

Para zerar o banco de verdade: `docker compose down -v`

## Se algo der errado

| Sintoma | O que fazer |
| --- | --- |
| "Falhou. O Docker Desktop está aberto?" | Abra o Docker Desktop, espere ficar verde, rode de novo. |
| API não responde em 3 min | `docker compose logs backend` |
| Porta 8081/8082 em uso | Feche o que estiver usando, ou edite as portas no `docker-compose.yml`. |
| Tela branca no navegador | Ctrl+Shift+R (o service worker do Flutter às vezes cacheia build antigo). |
