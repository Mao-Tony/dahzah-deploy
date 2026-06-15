# ==================== 后端 Dockerfile ====================
# 构建: docker build -t dahzah-backend ./backend
# 运行: docker run -d -p 8000:8000 --env-file .env dahzah-backend

FROM python:3.12-slim

WORKDIR /app

# 安装系统依赖
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# 安装 uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# 复制依赖文件
COPY pyproject.toml uv.lock* ./

# 安装依赖
RUN uv sync --frozen --no-dev

# 复制应用代码
COPY . .

# 创建上传和日志目录
RUN mkdir -p /app/uploads /app/logs

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
