@echo off
:: ============================================================
:: INSTALADOR DE CONTROL DE HOSTS - EJECUTAR UNA SOLA VEZ
:: Ejecutar como Administrador
:: ============================================================
:: Este script instala un servicio de Windows que actualiza
:: automaticamente el archivo hosts desde GitHub.
:: Solo necesita ejecutarse UNA VEZ con privilegios de admin.
:: ============================================================

title Instalador de Control de Hosts - Empresa

:: Verificar que se ejecuta como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  [ERROR] Este instalador debe ejecutarse como ADMINISTRADOR.
    echo.
    echo  Haz clic derecho en el archivo y selecciona:
    echo  "Ejecutar como administrador"
    echo.
    pause
    exit /b 1
)

echo.
echo  ============================================================
echo   INSTALADOR DE CONTROL DE HOSTS EMPRESARIAL
echo   Version 1.0
echo  ============================================================
echo.

:: ============================================================
:: PASO 1: PEDIR DEPARTAMENTO
:: ============================================================
echo  Selecciona el departamento de este equipo:
echo.
echo   [1] Ventas
echo   [2] Retention
echo   [3] Calidad
echo   [4] Administracion
echo.
set /p DEPTO_OPCION=" Ingresa el numero (1-4): "

if "%DEPTO_OPCION%"=="1" (
    set DEPARTAMENTO=ventas
    set DEPTO_NOMBRE=Ventas
)
if "%DEPTO_OPCION%"=="2" (
    set DEPARTAMENTO=retention
    set DEPTO_NOMBRE=Retention
)
if "%DEPTO_OPCION%"=="3" (
    set DEPARTAMENTO=calidad
    set DEPTO_NOMBRE=Calidad
)
if "%DEPTO_OPCION%"=="4" (
    set DEPARTAMENTO=administracion
    set DEPTO_NOMBRE=Administracion
)

if not defined DEPARTAMENTO (
    echo.
    echo  [ERROR] Opcion invalida. Ejecuta el instalador nuevamente.
    pause
    exit /b 1
)

echo.
echo  Departamento seleccionado: %DEPTO_NOMBRE%
echo.

:: ============================================================
:: PASO 2: PEDIR GITHUB USERNAME Y REPO
:: ============================================================
echo  ============================================================
echo   CONFIGURACION DE GITHUB
echo  ============================================================
echo.
echo  Ingresa tu usuario de GitHub (ej: miempresa):
set /p GITHUB_USER=" Usuario GitHub: "

echo.
echo  Ingresa el nombre del repositorio (ej: hosts-control):
set /p GITHUB_REPO=" Nombre del repositorio: "

echo.
echo  Cada cuantas horas deseas actualizar? (recomendado: 4):
set /p HORAS_UPDATE=" Horas entre actualizaciones: "

if "%HORAS_UPDATE%"=="" set HORAS_UPDATE=4

:: Calcular minutos para Task Scheduler
set /a MINUTOS_UPDATE=%HORAS_UPDATE%*60

:: URL RAW de GitHub
set GITHUB_URL=https://raw.githubusercontent.com/%GITHUB_USER%/%GITHUB_REPO%/main/hosts/hosts-%DEPARTAMENTO%.txt

echo.
echo  URL configurada: %GITHUB_URL%
echo.

:: ============================================================
:: PASO 3: CREAR DIRECTORIO DE TRABAJO
:: ============================================================
set INSTALL_DIR=C:\HostsControl
set SCRIPT_DIR=%INSTALL_DIR%\scripts
set LOG_DIR=%INSTALL_DIR%\logs
set BACKUP_DIR=%INSTALL_DIR%\backups

echo  Creando directorios de instalacion...
if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"
if not exist "%SCRIPT_DIR%" mkdir "%SCRIPT_DIR%"
if not exist "%LOG_DIR%" mkdir "%LOG_DIR%"
if not exist "%BACKUP_DIR%" mkdir "%BACKUP_DIR%"

