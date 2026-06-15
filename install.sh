#!/bin/bash
# ================================================
# Dahzah 一键安装脚本 - 适配云服务器
# ================================================

set -e

echo "=========================================="
echo "Dahzah 一键安装脚本"
echo "=========================================="

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}错误: Docker Compose 未安装${NC}"
    echo "请先安装 Docker Compose"
    exit 1
fi

echo -e "${GREEN}✓ Docker 检查通过${NC}"

# 检查目录
if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    echo -e "${YELLOW}正在克隆代码...${NC}"

    if [ ! -d "backend" ]; then
        git clone https://github.com/Mao-Tony/dazah-backend.git backend
    fi

    if [ ! -d "frontend" ]; then
        git clone https://github.com/Mao-Tony/dazah-frontend.git frontend
    fi
fi

# 创建环境变量文件
if [ ! -f ".env" ]; then
    echo -e "${YELLOW}创建环境变量文件...${NC}"
    cp .env.example .env

    # 生成随机密钥
    SECRET_KEY=$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64)
    sed -i "s/your-secret-key-change-this-in-production/$SECRET_KEY/" .env

    echo -e "${YELLOW}请编辑 .env 文件配置必填项:${NC}"
    echo "  - POSTGRES_PASSWORD (数据库密码)"
    echo "  - MINIMAX_API_KEY (AI 服务密钥，可选)"
fi

# 创建前端环境变量
if [ ! -f "frontend/.env.local" ]; then
    echo -e "${YELLOW}创建前端环境变量...${NC}"
    cp frontend/.env.example frontend/.env.local
fi

# 创建 SSL 目录
mkdir -p ssl

# 构建并启动
echo -e "${GREEN}开始构建 Docker 镜像...${NC}"
docker-compose build --no-cache

echo -e "${GREEN}启动服务...${NC}"
docker-compose up -d

# 等待服务启动
echo -e "${YELLOW}等待服务启动...${NC}"
sleep 10

# 检查服务状态
echo ""
echo "=========================================="
echo "安装完成！"
echo "=========================================="
echo ""
echo "服务状态:"
docker-compose ps
echo ""
echo "访问地址:"
echo "  前端页面: http://localhost"
echo "  后端 API: http://localhost:8000"
echo "  API 文档: http://localhost:8000/docs"
echo ""
echo -e "${YELLOW}查看日志: docker-compose logs -f${NC}"
echo -e "${YELLOW}停止服务: docker-compose down${NC}"
