import { OrderStatus } from '@prisma/client';
import { prisma } from '../../lib/prisma';

export type Period = 'today' | 'week' | 'month' | 'year';

function getDateRange(period: Period) {
  const now = new Date();
  const from = new Date();
  if (period === 'today') { from.setHours(0, 0, 0, 0); }
  else if (period === 'week') { from.setDate(now.getDate() - 7); }
  else if (period === 'month') { from.setMonth(now.getMonth() - 1); }
  else { from.setFullYear(now.getFullYear() - 1); }
  return { from, to: now };
}

export async function getSummary(merchantId: string, period: Period) {
  const { from, to } = getDateRange(period);

  const [total, delivered, pending, cancelled, processing, inDelivery] =
    await prisma.$transaction([
      prisma.order.count({ where: { merchantId, createdAt: { gte: from, lte: to } } }),
      prisma.order.count({ where: { merchantId, status: OrderStatus.DELIVERED, createdAt: { gte: from, lte: to } } }),
      prisma.order.count({ where: { merchantId, status: OrderStatus.PENDING, createdAt: { gte: from, lte: to } } }),
      prisma.order.count({ where: { merchantId, status: OrderStatus.CANCELLED, createdAt: { gte: from, lte: to } } }),
      prisma.order.count({ where: { merchantId, status: OrderStatus.PROCESSING, createdAt: { gte: from, lte: to } } }),
      prisma.order.count({ where: { merchantId, status: OrderStatus.IN_DELIVERY, createdAt: { gte: from, lte: to } } }),
    ]);

  const successRate = total > 0 ? Math.round((delivered / total) * 100) : 0;

  return { total, delivered, pending, cancelled, processing, inDelivery, successRate, period, from, to };
}

export async function getOrdersChart(merchantId: string, period: Period) {
  const { from, to } = getDateRange(period);
  const orders = await prisma.order.findMany({
    where: { merchantId, createdAt: { gte: from, lte: to } },
    select: { createdAt: true, status: true },
    orderBy: { createdAt: 'asc' },
  });

  // Group by date label
  const map = new Map<string, { delivered: number; cancelled: number; total: number }>();
  for (const o of orders) {
    const key = o.createdAt.toISOString().slice(0, 10);
    const existing = map.get(key) ?? { delivered: 0, cancelled: 0, total: 0 };
    existing.total++;
    if (o.status === OrderStatus.DELIVERED) existing.delivered++;
    if (o.status === OrderStatus.CANCELLED) existing.cancelled++;
    map.set(key, existing);
  }

  return Array.from(map.entries()).map(([date, counts]) => ({ date, ...counts }));
}

export async function getAreaStats(merchantId: string, period: Period) {
  const { from, to } = getDateRange(period);
  const orders = await prisma.order.groupBy({
    by: ['governorate'],
    where: { merchantId, createdAt: { gte: from, lte: to } },
    _count: { id: true },
    orderBy: { _count: { id: 'desc' } },
  });

  return orders.map((r) => ({ governorate: r.governorate, count: r._count.id }));
}

export async function getDriverStats(merchantId: string, period: Period) {
  const { from, to } = getDateRange(period);
  const orders = await prisma.order.groupBy({
    by: ['driverName'],
    where: {
      merchantId,
      driverName: { not: null },
      createdAt: { gte: from, lte: to },
    },
    _count: { id: true },
    orderBy: { _count: { id: 'desc' } },
  });

  return orders
    .filter((r) => r.driverName)
    .map((r) => ({ driver: r.driverName!, count: r._count.id }));
}

export async function getTimeStats(merchantId: string, period: Period) {
  const { from, to } = getDateRange(period);
  const orders = await prisma.order.findMany({
    where: { merchantId, createdAt: { gte: from, lte: to } },
    select: { createdAt: true },
  });

  const hours = Array.from({ length: 24 }, (_, i) => ({ hour: i, count: 0 }));
  for (const o of orders) {
    hours[o.createdAt.getHours()].count++;
  }
  return hours;
}
