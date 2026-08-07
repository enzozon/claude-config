@echo off
REM Clique duas vezes depois de clonar este repositorio no PC novo.
REM O -ExecutionPolicy Bypass vale so para este processo: num Windows recem
REM instalado a politica vem Restricted e bloquearia o .ps1 direto.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0restaurar.ps1"
echo.
pause
