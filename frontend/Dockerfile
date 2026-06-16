# ==================== 前端 Dockerfile ====================
# 构建时自动从 GitHub 拉取代码
# 支持私有仓库认证

ARG FRONTEND_REPO=https://github.com/Mao-Tony/dazah-frontend.git
ARG FRONTEND_BRANCH=main
ARG NEXT_PUBLIC_API_URL=http://backend:8000/api/v1

FROM registry.cn-hangzhou.aliyuncs.com/acs/node:20-alpine AS builder

WORKDIR /app

# 配置淘宝 npm 镜像
RUN npm config set registry https://registry.npmmirror.com && \
    corepack enable && \
    corepack prepare pnpm@latest --activate

# 安装 git
RUN apk add --no-cache git

# 克隆代码（使用 GitHub 代理加速）
RUN git clone --branch ${FRONTEND_BRANCH} --depth 1 https://gh-proxy.org/${FRONTEND_REPO#https://} /tmp/frontend && \
    cp -r /tmp/frontend/* /app/ && \
    rm -rf /tmp/frontend

# 设置环境变量
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
ENV NEXT_PUBLIC_USE_LOCAL=/api/v1

# 安装依赖
RUN pnpm install --frozen-lockfile --registry https://registry.npmmirror.com

# 构建
RUN pnpm build --registry https://registry.npmmirror.com

# ==================== 生产镜像 ====================
FROM registry.cn-hangzhou.aliyuncs.com/acs/node:20-alpine AS runner

WORKDIR /app

ENV NODE_ENV=production

# 创建非 root 用户
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# 创建目录
RUN mkdir -p /app/public/uploads && \
    chown -R nextjs:nodejs /app

USER nextjs

EXPOSE 3000

ENV PORT=3000
ENV HOSTNAME="0.0.0.0"

# 复制构建产物
COPY --from=builder --chown=nextjs:nodejs /app/.next/standalone ./
COPY --from=builder --chown=nextjs:nodejs /app/.next/static ./
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

CMD ["node", "server.js"]
