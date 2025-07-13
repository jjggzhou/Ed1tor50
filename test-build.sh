#!/bin/bash

echo "=== ZMK构建测试脚本 ==="

# 检查当前目录
echo "当前目录: $(pwd)"
echo "目录内容:"
ls -la

# 检查west配置
echo ""
echo "=== West配置检查 ==="
west status

echo ""
echo "=== 检查Zephyr目录 ==="
if [ -d "zephyr" ]; then
    echo "Zephyr目录存在"
    ls -la zephyr/
else
    echo "Zephyr目录不存在"
fi

echo ""
echo "=== 检查ZMK目录 ==="
if [ -d "zmk" ]; then
    echo "ZMK目录存在"
    ls -la zmk/
else
    echo "ZMK目录不存在"
fi

echo ""
echo "=== 环境变量 ==="
echo "ZEPHYR_BASE: $ZEPHYR_BASE"
echo "ZMK_DIR: $ZMK_DIR"
echo "PWD: $PWD"

echo ""
echo "=== 尝试构建 ==="
west build -s zmk/app -b nrfmicro_13 -- -DSHIELD=Ed1tor50 