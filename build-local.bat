@echo off
REM ZMK本地Docker构建脚本 (Windows版本)
setlocal enabledelayedexpansion

echo === ZMK本地Docker构建脚本 ===

REM 检查Docker是否安装
docker --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到Docker，请先安装Docker Desktop
    pause
    exit /b 1
)

REM 检查docker-compose是否安装
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo 错误: 未找到docker-compose，请先安装docker-compose
    pause
    exit /b 1
)

REM 默认参数
set BOARD=%1
if "%BOARD%"=="" set BOARD=nice_nano_v2

set SHIELD=%2
if "%SHIELD%"=="" set SHIELD=Ed1tor50

echo 构建参数:
echo   板卡: %BOARD%
echo   Shield: %SHIELD%
echo.

REM 构建Docker镜像
echo 正在构建Docker镜像...
docker-compose build
if errorlevel 1 (
    echo 构建镜像失败
    pause
    exit /b 1
)

REM 运行构建
echo 开始构建固件...
docker-compose run --rm zmk-build %BOARD% %SHIELD%
if errorlevel 1 (
    echo 构建固件失败
    pause
    exit /b 1
)

echo.
echo === 构建完成 ===
echo 固件文件应该位于: build/zephyr/zmk.uf2
echo 如果构建成功，您可以将zmk.uf2文件复制到键盘进行刷写
pause 