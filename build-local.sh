#!/bin/bash

# ZMK本地Docker构建脚本
set -e

echo "=== ZMK本地Docker构建脚本 ==="

# 检查Docker是否安装
if ! command -v docker &> /dev/null; then
    echo "错误: 未找到Docker，请先安装Docker"
    exit 1
fi

# 检查docker-compose是否安装
if ! command -v docker-compose &> /dev/null; then
    echo "错误: 未找到docker-compose，请先安装docker-compose"
    exit 1
fi

# 默认参数
BOARD=${1:-"nrfmicro_13"}
SHIELD=${2:-"Ed1tor50"}

echo "构建参数:"
echo "  板卡: $BOARD"
echo "  Shield: $SHIELD"
echo ""

# 构建Docker镜像
echo "正在构建Docker镜像..."
docker-compose build

# 运行构建
echo "开始构建固件..."
docker-compose run --rm zmk-build $BOARD $SHIELD

echo ""
echo "=== 构建完成 ==="
echo "固件文件应该位于: build/zephyr/zmk.uf2"
echo "如果构建成功，您可以将zmk.uf2文件复制到键盘进行刷写" 