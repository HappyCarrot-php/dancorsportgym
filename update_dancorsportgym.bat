@echo off
title Actualizador Automático - DancorSportGym (Flutter)
color 0B

echo ================================================
echo        ACTUALIZADOR AUTOMATICO - DANCOR SPORT GYM
echo ================================================
echo.

REM Ruta local del proyecto
set PROJECT_PATH=C:\Users\ricky\Documents\Programacion\Flutter\dancorsportgym

REM Repositorio remoto
set REMOTE_REPO=https://github.com/HappyCarrot-php/dancorsportgym.git

cd /d "%PROJECT_PATH%"
if %errorlevel% neq 0 (
    echo [ERROR] No se pudo acceder a la carpeta del proyecto.
    pause
    exit /b
)

echo.
echo [1/4] Verificando cambios locales...
git status

echo.
echo [2/4] Agregando archivos modificados...
git add .

echo.
set /p COMMIT_MSG=Escribe el mensaje del commit (por defecto: "Actualizacion automatica"): 
if "%COMMIT_MSG%"=="" set COMMIT_MSG=Actualizacion automatica

git commit -m "%COMMIT_MSG%"
if %errorlevel% neq 0 (
    echo [!] No hay cambios nuevos para subir.
    goto push_changes
)

:push_changes
echo.
echo [3/4] Subiendo cambios al repositorio remoto...
git push origin master

if %errorlevel% neq 0 (
    echo [ERROR] No se pudo hacer push. Revisa tu conexion o token de GitHub.
    pause
    exit /b
)

echo.
echo [4/4] Proyecto DancorSportGym actualizado correctamente.
echo.
echo ================================================
echo     TODOS LOS CAMBIOS FUERON SINCRONIZADOS
echo ================================================
pause
exit
