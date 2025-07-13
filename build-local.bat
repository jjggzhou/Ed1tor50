@echo off
chcp 65001 >nul
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
if "%BOARD%"=="" set BOARD=nrfmicro_13

set SHIELD=%2
if "%SHIELD%"=="" set SHIELD=Ed1tor50

echo 构建参数:
echo   板卡: %BOARD%
echo   Shield: %SHIELD%
echo.

REM 创建输出目录
if not exist firmwares mkdir firmwares

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
docker-compose run --rm builder /usr/local/bin/build.sh %BOARD% %SHIELD%
if errorlevel 1 (
    echo 构建固件失败
    pause
    exit /b 1
)

REM 检查构建结果
if exist firmwares\zmk.uf2 (
    echo.
    echo === 构建成功 ===
    echo 固件文件已保存到firmwares目录:
    dir firmwares\*.uf2 firmwares\*.hex firmwares\*.bin 2>nul
) else (
    echo.
    echo === 构建失败 ===
    echo 未找到固件文件，请检查构建日志
    pause
    exit /b 1
)

pause 