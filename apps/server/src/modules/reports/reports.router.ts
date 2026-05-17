import { Router, Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { requireAuth, AuthRequest } from '../../middleware/auth.middleware';
import * as reportsService from './reports.service';

export const reportsRouter = Router();
reportsRouter.use(requireAuth);

const periodSchema = z.object({
  period: z.enum(['today', 'week', 'month', 'year']).default('month'),
});

// GET /reports/summary?period=month
reportsRouter.get('/summary', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const { period } = periodSchema.parse(req.query);
    const data = await reportsService.getSummary(merchantId, period);
    res.json(data);
  } catch (err) { next(err); }
});

// GET /reports/orders-chart?period=month
reportsRouter.get('/orders-chart', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const { period } = periodSchema.parse(req.query);
    const data = await reportsService.getOrdersChart(merchantId, period);
    res.json(data);
  } catch (err) { next(err); }
});

// GET /reports/areas?period=month
reportsRouter.get('/areas', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const { period } = periodSchema.parse(req.query);
    const data = await reportsService.getAreaStats(merchantId, period);
    res.json(data);
  } catch (err) { next(err); }
});

// GET /reports/drivers?period=month
reportsRouter.get('/drivers', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const { period } = periodSchema.parse(req.query);
    const data = await reportsService.getDriverStats(merchantId, period);
    res.json(data);
  } catch (err) { next(err); }
});

// GET /reports/time?period=month
reportsRouter.get('/time', async (req: Request, res: Response, next: NextFunction) => {
  try {
    const merchantId = (req as AuthRequest).merchantId;
    const { period } = periodSchema.parse(req.query);
    const data = await reportsService.getTimeStats(merchantId, period);
    res.json(data);
  } catch (err) { next(err); }
});
