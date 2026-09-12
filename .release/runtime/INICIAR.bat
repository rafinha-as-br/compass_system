@echo off
setlocal
cd /d "%~dp0"

if not exist web\travel_matrix (
  echo [1/3] Extraindo o build web do travel_matrix...
  powershell -NoProfile -Command "Expand-Archive -Path '..\artifacts\travel_matrix\travel_matrix-web.zip' -DestinationPath 'web\travel_matrix' -Force" || goto erro
)

echo [2/3] Subindo Compass System ^(builda a imagem da API na primeira vez^)...
docker compose up -d --build || goto erro

echo [3/3] Aguardando a API responder...
set /a TRIES=0
:wait
set /a TRIES+=1
if %TRIES% GTR 60 goto timeout
timeout /t 3 /nobreak >nul
curl -s -o nul http://localhost:8081/teste
if errorlevel 1 goto wait

echo.
echo   Travel Matrix   http://localhost:8082
echo   API             http://localhost:8081
echo.
start http://localhost:8082
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
