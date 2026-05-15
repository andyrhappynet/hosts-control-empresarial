@echo off
:: ============================================================
:: DESINSTALADOR DEL SISTEMA DE CONTROL DE HOSTS
:: Ejecutar como Administrador
:: ============================================================

title Desinstalador de Control de Hosts

net session >nul 2>&1
if %errorLevel% neq 0 (
    echo [ERROR] Ejecutar como Administrador.
    pause
    exit /b 1
)

echo.
echo  ============================================================
echo   DESINSTALADOR DE CONTROL DE HOSTS
echo  ============================================================
echo.
echo  [ATENCION] Esto eliminara todas las tareas programadas
echo  y restaurara el archivo hosts original de Windows.
echo.
set /p CONFIRMAR=" Escribir SI para confirmar: "

if /i not "%CONFIRMAR%"=="SI" (
    echo Desinstalacion cancelada.
    pause
    exit /b 0
)

echo.
echo  Eliminando tareas programadas...
schtasks /delete /tn "HostsControl_Startup" /f >nul 2>&1
schtasks /delete /tn "HostsControl_Periodic" /f >nul 2>&1
echo  [OK] Tareas eliminadas.

echo  Restaurando hosts original de Windows...
(
    echo # Copyright (c) 1993-2009 Microsoft Corp.
    echo #
    echo # This is a sample HOSTS file used by Microsoft TCP/IP for Windows.
    echo #
    echo 127.0.0.1       localhost
    echo ::1             localhost
) > "C:\Windows\System32\drivers\etc\hosts"
echo  [OK] Hosts restaurado.

echo  Eliminando directorio de instalacion...
icacls "C:\HostsControl" /grant Administrators:(OI)(CI)(F) >nul 2>&1
rmdir /s /q "C:\HostsControl" >nul 2>&1
echo  [OK] Directorio eliminado.

ipconfig /flushdns >nul 2>&1

echo.
echo  ============================================================
echo   DESINSTALACION COMPLETADA
echo  ============================================================
echo.
pause
