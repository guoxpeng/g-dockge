#!/bin/bash

# Dockge 一键安装脚本（端口100 + 启用控制台）
# 作者：DeepSeek Chat
# 使用方法：保存为 install_dockge.sh，然后运行 chmod +x install_dockge.sh && ./install_dockge.sh

set -e  # 遇到错误自动退出

echo "🚀 开始安装 Dockge（端口：100，启用控制台）..."

# 定义变量
DOCKGE_PORT=100
DOCKGE_DATA_DIR="/opt/dockge-data"  # 数据存储目录（可修改）

# 创建数据目录（如果不存在）
sudo mkdir -p "$DOCKGE_DATA_DIR"
sudo chown -R "$(whoami)" "$DOCKGE_DATA_DIR"

# 检查是否已安装 Docker
if ! command -v docker &> /dev/null; then
    echo "❌ Docker 未安装，正在尝试自动安装..."
    curl -fsSL https://get.docker.com | sudo sh
    sudo usermod -aG docker "$(whoami)"
    echo "✅ Docker 安装完成，请重新登录以生效用户组权限"
    exit 1
fi

# 停止并删除现有容器（如果存在）
if docker ps -a --format '{{.Names}}' | grep -q "^dockge$"; then
    echo "🔄 发现现有 Dockge 容器，正在删除..."
    docker stop dockge > /dev/null 2>&1 || true
    docker rm dockge > /dev/null 2>&1 || true
fi

# 拉取最新镜像
echo "🔍 拉取 Dockge 最新镜像..."
docker pull louislam/dockge:1

# 启动容器
echo "🐳 启动 Dockge 容器（端口：$DOCKGE_PORT）..."
docker run -d \
    --name dockge \
    -e DOCKGE_ENABLE_CONSOLE=true \
    -v /var/run/docker.sock:/var/run/docker.sock \
    -v "$DOCKGE_DATA_DIR:/app/data" \
    -p "$DOCKGE_PORT:5001" \
    -u root \
    louislam/dockge:1

# 检查状态
if docker ps --format '{{.Names}}' | grep -q "^dockge$"; then
    echo -e "\n🎉 Dockge 安装成功！"
    echo -e "👉 访问地址：\033[4mhttp://$(curl -s ifconfig.me):$DOCKGE_PORT\033[0m"
    echo -e "📁 数据目录：$DOCKGE_DATA_DIR"
    echo -e "⚠️ 注意：控制台已启用，请确保仅在安全网络使用！"
else
    echo "❌ 容器启动失败，请检查日志：docker logs dockge"
fi