@echo off
title Hold Maintenance - Launcher
echo ============================================
echo   Hold Maintenance - Starting All Services
echo ============================================
echo.

echo [1/2] Starting Backend (ASP.NET Core)...
start "Backend - ASP.NET Core" cmd /k "cd /d %~dp0backend && dotnet run"

echo [2/2] Waiting 5 seconds for backend to start...
timeout /t 5 /nobreak >nul

echo [2/2] Starting Flutter App...
start "Flutter App" cmd /k "cd /d %~dp0 && flutter run"

echo.
echo ============================================
echo   Both services are starting!
echo   - Backend:  http://localhost:5056
echo   - Flutter:  Check the Flutter terminal
echo ============================================
echo.
echo You can close this window.
pause
