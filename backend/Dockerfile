# ==================== 后端 Dockerfile ====================
# 构建时自动从 GitHub 拉取代码
# 支持私有仓库认证

ARG BACKEND_REPO=https://github.com/Mao-Tony/dazah-backend.git
ARG BACKEND_BRANCH=main

FROM registry.cn-hangzhou.aliyuncs.com/acs/python:3.12-slim

WORKDIR /app

# 安装系统依赖和 git
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl git \
    && rm -rf /var/lib/apt/lists/*

# 配置清华 PyPI 镜像
RUN pip config set global.index-url https://pypi.tuna.tsinghua.edu.cn/simple && \
    pip config set global.trusted-host https://pypi.tuna.tsinghua.edu.cn

# 使用 pip 安装 uv
RUN pip install uv

# 克隆代码
RUN git clone --branch ${BACKEND_BRANCH} --depth 1 ${BACKEND_REPO} /tmp/backend && \
    cp -r /tmp/backend/* /app/ && \
    rm -rf /tmp/backend

# 安装依赖
RUN uv sync --frozen --no-dev --index-url https://pypi.tuna.tsinghua.edu.cn/simple

# 创建上传和日志目录
RUN mkdir -p /app/uploads /app/logs

EXPOSE 8000

CMD ["uv", "run", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
