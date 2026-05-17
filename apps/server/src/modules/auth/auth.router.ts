import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import * as authService from './auth.service';
import { requireAuth, AuthRequest } from '../../middleware/auth.middleware';
import { prisma } from '../../lib/prisma';

export const authRouter = Router();

const loginSchema = z.object({
  phone: z.string().min(1),
  password: z.string().min(1),
});

const refreshSchema = z.object({
  refreshToken: z.string(),
});

// POST /auth/login
authRouter.post('/login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { phone, password } = loginSchema.parse(req.body);
    const result = await authService.login(phone, password);
    res.json(result);
  } catch (err) {
    next(err);
  }
});

// POST /auth/refresh
authRouter.post('/refresh', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = refreshSchema.parse(req.body);
    const tokens = await authService.refresh(refreshToken);
    res.json(tokens);
  } catch (err) {
    next(err);
  }
});

// POST /auth/logout
authRouter.post('/logout', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = refreshSchema.parse(req.body);
    await authService.logout(refreshToken);
    res.json({ message: 'Logged out successfully' });
  } catch (err) {
    next(err);
  }
});

// GET /auth/me
authRouter.get('/me', requireAuth, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const merchant = await prisma.merchant.findUniqueOrThrow({
      where: { id: merchantId },
      select: { id: true, phone: true, name: true, nameAr: true, role: true, createdAt: true },
    });
    res.json(merchant);
  } catch (err) {
    next(err);
  }
});
