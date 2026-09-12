@echo off
setlocal
cd /d "%~dp0"

if exist images.tar (
  if not exist .images-loaded (
    echo [1/3] Carregando imagens Docker ^(so na primeira vez, pode levar 1-2 min^)...
    docker load -i images.tar || goto erro
    echo ok > .images-loaded
  )
)

echo [2/3] Subindo Compass System...
docker compose up -d || goto erro

echo [3/3] Aguardando a API responder...
set /a TRIES=0
:wait
set /a TRIES+=1
if %TRIES% GTR 60 goto timeout
timeout /t 3 /nobreak >nul
curl -s -o nul http://localhost:8081/teste
if errorlevel 1 goto wait

echo.
echo   RouteCraft    http://localhost:8080
echo   Travel Matrix http://localhost:8082
echo   API           http://localhost:8081
echo.
start http://localhost:8080
echo Para parar tudo depois: PARAR.bat
pause
exit /b 0

:timeout
echo.
echo A API nao respondeu em 3 minutos. Veja o log com:  docker compose logs backend
pause
exit /b 1

:erro
echo.
echo Falhou. O Docker Desktop esta aberto?
pause
exit /b 1
