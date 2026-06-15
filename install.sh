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

# ================================================
# 1. 环境检测和 Swap 配置
# ================================================
echo -e "\n${YELLOW}[1/5] 环境检测和 Swap 配置...${NC}"

# 获取总内存 (MB)
TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')
SWAP_TOTAL=$(free -m | awk '/^Swap:/{print $2}')

echo "  当前内存: ${TOTAL_MEM}MB, 可用: ${AVAILABLE_MEM}MB, Swap: ${SWAP_TOTAL}MB"

# 检查是否需要配置 Swap (低于 2GB)
MIN_MEM_REQUIRED=2048

if [ "$TOTAL_MEM" -lt "$MIN_MEM_REQUIRED" ]; then
    echo -e "  ${YELLOW}内存不足 ${MIN_MEM_REQUIRED}MB，检查 Swap...${NC}"

    if [ "$SWAP_TOTAL" -eq 0 ]; then
        echo -e "  ${YELLOW}未检测到 Swap，正在自动配置...${NC}"

        # 计算需要的 Swap 大小 (内存的 2 倍，最低 1GB，最高 4GB)
        SWAP_SIZE=$((TOTAL_MEM * 2))
        [ "$SWAP_SIZE" -lt 1024 ] && SWAP_SIZE=1024
        [ "$SWAP_SIZE" -gt 4096 ] && SWAP_SIZE=4096

        echo -e "  将创建 ${SWAP_SIZE}MB 的 Swap 文件..."

        # 检查磁盘空间
        AVAILABLE_DISK=$(df -m / | awk 'NR==2 {print $4}')
        if [ "$AVAILABLE_DISK" -lt $((SWAP_SIZE * 2)) ]; then
            echo -e "  ${RED}错误: 磁盘空间不足${NC}"
            echo "  需要至少 $((SWAP_SIZE * 2))MB，当前 ${AVAILABLE_DISK}MB"
        else
            # 创建 Swap
            sudo fallocate -l ${SWAP_SIZE}M /swapfile 2>/dev/null || \
            sudo dd if=/dev/zero of=/swapfile bs=1M count=$SWAP_SIZE 2>/dev/null
            sudo chmod 600 /swapfile
            sudo mkswap /swapfile
            sudo swapon /swapfile

            # 添加到 fstab
            grep -q "/swapfile" /etc/fstab || echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

            # 设置 swappiness
            sudo sysctl vm.swappiness=10 2>/dev/null
            grep -q "vm.swappiness" /etc/sysctl.conf || echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf

            echo -e "  ${GREEN}✓ Swap 配置完成: ${SWAP_SIZE}MB${NC}"
        fi
    else
        echo -e "  ${GREEN}✓ 已有 Swap ${SWAP_TOTAL}MB${NC}"
    fi
else
    echo -e "  ${GREEN}✓ 内存充足，无需配置 Swap${NC}"
fi

# ================================================
# 2. Docker 检查
# ================================================
echo -e "\n${YELLOW}[2/5] Docker 检查...${NC}"

if ! command -v docker &> /dev/null; then
    echo -e "${RED}错误: Docker 未安装${NC}"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}错误: Docker Compose 未安装${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Docker 检查通过${NC}"
docker --version | sed 's/^/  /'

# ================================================
# 3. 克隆代码
# ================================================
echo -e "\n${YELLOW}[3/5] 克隆代码...${NC}"

if [ ! -d "backend" ] || [ ! -d "frontend" ]; then
    if [ ! -d "backend" ]; then
        echo "  克隆后端代码..."
        git clone https://github.com/Mao-Tony/dazah-backend.git backend
    fi

    if [ ! -d "frontend" ]; then
        echo "  克隆前端代码..."
        git clone https://github.com/Mao-Tony/dazah-frontend.git frontend
    fi
else
    echo -e "${GREEN}✓ 代码已存在，跳过克隆${NC}"
fi

# ================================================
# 4. 配置环境变量
# ================================================
echo -e "\n${YELLOW}[4/5] 配置环境变量...${NC}"

if [ ! -f ".env" ]; then
    echo "  创建 .env 文件..."
    cp .env.example .env

    # 生成随机密钥
    SECRET_KEY=$(openssl rand -base64 32 2>/dev/null || head -c 32 /dev/urandom | base64)
    sed -i "s/your-secret-key-change-this-in-production/$SECRET_KEY/" .env
    echo -e "  ${GREEN}✓ .env 已创建，请编辑配置必填项${NC}"
else
    echo -e "${GREEN}✓ .env 已存在${NC}"
fi

# 前端环境变量
if [ ! -f "frontend/.env.local" ]; then
    cp frontend/.env.example frontend/.env.local
    echo -e "  ${GREEN}✓ frontend/.env.local 已创建${NC}"
fi

# SSL 目录
mkdir -p ssl
echo -e "  ${GREEN}✓ ssl 目录已创建${NC}"

# ================================================
# 5. 构建和启动
# ================================================
echo -e "\n${YELLOW}[5/5] 构建和启动服务...${NC}"

echo -e "  ${YELLOW}构建 Docker 镜像 (可能需要几分钟)...${NC}"
docker-compose build

echo -e "  ${YELLOW}启动服务...${NC}"
docker-compose up -d

# 等待服务启动
echo -e "  ${YELLOW}等待服务启动...${NC}"
sleep 15

# ================================================
# 完成
# ================================================
echo ""
echo "=========================================="
echo -e "${GREEN}安装完成！${NC}"
echo "=========================================="
echo ""
echo "服务状态:"
docker-compose ps | sed 's/^/  /'
echo ""
echo "访问地址:"
echo "  前端页面: http://localhost:3000"
echo "  后端 API: http://localhost:8000"
echo "  API 文档: http://localhost:8000/docs"
echo ""
echo -e "${YELLOW}查看日志: docker-compose logs -f${NC}"
echo -e "${YELLOW}停止服务: docker-compose down${NC}"
