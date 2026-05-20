# ============================================
# BazZ API — Production Dockerfile
# ============================================
# Multi-stage build for minimal image size
# Used as fallback if App Runner GitHub source has issues

# ── Stage 1: Install dependencies ──────────
FROM node:20-alpine AS deps
RUN apk add --no-cache libc6-compat openssl
RUN npm install -g pnpm@9

WORKDIR /app

# Copy package files (pnpm-lock.yaml lives at repo root, not in apps/api)
COPY package.json ./
COPY prisma ./prisma/

# Install all deps (including dev for build)
RUN pnpm install --no-frozen-lockfile

# ── Stage 2: Build ─────────────────────────
FROM deps AS builder
WORKDIR /app

COPY . .

# Generate Prisma client + compile TypeScript
RUN pnpm build

# ── Stage 3: Production image ───────────────
FROM node:20-alpine AS runner
RUN apk add --no-cache libc6-compat openssl

WORKDIR /app
ENV NODE_ENV=production

# Copy only what's needed to run
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/dist ./dist
COPY --from=builder /app/prisma ./prisma
COPY --from=builder /app/package.json ./package.json
COPY --from=builder /app/start.sh ./start.sh
RUN chmod +x start.sh

EXPOSE 3000

CMD ["sh", "start.sh"]
