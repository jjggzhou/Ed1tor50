# ZMK本地Docker构建指南

这个项目现在支持使用Docker进行本地ZMK固件构建，避免了复杂的本地环境配置。

## 前置要求

1. **安装Docker Desktop**
   - Windows: 下载并安装 [Docker Desktop for Windows](https://www.docker.com/products/docker-desktop)
   - macOS: 下载并安装 [Docker Desktop for Mac](https://www.docker.com/products/docker-desktop)
   - Linux: 按照 [Docker安装指南](https://docs.docker.com/engine/install/) 安装

2. **安装Docker Compose**
   - 通常Docker Desktop已经包含了docker-compose
   - 如果没有，请参考 [Docker Compose安装指南](https://docs.docker.com/compose/install/)

## 快速开始

### 方法1: 使用构建脚本（推荐）

```bash
# 使用默认参数构建
./build-local.sh

# 或者指定板卡和shield
./build-local.sh nrfmicro_13 Ed1tor50
```

### 方法2: 使用docker-compose

```bash
# 构建镜像
docker-compose build

# 运行构建
docker-compose run --rm zmk-build nrfmicro_13 Ed1tor50
```

### 方法3: 直接使用Docker

```bash
# 构建镜像
docker build -t zmk-builder .

# 运行构建
docker run --rm -v $(pwd):/workspace zmk-builder nrfmicro_13 Ed1tor50
```

## 构建参数

- `BOARD`: 目标板卡（默认: nrfmicro_13）
- `SHIELD`: 键盘shield（默认: Ed1tor50）

## 输出文件

构建完成后，固件文件将位于：
- `build/zephyr/zmk.uf2` - 主要的固件文件
- `build/zephyr/zmk.hex` - HEX格式的固件文件

## 刷写固件

1. 将键盘进入DFU模式
2. 将 `zmk.uf2` 文件复制到出现的USB存储设备中
3. 等待刷写完成，键盘将自动重启

## 故障排除

### 构建失败
- 检查Docker是否正确安装
- 确保有足够的磁盘空间（至少5GB）
- 检查网络连接，首次构建需要下载依赖

### 权限问题
- Windows: 确保Docker Desktop有足够的权限
- Linux: 可能需要将用户添加到docker组

### 缓存问题
- 清除Docker缓存: `docker system prune -a`
- 重新构建: `docker-compose build --no-cache`

## 高级用法

### 交互式调试
```bash
# 进入容器进行调试
docker-compose run --rm -it zmk-build bash
```

### 自定义构建
```bash
# 在容器内手动执行构建命令
docker run --rm -v $(pwd):/workspace zmk-builder bash -c "
west build -s zmk/app -b nrfmicro_13 -- -DSHIELD=Ed1tor50
"
```

## 性能优化

- 构建缓存会自动保存在Docker volumes中
- 首次构建较慢，后续构建会更快
- 可以通过修改 `docker-compose.yml` 来调整缓存设置 