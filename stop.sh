#!/bin/bash
# ================================================
# Dahzah 停止脚本
# ================================================

set -e

echo "=========================================="
echo "Dahzah 停止脚本"
echo "=========================================="

docker-compose down

echo ""
echo "服务已停止"
echo -e "重新启动: ${YELLOW}./start.sh${NC}"
echo -e "完全删除: ${YELLOW}docker-compose down -v${NC} (会删除数据)"
