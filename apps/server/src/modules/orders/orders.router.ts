import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { OrderStatus, PackageSize } from '@prisma/client';
import { requireAuth, AuthRequest } from '../../middleware/auth.middleware';
import * as ordersService from './orders.service';

export const ordersRouter = Router();
ordersRouter.use(requireAuth);

const createOrderSchema = z.object({
  recipientName: z.string().min(2),
  recipientPhone: z.string().min(10),
  address: z.string().min(5),
  area: z.string().min(2),
  areaAr: z.string().optional(),
  governorate: z.string().min(2),
  governorateAr: z.string().optional(),
  packageSize: z.nativeEnum(PackageSize).optional(),
  isFragile: z.boolean().optional(),
  isCod: z.boolean().optional(),
  codAmount: z.number().min(0).optional(),
  notes: z.string().optional(),
});

const listOrdersSchema = z.object({
  status: z.nativeEnum(OrderStatus).optional(),
  search: z.string().optional(),
  page: z.coerce.number().int().positive().optional(),
  limit: z.coerce.number().int().positive().optional(),
  from: z.string().optional(),
  to: z.string().optional(),
});

// GET /orders
ordersRouter.get('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const query = listOrdersSchema.parse(req.query);
    const result = await ordersService.listOrders(merchantId, query);
    res.json(result);
  } catch (err) { next(err); }
});

// POST /orders
ordersRouter.post('/', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const dto = createOrderSchema.parse(req.body);
    const order = await ordersService.createOrder(merchantId, dto);
    res.status(201).json(order);
  } catch (err) { next(err); }
});

// GET /orders/:id
ordersRouter.get('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const order = await ordersService.getOrder(merchantId, req.params.id);
    res.json(order);
  } catch (err) { next(err); }
});

// PATCH /orders/:id/status
ordersRouter.patch('/:id/status', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const { status, note } = z.object({
      status: z.nativeEnum(OrderStatus),
      note: z.string().optional(),
    }).parse(req.body);
    const order = await ordersService.updateOrderStatus(merchantId, req.params.id, status, note);
    res.json(order);
  } catch (err) { next(err); }
});

// DELETE /orders/:id  (cancel)
ordersRouter.delete('/:id', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const order = await ordersService.cancelOrder(merchantId, req.params.id);
    res.json(order);
  } catch (err) { next(err); }
});
