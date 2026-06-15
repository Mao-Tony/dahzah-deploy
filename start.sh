#!/bin/bash
# ================================================
# Dahzah 一键启动脚本
# ================================================

set -e

echo "=========================================="
echo "Dahzah 启动脚本"
echo "=========================================="

# 检查 Docker
if ! command -v docker &> /dev/null; then
    echo "错误: Docker 未安装"
    exit 1
fi

# 检查环境变量
if [ ! -f ".env" ]; then
    echo "错误: .env 文件不存在，请先运行 install.sh"
    exit 1
fi

# 启动服务
docker-compose up -d

# 等待启动
sleep 5

# 显示状态
echo ""
echo "=========================================="
echo "服务状态:"
echo "=========================================="
docker-compose ps
echo ""
echo "访问地址:"
echo "  前端页面: http://localhost"
echo "  后端 API: http://localhost:8000"
echo ""
echo -e "查看日志: ${YELLOW}docker-compose logs -f${NC}"
echo -e "停止服务: ${YELLOW}docker-compose down${NC}"
