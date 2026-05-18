import 'dotenv/config';
import http from 'http';
import express from 'express';
import cors from 'cors';
import helmet from 'helmet';
import compression from 'compression';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';

import { prisma } from './lib/prisma';
import { initWebSocket } from './lib/websocket';
import { initFirebase } from './lib/firebase';
import { setupSwagger } from './lib/swagger';
import { errorHandler } from './middleware/error.middleware';
import { authRouter } from './modules/auth/auth.router';
import { ordersRouter } from './modules/orders/orders.router';
import { reportsRouter } from './modules/reports/reports.router';
import { adminRouter } from './modules/admin/admin.router';
import { areasRouter } from './modules/areas/areas.router';

const app = express();
const server = http.createServer(app);

// ── Security & middleware ──────────────────────
app.use(helmet());
app.use(cors({
  origin: process.env.CORS_ORIGINS?.split(',') ?? true, // 'true' mirrors request origin, works with credentials
  credentials: true,
}));
app.use(compression());
app.use(express.json());
app.use(morgan(process.env.NODE_ENV === 'production' ? 'combined' : 'dev'));

// Rate limiting
app.use('/api/auth/login', rateLimit({ windowMs: 15 * 60 * 1000, max: 10, message: { error: 'Too many login attempts' } }));
app.use('/api', rateLimit({ windowMs: 60 * 1000, max: 200 }));

// ── Firebase & Swagger (must register before 404 handler) ─────────────────
initFirebase();
setupSwagger(app);

// ── Routes ────────────────────────────────────
app.use('/api/auth', authRouter);
app.use('/api/orders', ordersRouter);
app.use('/api/reports', reportsRouter);
app.use('/api/admin', adminRouter);
app.use('/api/areas', areasRouter);

// Health check
app.get('/health', (_req, res) => res.json({ status: 'ok', timestamp: new Date().toISOString() }));

// 404 handler
app.use((_req, res) => res.status(404).json({ error: 'Route not found' }));

// Error handler
app.use(errorHandler);

// ── WebSocket ─────────────────────────────────
initWebSocket(server);

// ── Start ─────────────────────────────────────
const PORT = parseInt(process.env.PORT ?? '3000', 10);

async function bootstrap() {

  await prisma.$connect();
  console.log('✅ Database connected');

  server.listen(PORT, () => {
    console.log(`\n🚀 BazZ API running on http://localhost:${PORT}`);
    console.log(`📡 WebSocket on  ws://localhost:${PORT}/ws`);
    console.log(`🏥 Health check: http://localhost:${PORT}/health`);
    console.log(`📚 API docs:     http://localhost:${PORT}/api/docs\n`);
  });
}

bootstrap().catch((err) => {
  console.error('❌ Failed to start server:', err);
  process.exit(1);
});
