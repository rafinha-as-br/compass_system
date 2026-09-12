@echo off
cd /d "%~dp0"
docker compose down
echo Parado. Os dados do banco continuam salvos - INICIAR.bat traz tudo de volta.
pause
