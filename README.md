# Dahzah 一键部署指南

基于 Docker Compose 的一键部署方案，全程使用国内镜像源，适合中国大陆服务器。

## 镜像源说明

- **Docker 基础镜像**: 阿里云容器镜像服务
- **Python 依赖**: 清华 PyPI 镜像
- **Node.js 依赖**: 淘宝 npm 镜像

无需额外配置 Docker daemon 镜像加速，所有资源均从国内获取。

## 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 2GB+ 内存
- 10GB+ 磁盘空间

## 快速开始

### 1. 一键克隆

```bash
git clone https://github.com/Mao-Tony/dahzah-deploy.git
cd dahzah-deploy

# 克隆后端代码
git clone https://github.com/Mao-Tony/dazah-backend.git backend

# 克隆前端代码
git clone https://github.com/Mao-Tony/dazah-frontend.git frontend
```

### 2. 配置环境变量

```bash
cp .env.example .env
nano .env
```

必须配置项：
- `SECRET_KEY` - 生成随机密钥
- `POSTGRES_PASSWORD` - 数据库密码
- `MINIMAX_API_KEY` - MiniMax AI API 密钥

### 3. 启动服务

```bash
docker-compose up -d
```

构建过程会自动从国内镜像拉取，无需额外配置。

### 4. 访问应用

- 前端页面: http://localhost
- 后端 API: http://localhost:8000
- API 文档: http://localhost:8000/docs

## 服务说明

| 服务 | 端口 | 镜像 |
|------|------|------|
| Nginx | 80, 443 | 阿里云 acs/nginx:alpine |
| Frontend | 3000 | 阿里云 acs/node:20-alpine |
| Backend | 8000 | 阿里云 acs/python:3.12-slim |
| PostgreSQL | 5432 | 阿里云 acs/postgres:17 |
| Redis | 6379 | 阿里云 acs/redis:latest |

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
