# ==================== 前端 Dockerfile ====================
# 构建: docker build -t dahzah-frontend ./frontend
# 运行: docker run -d -p 3000:3000 --env-file .env.local dahzah-frontend

FROM node:20-alpine AS builder

WORKDIR /app

# 安装依赖
COPY package.json pnpm-lock.yaml ./
RUN corepack enable && pnpm install --frozen-lockfile

# 复制源代码
COPY . .

# 构建
RUN API_BASE_URL=http://backend:8000 pnpm build

# ==================== 生产镜像 ====================
FROM node:20-alpine AS runner

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
