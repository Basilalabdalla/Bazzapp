# ============================================
# BazZ API — Production Dockerfile
# ============================================
# Build context: apps/api directory
# pnpm-lock.yaml is at repo root — not available here
# so we use --no-frozen-lockfile

FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat openssl
RUN npm install -g pnpm@9

WORKDIR /app

COPY package.json ./
COPY prisma ./prisma/

RUN pnpm install --no-frozen-lockfile

# ── Stage 2: Build ─────────────────────────
FROM deps AS builder
WORKDIR /app

COPY . .

RUN pnpm build

# ── Stage 3: Production image ───────────────
FROM node:20-alpine AS runner
RUN apk add --no-cache libc6-compat openssl

WORKDIR /app
ENV NODE_ENV=production

COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/start.sh ./start.sh
RUN chmod +x start.sh

EXPOSE 3000

CMD ["sh", "start.sh"]
