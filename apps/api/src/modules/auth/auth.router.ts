import { Router, Request, Response, NextFunction, IRouter } from 'express';
import { z } from 'zod';
import bcrypt from 'bcryptjs';
import * as authService from './auth.service';
import { requireAuth, AuthRequest } from '../../middleware/auth.middleware';
import { prisma } from '../../lib/prisma';

export const authRouter: IRouter = Router();

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

// PATCH /auth/profile
authRouter.patch('/profile', requireAuth, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const { name, nameAr } = z.object({
      name: z.string().min(2).optional(),
      nameAr: z.string().optional(),
    }).parse(req.body);

    const merchant = await prisma.merchant.update({
      where: { id: merchantId },
      data: { ...(name && { name }), ...(nameAr !== undefined && { nameAr }) },
      select: { id: true, phone: true, name: true, nameAr: true, role: true },
    });
    res.json(merchant);
  } catch (err) { next(err); }
});

// PATCH /auth/password
authRouter.patch('/password', requireAuth, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const { currentPassword, newPassword } = z.object({
      currentPassword: z.string().min(1),
      newPassword: z.string().min(6),
    }).parse(req.body);

    const merchant = await prisma.merchant.findUniqueOrThrow({ where: { id: merchantId } });
    const valid = await bcrypt.compare(currentPassword, merchant.passwordHash);
    if (!valid) {
      res.status(401).json({ error: 'Current password is incorrect' });
      return;
    }

    const passwordHash = await bcrypt.hash(newPassword, 12);
    await prisma.merchant.update({ where: { id: merchantId }, data: { passwordHash } });
    res.json({ message: 'Password updated successfully' });
  } catch (err) { next(err); }
});

// PATCH /auth/fcm-token
authRouter.patch('/fcm-token', requireAuth, async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const { fcmToken } = z.object({ fcmToken: z.string().min(1) }).parse(req.body);
    await prisma.merchant.update({ where: { id: merchantId }, data: { fcmToken } });
    res.json({ message: 'FCM token registered' });
  } catch (err) { next(err); }
});
