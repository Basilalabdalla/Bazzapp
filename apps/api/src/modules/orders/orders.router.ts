import { Router, Request, Response, NextFunction, IRouter } from 'express';
import { z } from 'zod';
import { OrderStatus, PackageSize } from '@prisma/client';
import { requireAuth, AuthRequest } from '../../middleware/auth.middleware';
import * as ordersService from './orders.service';
import { prisma } from '../../lib/prisma';

export const ordersRouter: IRouter = Router();

// ─── PUBLIC: order tracking (no auth required) ───────────────────────────────
// GET /orders/track/:ref  →  returns limited public info for a given orderId
ordersRouter.get('/track/:ref', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const ref = decodeURIComponent(req.params.ref).toUpperCase().trim();

    // Accept both "BZ-1234" and "#BZ-1234" from the customer
    const normalised = ref.startsWith('#') ? ref : `#${ref}`;

    const order = await prisma.order.findFirst({
      where: { orderId: normalised },
      select: {
        orderId: true,
        status: true,
        area: true,
        areaAr: true,
        governorate: true,
        governorateAr: true,
        driverName: true,
        driverNameAr: true,
        createdAt: true,
        updatedAt: true,
        statusHistory: {
          orderBy: { createdAt: 'asc' },
          select: { status: true, note: true, createdAt: true },
        },
      },
    });

    if (!order) {
      res.status(404).json({ error: 'Order not found' });
      return;
    }

    res.json(order);
  } catch (err) { next(err); }
});

// ─── AUTHENTICATED routes ─────────────────────────────────────────────────────
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
