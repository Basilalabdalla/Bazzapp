#!/bin/sh
# ============================================
# BazZ API — Production Startup Script
# ============================================
# 1. Run DB migrations (safe to run on every deploy — idempotent)
# 2. Start the server

set -e

echo "▶ Running Prisma migrations..."
./node_modules/.bin/prisma migrate deploy

echo "▶ Starting BazZ API..."
exec node dist/main.js
