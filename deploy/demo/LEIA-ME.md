# Compass System — pacote de demonstração

Tudo roda offline. Único pré-requisito: **Docker Desktop aberto**.

## Como rodar

1. Abra o Docker Desktop e espere ficar verde.
2. Duplo-clique em **`INICIAR.bat`**.
   Na primeira vez ele carrega as imagens (1-2 min). Depois é rápido.
3. O navegador abre sozinho no RouteCraft.

| O quê | Onde |
| --- | --- |
| RouteCraft (criação de roteiros) | http://localhost:8080 |
| Travel Matrix | http://localhost:8082 |
| API | http://localhost:8081 |

## Que versoes estao aqui dentro

Veja o `VERSOES.txt`. Cada componente tem versao propria e sobe no seu
proprio ritmo, entao um pacote pode ter, por exemplo, o routecraft_app
0.2.0 junto do compass-api 0.0.1.

## Dados de exemplo

O banco começa vazio. Para popular com 5 clientes e 20 roteiros
(4 estados do ciclo de vida por cliente), rode **`POPULAR-DADOS.bat`**
com a aplicação já de pé. Precisa de Python instalado.

Login de exemplo depois do seed: `ana.souza@teste.com` / `senha123`

Se preferir mostrar o cadastro ao vivo, é só não rodar o seed.

## Parar

**`PARAR.bat`**. Os dados do banco ficam salvos num volume do Docker —
o próximo `INICIAR.bat` traz tudo de volta.

Para zerar o banco de verdade: `docker compose down -v`

## Se algo der errado

| Sintoma | O que fazer |
| --- | --- |
| "Falhou. O Docker Desktop está aberto?" | Abra o Docker Desktop, espere ficar verde, rode de novo. |
| API não responde em 3 min | `docker compose logs backend` |
| Porta 8080/8081/8082 em uso | Feche o que estiver usando, ou edite as portas no `docker-compose.yml`. |
| Tela branca no navegador | Ctrl+Shift+R (o service worker do Flutter às vezes cacheia build antigo). |
