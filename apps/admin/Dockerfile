# ── Stage 1: Build ────────────────────────────────────────────────────────────
FROM node:22-alpine AS builder

WORKDIR /app

# Install pnpm
RUN npm install -g pnpm

# Copy package files
COPY package.json ./
COPY apps/admin/package.json ./apps/admin/

# Install dependencies (admin only — no shared workspace deps)
WORKDIR /app/apps/admin
RUN pnpm install --no-frozen-lockfile

# Copy source
COPY apps/admin ./

# Build — API URL is baked in at build time
ARG VITE_API_URL=https://api.bazzmarket.com
ARG VITE_WS_URL=wss://api.bazzmarket.com
ENV VITE_API_URL=$VITE_API_URL
ENV VITE_WS_URL=$VITE_WS_URL

RUN pnpm build

# ── Stage 2: Serve with nginx ──────────────────────────────────────────────────
FROM nginx:alpine

# Copy built files
COPY --from=builder /app/apps/admin/dist /usr/share/nginx/html

# Copy nginx config
COPY apps/admin/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD wget -qO- http://localhost/health || exit 1

CMD ["nginx", "-g", "daemon off;"]
