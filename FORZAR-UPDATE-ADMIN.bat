@echo off
:: ============================================================
:: FORZAR ACTUALIZACION DE HOSTS - USO ADMIN
:: Actualiza el hosts inmediatamente sin necesidad de reiniciar
:: ============================================================

title Forzar Actualizacion de Hosts

:: Verificar que se ejecuta como administrador
net session >nul 2>&1
if %errorLevel% neq 0 (
    echo.
    echo  [ERROR] Este script debe ejecutarse como ADMINISTRADOR.
    echo.
    pause
    exit /b 1
)

:: Verificar que el sistema esta instalado
if not exist "C:\HostsControl\scripts\update-hosts.bat" (
    echo.
    echo  [ERROR] El sistema de control de hosts no esta instalado.
    echo  Ejecuta primero el archivo INSTALAR-COMO-ADMIN.bat
    echo.
    pause
    exit /b 1
)

:: Leer configuracion
if exist "C:\HostsControl\config.ini" (
    for /f "tokens=1,2 delims==" %%a in (C:\HostsControl\config.ini) do (
        if "%%a"=="DEPTO_NOMBRE" set DEPTO_NOMBRE=%%b
        if "%%a"=="GITHUB_URL" set GITHUB_URL=%%b
    )
)

cls
echo.
echo  ============================================================
echo   FORZAR ACTUALIZACION DE HOSTS
echo  ============================================================
echo.
echo   Departamento : %DEPTO_NOMBRE%
echo   Fuente       : %GITHUB_URL%
echo.
echo  Descargando archivo hosts desde GitHub...
echo.

call "C:\HostsControl\scripts\update-hosts.bat"

echo.
if %errorlevel%==0 (
    echo  ============================================================
    echo   [OK] HOSTS ACTUALIZADO EXITOSAMENTE
    echo  ============================================================
    echo.
    echo   El archivo hosts ha sido reemplazado completamente.
    echo   La cache DNS ha sido limpiada.
    echo   Los cambios son efectivos de inmediato.
    echo.
) else (
    echo  ============================================================
    echo   [ERROR] NO SE PUDO ACTUALIZAR EL HOSTS
    echo  ============================================================
    echo.
    echo   Posibles causas:
    echo   - Sin conexion a internet
    echo   - El repositorio de GitHub no existe o es privado
    echo   - El archivo hosts no se encuentra en la ruta correcta
    echo.
    echo   Revisa el log: C:\HostsControl\logs\update.log
    echo.
)

echo  Presiona cualquier tecla para salir...
pause >nul
