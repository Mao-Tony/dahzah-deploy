#!/bin/bash
# ================================================
# Dahzah 环境检测和 Swap 配置脚本
# ================================================

set -e

echo "=========================================="
echo "Dahzah 环境检测"
echo "=========================================="

# 获取总内存 (MB)
TOTAL_MEM=$(free -m | awk '/^Mem:/{print $2}')
AVAILABLE_MEM=$(free -m | awk '/^Mem:/{print $7}')
SWAP_TOTAL=$(free -m | awk '/^Swap:/{print $2}')

echo ""
echo "当前内存状态:"
echo "  总内存: ${TOTAL_MEM}MB"
echo "  可用内存: ${AVAILABLE_MEM}MB"
echo "  Swap: ${SWAP_TOTAL}MB"
echo ""

# 检查是否需要配置 Swap
MIN_MEM_REQUIRED=2048  # 最低要求 2GB

if [ "$TOTAL_MEM" -lt "$MIN_MEM_REQUIRED" ]; then
    echo -e "\033[33m内存不足 ${MIN_MEM_REQUIRED}MB，正在检查 Swap...\033[0m"

    if [ "$SWAP_TOTAL" -eq 0 ]; then
        echo -e "\033[33m未检测到 Swap，正在自动配置...\033[0m"

        # 计算需要的 Swap 大小 (内存的 2 倍，最低 1GB，最高 4GB)
        SWAP_SIZE=$((TOTAL_MEM * 2))
        if [ "$SWAP_SIZE" -lt 1024 ]; then
            SWAP_SIZE=1024
        fi
        if [ "$SWAP_SIZE" -gt 4096 ]; then
            SWAP_SIZE=4096
        fi

        echo "将创建 ${SWAP_SIZE}MB 的 Swap 文件..."

        # 检查是否有足够磁盘空间 (需要 Swap 大小的 2 倍)
        AVAILABLE_DISK=$(df -m / | awk 'NR==2 {print $4}')
        if [ "$AVAILABLE_DISK" -lt $((SWAP_SIZE * 2)) ]; then
            echo -e "\033[31m错误: 磁盘空间不足，需要至少 $((SWAP_SIZE * 2))MB 可用空间\033[0m"
            echo "当前可用: ${AVAILABLE_DISK}MB"
            exit 1
        fi

        # 创建 Swap 文件
        echo "创建 Swap 文件..."
        sudo fallocate -l ${SWAP_SIZE}M /swapfile || sudo dd if=/dev/zero of=/swapfile bs=1M count=$SWAP_SIZE

        # 设置权限
        echo "设置权限..."
        sudo chmod 600 /swapfile

        # 格式化
        echo "格式化 Swap..."
        sudo mkswap /swapfile

        # 启用 Swap
        echo "启用 Swap..."
        sudo swapon /swapfile

        # 添加到 fstab
        if ! grep -q "/swapfile" /etc/fstab 2>/dev/null; then
            echo "添加到 fstab..."
            echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
        fi

        # 设置 swappiness
        echo "设置 swappiness..."
        sudo sysctl vm.swappiness=10
        echo "vm.swappiness=10" | sudo tee -a /etc/sysctl.conf

        echo ""
        echo -e "\033[32mSwap 配置完成！\033[0m"
    else
        echo -e "\033[32m已有 Swap ${SWAP_TOTAL}MB，无需额外配置\033[0m"
    fi
else
    echo -e "\033[32m内存充足，无需配置 Swap\033[0m"
fi

# 显示最终状态
echo ""
echo "=========================================="
echo "最终状态:"
echo "=========================================="
free -h
echo ""

# Docker 检查
echo "检查 Docker..."
if command -v docker &> /dev/null; then
    echo -e "\033[32m✓ Docker 已安装\033[0m"
    docker --version
else
    echo -e "\033[31m✗ Docker 未安装\033[0m"
    echo "请先安装 Docker: https://docs.docker.com/get-docker/"
    exit 1
fi

echo ""
echo "环境检测完成！"
