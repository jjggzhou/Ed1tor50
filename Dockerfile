# ZMK固件编译Docker镜像
FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8

# 安装必要的依赖
RUN apt-get update && apt-get install -y \
    git \
    wget \
    cmake \
    ninja-build \
    gperf \
    ccache \
    dfu-util \
    device-tree-compiler \
    python3 \
    python3-pip \
    python3-setuptools \
    python3-wheel \
    python3-dev \
    python3-venv \
    build-essential \
    libssl-dev \
    libffi-dev \
    pkg-config \
    libusb-1.0-0-dev \
    locales \
    && rm -rf /var/lib/apt/lists/*

# 设置locale
RUN locale-gen en_US.UTF-8

# 安装Python依赖
RUN pip3 install --upgrade pip setuptools wheel
RUN pip3 install west

# 创建工作目录
WORKDIR /workspace

# 复制配置文件
COPY config/ ./config/
COPY build.yaml ./

# 初始化Zephyr环境
RUN west init -l config
RUN west update
RUN west status

# 设置Zephyr环境变量
ENV ZEPHYR_BASE=/workspace/zephyr
ENV ZMK_DIR=/workspace/zmk

# 设置构建脚本
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "Starting ZMK firmware build..."\n\
\n\
# Set up environment\n\
export ZEPHYR_BASE=/workspace/zephyr\n\
export ZMK_DIR=/workspace/zmk\n\
\n\
# Check parameters\n\
if [ -z "$1" ]; then\n\
    echo "Usage: $0 <board> [shield]"\n\
    echo "Example: $0 nrfmicro_13 Ed1tor50"\n\
    exit 1\n\
fi\n\
\n\
BOARD=$1\n\
SHIELD=${2:-""}\n\
\n\
echo "Building board: $BOARD"\n\
echo "Current directory: $(pwd)"\n\
\n\
# Fix west environment\n\
echo "Fixing west environment..."\n\
west update\n\
west status\n\
\n\
# Build firmware\n\
if [ ! -z "$SHIELD" ]; then\n\
    echo "Using shield: $SHIELD"\n\
    west build -s zmk/app -b $BOARD -- -DSHIELD=$SHIELD\n\
else\n\
    west build -s zmk/app -b $BOARD\n\
fi\n\
\n\
# Copy firmware files to output directory\n\
echo "Checking for firmware files..."\n\
ls -la build/zephyr/ 2>/dev/null || echo "build/zephyr/ directory not found"\n\
\n\
if [ -f "build/zephyr/zmk.uf2" ]; then\n\
    echo "Copying firmware files to output directory..."\n\
    # 确保输出目录存在\n\
    mkdir -p /workspace/output\n\
    # 复制文件并显示详细信息\n\
    echo "Copying zmk.uf2..."\n\
    cp -v build/zephyr/zmk.uf2 /workspace/output/\n\
    \n\
    if [ -f "build/zephyr/zmk.hex" ]; then\n\
        echo "Copying zmk.hex..."\n\
        cp -v build/zephyr/zmk.hex /workspace/output/\n\
    else\n\
        echo "No .hex file found"\n\
    fi\n\
    \n\
    if [ -f "build/zephyr/zmk.bin" ]; then\n\
        echo "Copying zmk.bin..."\n\
        cp -v build/zephyr/zmk.bin /workspace/output/\n\
    else\n\
        echo "No .bin file found"\n\
    fi\n\
    \n\
    echo "Build completed! Firmware files copied to output directory:"\n\
    ls -la /workspace/output/*.uf2 /workspace/output/*.hex /workspace/output/*.bin 2>/dev/null || echo "No firmware files found in output directory"\n\
else\n\
    echo "Build failed - firmware file not found at build/zephyr/zmk.uf2"\n\
    echo "Available files in build/zephyr/:"\n\
    ls -la build/zephyr/ 2>/dev/null || echo "build/zephyr/ directory not found"\n\
    exit 1\n\
fi\n\
' > /usr/local/bin/build.sh && chmod +x /usr/local/bin/build.sh

# 设置默认命令
CMD ["/usr/local/bin/build.sh"] 