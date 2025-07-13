# ZMK固件编译Docker镜像
FROM ubuntu:22.04

# 设置环境变量
ENV DEBIAN_FRONTEND=noninteractive
ENV ZEPHYR_BASE=/workspace/zephyr
ENV ZMK_DIR=/workspace/zmk
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

# 设置构建脚本
RUN echo '#!/bin/bash\n\
set -e\n\
\n\
echo "Starting ZMK firmware build..."\n\
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
if [ ! -z "$SHIELD" ]; then\n\
    echo "Using shield: $SHIELD"\n\
    west build -s zmk/app -b $BOARD -- -DSHIELD=$SHIELD\n\
else\n\
    west build -s zmk/app -b $BOARD\n\
fi\n\
\n\
echo "Build completed! Firmware file located at: build/zephyr/zmk.uf2"\n\
' > /workspace/build.sh && chmod +x /workspace/build.sh

# 设置入口点
ENTRYPOINT ["/workspace/build.sh"] 