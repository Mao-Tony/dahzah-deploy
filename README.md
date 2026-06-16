# Dahzah 一键部署指南

基于 Docker Compose 的一键部署方案，全程使用国内镜像源，构建时自动拉取代码。

## 特性

- **自动拉取代码**：构建时自动从 GitHub 克隆前后端代码
- **国内镜像**：所有基础镜像和依赖来自国内源
- **一键部署**：只需 Docker 一个环境

## 系统要求

- Docker 20.10+
- Docker Compose 2.0+
- 2GB+ 内存
- 10GB+ 磁盘空间

## 快速开始

### 1. 克隆部署配置

```bash
git clone https://github.com/Mao-Tony/dahzah-deploy.git
cd dahzah-deploy
```

### 2. 配置环境变量

```bash
cp .env.example .env
nano .env
```

必须配置项：
- `SECRET_KEY` - 生成随机密钥
- `POSTGRES_PASSWORD` - 数据库密码
- `MINIMAX_API_KEY` - MiniMax AI API 密钥（可选）

### 3. 一键启动

```bash
docker-compose up -d
```

构建过程会自动：
1. 从 GitHub 拉取前后端代码
2. 从国内镜像安装依赖
3. 构建并启动所有服务

### 4. 访问应用

- 前端页面: http://localhost:3000
- 后端 API: http://localhost:8000
- API 文档: http://localhost:8000/docs

## 服务说明

| 服务 | 端口 | 镜像 |
|------|------|------|
| Frontend | 3000 | 阿里云 acs/node:20-alpine |
| Backend | 8000 | 阿里云 acs/python:3.12-slim |
| PostgreSQL | 5432 | 阿里云 acs/postgres:17 |
| Redis | 6379 | 阿里云 acs/redis:latest |
| Nginx | 80, 443 | 阿里云 acs/nginx:alpine |

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

## 自定义代码仓库

如需使用自己的代码仓库，修改 `.env`：

```bash
BACKEND_REPO=https://github.com/你的用户名/你的后端仓库.git
FRONTEND_REPO=https://github.com/你的用户名/你的前端仓库.git
```

## 数据持久化

所有数据通过 Docker Volume 持久化：
- `pgdata` - PostgreSQL 数据
- `redisdata` - Redis 数据
- `backend-uploads` - 后端上传文件
- `frontend-uploads` - 前端上传文件

## 故障排查

### 服务启动失败
```bash
docker-compose logs <service-name>
```

### 数据库连接失败
检查 `POSTGRES_USER` 和 `POSTGRES_PASSWORD` 是否正确

### 前端无法访问后端 API
检查 `NEXT_PUBLIC_API_URL` 配置

## License

Private - All Rights Reserved