:: ============================================================
:: PASO 4: GUARDAR CONFIGURACION
:: ============================================================
echo  Guardando configuracion...
(
    echo GITHUB_USER=%GITHUB_USER%
    echo GITHUB_REPO=%GITHUB_REPO%
    echo DEPARTAMENTO=%DEPARTAMENTO%
    echo DEPTO_NOMBRE=%DEPTO_NOMBRE%
    echo GITHUB_URL=%GITHUB_URL%
    echo HORAS_UPDATE=%HORAS_UPDATE%
    echo INSTALL_DIR=%INSTALL_DIR%
) > "%INSTALL_DIR%\config.ini"

:: ============================================================
:: PASO 5: CREAR EL SCRIPT PRINCIPAL DE ACTUALIZACION
:: ============================================================
echo  Creando script de actualizacion...

(
echo @echo off
echo :: Script de actualizacion automatica de Hosts
echo :: Generado por el instalador - NO MODIFICAR MANUALMENTE
echo.
echo set LOG_FILE=C:\HostsControl\logs\update.log
echo set HOSTS_FILE=C:\Windows\System32\drivers\etc\hosts
echo set TEMP_FILE=C:\HostsControl\hosts_temp.txt
echo set BACKUP_DIR=C:\HostsControl\backups
echo set GITHUB_URL=%GITHUB_URL%
echo.
echo :: Registrar inicio
echo echo [%%date%% %%time%%] Iniciando actualizacion de hosts... ^>^> "%%LOG_FILE%%"
echo.
echo :: Descargar nuevo hosts desde GitHub
echo powershell -Command "try { (New-Object System.Net.WebClient).DownloadFile('%%GITHUB_URL%%', '%%TEMP_FILE%%'); exit 0 } catch { exit 1 }"
echo.
echo if %%errorlevel%% neq 0 (
echo     echo [%%date%% %%time%%] ERROR: No se pudo descargar el archivo hosts desde GitHub. ^>^> "%%LOG_FILE%%"
echo     exit /b 1
echo )
echo.
echo :: Verificar que el archivo descargado no esta vacio
echo for %%%%F in ^("%%TEMP_FILE%%"^) do if %%%%~zF==0 ^(
echo     echo [%%date%% %%time%%] ERROR: El archivo descargado esta vacio. ^>^> "%%LOG_FILE%%"
echo     exit /b 1
echo ^)
echo.
echo :: Hacer backup del hosts actual
echo set BACKUP_NAME=hosts_backup_%%date:~-4,4%%%%date:~-7,2%%%%date:~-10,2%%_%%time:~0,2%%%%time:~3,2%%%%time:~6,2%%.txt
echo set BACKUP_NAME=%%BACKUP_NAME: =0%%
echo copy /y "%%HOSTS_FILE%%" "%%BACKUP_DIR%%\%%BACKUP_NAME%%" ^>nul 2^>^&1
echo.
echo :: REEMPLAZAR COMPLETAMENTE el archivo hosts
echo copy /y "%%TEMP_FILE%%" "%%HOSTS_FILE%%"
echo.
echo if %%errorlevel%% neq 0 (
echo     echo [%%date%% %%time%%] ERROR: No se pudo escribir el archivo hosts. ^>^> "%%LOG_FILE%%"
echo     exit /b 1
echo ^)
echo.
echo :: Limpiar archivo temporal
echo del /f /q "%%TEMP_FILE%%" ^>nul 2^>^&1
echo.
echo :: Limpiar cache DNS
echo ipconfig /flushdns ^>nul 2^>^&1
echo.
echo echo [%%date%% %%time%%] Hosts actualizado correctamente desde GitHub. ^>^> "%%LOG_FILE%%"
echo.
echo :: Mantener solo los ultimos 30 backups
echo for /f "skip=30 delims=" %%%%F in ^('dir /b /o-d "%%BACKUP_DIR%%\hosts_backup_*.txt" 2^>nul'^) do ^(
echo     del /f /q "%%BACKUP_DIR%%\%%%%F" ^>nul 2^>^&1
echo ^)
) > "%SCRIPT_DIR%\update-hosts.bat"

:: ============================================================
:: PASO 6: CREAR SCRIPT DE FORZAR UPDATE (para el admin)
:: ============================================================
(
echo @echo off
echo title Forzar Actualizacion de Hosts
echo echo.
echo echo  Forzando actualizacion del archivo hosts...
echo echo  Departamento: %DEPTO_NOMBRE%
echo echo.
echo call "C:\HostsControl\scripts\update-hosts.bat"
echo echo.
echo if %%errorlevel%%==0 (
echo     echo  [OK] Hosts actualizado exitosamente!
echo ) else (
echo     echo  [ERROR] No se pudo actualizar. Revisa C:\HostsControl\logs\update.log
echo )
echo echo.
echo pause
) > "%INSTALL_DIR%\FORZAR-UPDATE.bat"

