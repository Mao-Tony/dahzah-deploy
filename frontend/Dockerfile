# ==================== 前端 Dockerfile ====================
# 使用阿里云 Node 镜像 + 淘宝 npm 镜像

FROM registry.cn-hangzhou.aliyuncs.com/acs/node:20-alpine AS builder

WORKDIR /app

# 配置淘宝 npm 镜像
RUN npm config set registry https://registry.npmmirror.com && \
    corepack enable && \
    corepack prepare pnpm@latest --activate

# 复制依赖文件
COPY package.json pnpm-lock.yaml ./

# 使用国内镜像安装依赖
RUN pnpm install --frozen-lockfile --registry https://registry.npmmirror.com

# 复制源代码
COPY . .

# 复制环境变量文件到构建目录
COPY .env* ./

# 构建时使用环境变量
ARG NEXT_PUBLIC_API_URL=http://backend:8000/api/v1
ENV NEXT_PUBLIC_API_URL=${NEXT_PUBLIC_API_URL}
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
