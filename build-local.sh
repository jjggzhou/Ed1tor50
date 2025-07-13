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

# 创建输出目录
mkdir -p firmwares

# 构建Docker镜像
echo "正在构建Docker镜像..."
docker-compose build

# 运行构建
echo "开始构建固件..."
docker-compose run --rm builder /usr/local/bin/build.sh $BOARD $SHIELD

# 检查构建结果
if [ -f "firmwares/zmk.uf2" ]; then
    echo ""
    echo "=== 构建成功 ==="
    echo "固件文件已保存到firmwares目录:"
    ls -la firmwares/*.uf2 firmwares/*.hex firmwares/*.bin 2>/dev/null || true
else
    echo ""
    echo "=== 构建失败 ==="
    echo "未找到固件文件，请检查构建日志"
    exit 1
fi 