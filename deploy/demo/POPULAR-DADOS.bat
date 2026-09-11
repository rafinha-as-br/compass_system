@echo off
cd /d "%~dp0"
echo Populando a API com 5 clientes e 20 roteiros de exemplo...
echo (a API precisa estar de pe - rode o INICIAR.bat antes)
echo.
python seed\seed_test_data.py
echo.
echo Login de exemplo:  ana.souza@teste.com  /  senha123
pause
