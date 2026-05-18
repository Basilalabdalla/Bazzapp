import { Router, Request, Response, NextFunction, IRouter } from 'express';
import { z } from 'zod';
import { OrderStatus, UserRole } from '@prisma/client';
import { requireAdmin } from '../../middleware/auth.middleware';
import * as adminService from './admin.service';
import * as authService from '../auth/auth.service';

export const adminRouter: IRouter = Router();

// ── Admin auth (public — no requireAdmin) ──────────────────────────────────

const loginSchema = z.object({
  phone: z.string().min(1),
  password: z.string().min(1),
});

// POST /admin/auth/login  — admin portal only, rejects MERCHANT accounts
adminRouter.post('/auth/login', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { phone, password } = loginSchema.parse(req.body);
    const result = await adminService.adminLogin(phone, password);
    res.json(result);
  } catch (err) { next(err); }
});

// POST /admin/auth/refresh
adminRouter.post('/auth/refresh', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = z.object({ refreshToken: z.string() }).parse(req.body);
    const tokens = await authService.refresh(refreshToken);
    res.json(tokens);
  } catch (err) { next(err); }
});

// POST /admin/auth/logout
adminRouter.post('/auth/logout', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = z.object({ refreshToken: z.string() }).parse(req.body);
    await authService.logout(refreshToken);
    res.json({ message: 'Logged out successfully' });
  } catch (err) { next(err); }
});

// All routes below this point require admin JWT
adminRouter.use(requireAdmin);

// ── Merchants ──────────────────────────────────────────────────────────────

const listMerchantsSchema = z.object({
  search: z.string().optional(),
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  isActive: z.enum(['true', 'false']).transform((v) => v === 'true').optional(),
});

const createMerchantSchema = z.object({
  phone: z.string().min(10),
  name: z.string().min(2),
  nameAr: z.string().optional(),
  password: z.string().min(6),
  role: z.nativeEnum(UserRole).optional(),
});

const updateMerchantSchema = z.object({
  name: z.string().min(2).optional(),
  nameAr: z.string().optional(),
  phone: z.string().min(10).optional(),
});

// GET /admin/merchants
adminRouter.get('/merchants', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = listMerchantsSchema.parse(req.query);
    const result = await adminService.listMerchants(query);
    res.json(result);
  } catch (err) { next(err); }
});

// POST /admin/merchants
adminRouter.post('/merchants', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const dto = createMerchantSchema.parse(req.body);
    const merchant = await adminService.createMerchant(dto);
    res.status(201).json(merchant);
  } catch (err) { next(err); }
});

// PATCH /admin/merchants/:id
adminRouter.patch('/merchants/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const dto = updateMerchantSchema.parse(req.body);
    const merchant = await adminService.updateMerchant(req.params.id, dto);
    res.json(merchant);
  } catch (err) { next(err); }
});

// PATCH /admin/merchants/:id/status
adminRouter.patch('/merchants/:id/status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await adminService.toggleMerchantStatus(req.params.id);
    res.json(result);
  } catch (err) { next(err); }
});

// ── Orders ─────────────────────────────────────────────────────────────────

const adminListOrdersSchema = z.object({
  merchantId: z.string().optional(),
  status: z.nativeEnum(OrderStatus).optional(),
  search: z.string().optional(),
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  from: z.string().optional(),
  to: z.string().optional(),
});

const updateStatusSchema = z.object({
  status: z.nativeEnum(OrderStatus),
  note: z.string().optional(),
});

const assignDriverSchema = z.object({
  driverName: z.string().min(2),
  driverNameAr: z.string().optional(),
  driverPhone: z.string().min(10),
});

// GET /admin/orders
adminRouter.get('/orders', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = adminListOrdersSchema.parse(req.query);
    const result = await adminService.adminListOrders(query);
    res.json(result);
  } catch (err) { next(err); }
});

// GET /admin/orders/:id
adminRouter.get('/orders/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const order = await adminService.adminGetOrder(req.params.id);
    res.json(order);
  } catch (err) { next(err); }
});

// PATCH /admin/orders/:id/status
adminRouter.patch('/orders/:id/status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { status, note } = updateStatusSchema.parse(req.body);
    const order = await adminService.adminUpdateOrderStatus(req.params.id, status, note);
    res.json(order);
  } catch (err) { next(err); }
});

// PATCH /admin/orders/:id/driver
adminRouter.patch('/orders/:id/driver', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const dto = assignDriverSchema.parse(req.body);
    const order = await adminService.adminAssignDriver(req.params.id, dto);
    res.json(order);
  } catch (err) { next(err); }
});

// ── Stats ──────────────────────────────────────────────────────────────────

// GET /admin/stats
adminRouter.get('/stats', async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const stats = await adminService.getPlatformStats();
    res.json(stats);
  } catch (err) { next(err); }
});

// ── Notifications ──────────────────────────────────────────────────────────

const sendNotificationSchema = z.object({
  merchantId: z.string().optional(), // if omitted → broadcast to all active merchants
  title: z.string().min(1).max(100),
  body: z.string().min(1).max(500),
});

// POST /admin/notifications/send
adminRouter.post('/notifications/send', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const dto = sendNotificationSchema.parse(req.body);
    const result = await adminService.sendAdminNotification(dto);
    res.json(result);
  } catch (err) { next(err); }
});
