# Dahzah 一键部署指南

基于 Docker Compose 的一键部署方案，包含后端、前端、数据库和 Nginx 反向代理。

## 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 2GB+ 内存
- 10GB+ 磁盘空间

## 快速开始

### 1. 克隆代码

```bash
# 克隆后端
git clone https://github.com/Mao-Tony/dazah-backend.git backend

# 克隆前端
git clone https://github.com/Mao-Tony/dazah-frontend.git frontend

# 进入部署目录
cd dahzah-deploy
```

### 2. 配置环境变量

```bash
# 复制环境变量模板
cp .env.example .env

# 编辑 .env 文件，填入你的配置
nano .env
```

必须配置项：
- `SECRET_KEY` - 生成随机密钥
- `POSTGRES_PASSWORD` - 数据库密码
- `MINIMAX_API_KEY` - MiniMax AI API 密钥（用于 AI 识别功能）

### 3. 启动服务

```bash
# 构建并启动所有服务
docker-compose up -d

# 查看服务状态
docker-compose ps

# 查看日志
docker-compose logs -f
```

### 4. 访问应用

- 前端页面: http://localhost
- 后端 API: http://localhost:8000
- API 文档: http://localhost:8000/docs

## 服务说明

| 服务 | 端口 | 说明 |
|------|------|------|
| Nginx | 80, 443 | 反向代理 |
| Frontend | 3000 | Next.js 前端 |
| Backend | 8000 | FastAPI 后端 |
| PostgreSQL | 5432 | 数据库 |
| Redis | 6379 | 缓存 |

## 常用命令

```bash
# 停止服务
docker-compose down

# 重启服务
docker-compose restart

# 更新代码后重新构建
docker-compose up -d --build

# 进入后端容器
docker-compose exec backend bash

# 进入数据库
docker-compose exec db psql -U postgres -d dahzah

# 查看后端日志
docker-compose logs -f backend

# 重新运行数据库迁移
docker-compose exec backend uv run alembic upgrade head
```

## 数据持久化

所有数据通过 Docker Volume 持久化：
- `pgdata` - PostgreSQL 数据
- `redisdata` - Redis 数据
- `backend-uploads` - 后端上传文件
- `frontend-uploads` - 前端上传文件

## SSL 配置 (可选)

如需启用 HTTPS：

1. 将 SSL 证书放入 `ssl/` 目录：
   - `ssl/server.crt` - 证书
   - `ssl/server.key` - 私钥

2. 修改 `nginx.conf` 启用 HTTPS

## 故障排查

### 服务启动失败
```bash
docker-compose logs <service-name>
```

### 数据库连接失败
检查 `POSTGRES_USER` 和 `POSTGRES_PASSWORD` 是否正确

### 前端无法访问后端 API
检查 `API_BASE_URL` 配置和 Nginx 代理配置

## License

Private - All Rights Reserved
