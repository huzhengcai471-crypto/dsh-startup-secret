@echo off
rem ---------------------------------------------------------------
rem NOTE: do NOT add a chcp line to this file.
rem This file is saved as UTF-8. cmd.exe seeks the next line by BYTE
rem offset, so the encoding must stay stable.
rem ---------------------------------------------------------------
setlocal enabledelayedexpansion
cd /d "%~dp0"

echo ============================================
echo   dsh-startup-secret 安装脚本
echo ============================================
echo.

rem 1. 定位本目录下的 tgz 包
set "TGZ="
for %%f in (dsh-startup-secret-*.tgz) do set "TGZ=%%f"
if "%TGZ%"=="" (
  echo [错误] 当前目录没有找到 dsh-startup-secret-*.tgz 安装包。
  echo        请把 tgz 和本脚本放在同一目录后重试。
  pause
  exit /b 1
)
echo 找到安装包: %TGZ%
echo.

rem 2. 定位 dsh 命令
set "DSH=dsh"
where dsh >nul 2>nul
if errorlevel 1 (
  set "CAND=%LOCALAPPDATA%\Programs\WorkBuddy\resources\cli\bin\dsh.cmd"
  if exist "!CAND!" (
    set "DSH=!CAND!"
  ) else (
    echo [错误] 找不到 dsh 命令。请先安装 DSH，或把 dsh 加入 PATH。
    pause
    exit /b 1
  )
)
echo 使用 dsh: %DSH%
echo.

rem 3. 选择 profile
set "PROFILE=web"
set /p "P=安装到哪个 profile？[web/desktop]（直接回车 = web）: "
if not "%P%"=="" set "PROFILE=%P%"
echo 目标 profile: %PROFILE%
echo.

rem 4. 安装
echo 正在安装...
call "%DSH%" plugin --profile %PROFILE% add "%TGZ%"
if errorlevel 1 (
  echo.
  echo [失败] 安装命令返回错误，请把上面的输出发给作者。
  pause
  exit /b 1
)
echo.

rem 5. 检查 bundles（关键：不加这一步插件不会生效）
set "PROFILE_PKG=%USERPROFILE%\.dsh\profiles\%PROFILE%\package.json"
if not exist "!PROFILE_PKG!" (
  echo [提醒] 未找到 packge.json，请手动确认 bundles。
  pause
  exit /b 0
)
findstr /c:"dsh-startup-secret" "!PROFILE_PKG!" >nul 2>nul
if errorlevel 1 (
  echo.
  echo [重要] 依赖已装好，但 bundles 里还没有本插件。
  echo        请打开: !PROFILE_PKG!
  echo        在 dsh.profile.bundles 数组里加入: "dsh-startup-secret"
)
echo.
echo ============================================
echo   安装完成
echo ============================================
echo.
echo 下一步: 重启 DSH（完全退出再打开），启动动画即可生效。
pause
exit /b 0