:: ============================================================
:: PASO 7: CREAR TAREA PROGRAMADA - AL INICIO DEL SISTEMA
:: ============================================================
echo  Configurando tarea programada al inicio del sistema...

schtasks /delete /tn "HostsControl_Startup" /f >nul 2>&1
schtasks /create /tn "HostsControl_Startup" ^
    /tr "C:\HostsControl\scripts\update-hosts.bat" ^
    /sc ONSTART ^
    /delay 0001:00 ^
    /ru SYSTEM ^
    /rl HIGHEST ^
    /f >nul 2>&1

if %errorlevel% neq 0 (
    echo  [ADVERTENCIA] No se pudo crear tarea de inicio. Intentando metodo alternativo...
    schtasks /create /tn "HostsControl_Startup" /tr "C:\HostsControl\scripts\update-hosts.bat" /sc ONSTART /ru SYSTEM /f >nul 2>&1
)

:: ============================================================
:: PASO 8: CREAR TAREA PROGRAMADA - CADA X HORAS
:: ============================================================
echo  Configurando tarea programada cada %HORAS_UPDATE% horas...

schtasks /delete /tn "HostsControl_Periodic" /f >nul 2>&1
schtasks /create /tn "HostsControl_Periodic" ^
    /tr "C:\HostsControl\scripts\update-hosts.bat" ^
    /sc HOURLY ^
    /mo %HORAS_UPDATE% ^
    /ru SYSTEM ^
    /rl HIGHEST ^
    /f >nul 2>&1

if %errorlevel% neq 0 (
    echo  [ADVERTENCIA] Tarea periodica - intentando con minutos...
    schtasks /create /tn "HostsControl_Periodic" /tr "C:\HostsControl\scripts\update-hosts.bat" /sc HOURLY /mo %HORAS_UPDATE% /ru SYSTEM /f >nul 2>&1
)

:: ============================================================
:: PASO 9: APLICAR HOSTS INMEDIATAMENTE (primera actualizacion)
:: ============================================================
echo.
echo  Aplicando hosts por primera vez...
call "%SCRIPT_DIR%\update-hosts.bat"

if %errorlevel%==0 (
    echo  [OK] Hosts aplicado correctamente.
) else (
    echo  [ADVERTENCIA] No se pudo descargar desde GitHub.
    echo  Verifica que el repositorio existe y es publico.
    echo  El sistema intentara nuevamente al reiniciar.
)

:: ============================================================
:: PASO 10: PROTEGER LOS ARCHIVOS DE SISTEMA
:: ============================================================
echo  Configurando permisos de proteccion...

:: Quitar permisos de escritura al hosts para usuarios estandar
icacls "C:\Windows\System32\drivers\etc\hosts" /inheritance:r /grant:r SYSTEM:(F) /grant:r Administrators:(F) >nul 2>&1

:: Proteger directorio de instalacion
icacls "%INSTALL_DIR%" /inheritance:r /grant:r SYSTEM:(OI)(CI)(F) /grant:r Administrators:(OI)(CI)(F) >nul 2>&1

:: ============================================================
:: FINALIZACION
:: ============================================================
echo.
echo  ============================================================
echo   INSTALACION COMPLETADA EXITOSAMENTE
echo  ============================================================
echo.
echo   Equipo configurado para: %DEPTO_NOMBRE%
echo   Actualizacion automatica: cada %HORAS_UPDATE% horas
echo   Actualizacion al inicio: SI
echo   GitHub URL: %GITHUB_URL%
echo.
echo   Archivos instalados en: C:\HostsControl\
echo.
echo   Para forzar una actualizacion manual (sin reiniciar):
echo   Ejecuta como admin: C:\HostsControl\FORZAR-UPDATE.bat
echo.
echo   Logs disponibles en: C:\HostsControl\logs\update.log
echo  ============================================================
echo.
pause
