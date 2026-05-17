import { OrderStatus, PackageSize } from '@prisma/client';
import { prisma } from '../../lib/prisma';
import { AppError } from '../../middleware/error.middleware';
import { broadcastOrderUpdate } from '../../lib/websocket';

let orderCounter = 0;

async function getNextOrderId(): Promise<string> {
  if (orderCounter === 0) {
    const latest = await prisma.order.findFirst({ orderBy: { createdAt: 'desc' } });
    const match = latest?.orderId.match(/#BZ-(\d+)/);
    orderCounter = match ? parseInt(match[1]) : 2400;
  }
  return `#BZ-${++orderCounter}`;
}

export interface CreateOrderDto {
  recipientName: string;
  recipientPhone: string;
  address: string;
  area: string;
  areaAr?: string;
  governorate: string;
  governorateAr?: string;
  packageSize?: PackageSize;
  isFragile?: boolean;
  isCod?: boolean;
  codAmount?: number;
  notes?: string;
}

export interface ListOrdersDto {
  status?: OrderStatus;
  search?: string;
  page?: number;
  limit?: number;
  from?: string;
  to?: string;
}

export async function createOrder(merchantId: string, dto: CreateOrderDto) {
  const orderId = await getNextOrderId();
  const order = await prisma.order.create({
    data: {
      orderId,
      merchantId,
      ...dto,
      packageSize: dto.packageSize ?? PackageSize.MEDIUM,
      status: OrderStatus.PENDING,
    },
    include: { statusHistory: true },
  });

  await prisma.orderStatusHistory.create({
    data: { orderId: order.id, status: OrderStatus.PENDING, note: 'Order created' },
  });

  broadcastOrderUpdate(merchantId, order);
  return order;
}

export async function listOrders(merchantId: string, dto: ListOrdersDto) {
  const page = dto.page ?? 1;
  const limit = Math.min(dto.limit ?? 20, 100);
  const skip = (page - 1) * limit;

  const where = {
    merchantId,
    ...(dto.status && { status: dto.status }),
    ...(dto.from || dto.to
      ? {
          createdAt: {
            ...(dto.from && { gte: new Date(dto.from) }),
            ...(dto.to && { lte: new Date(dto.to) }),
          },
        }
      : {}),
    ...(dto.search && {
      OR: [
        { orderId: { contains: dto.search, mode: 'insensitive' as const } },
        { recipientName: { contains: dto.search, mode: 'insensitive' as const } },
        { area: { contains: dto.search, mode: 'insensitive' as const } },
      ],
    }),
  };

  const [orders, total] = await prisma.$transaction([
    prisma.order.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
      include: { statusHistory: { orderBy: { createdAt: 'asc' } } },
    }),
    prisma.order.count({ where }),
  ]);

  return {
    data: orders,
    meta: { page, limit, total, totalPages: Math.ceil(total / limit) },
  };
}

export async function getOrder(merchantId: string, id: string) {
  const order = await prisma.order.findFirst({
    where: { OR: [{ id }, { orderId: id }], merchantId },
    include: { statusHistory: { orderBy: { createdAt: 'asc' } } },
  });
  if (!order) throw new AppError(404, 'Order not found');
  return order;
}

export async function updateOrderStatus(
  merchantId: string,
  id: string,
  status: OrderStatus,
  note?: string,
) {
  const order = await getOrder(merchantId, id);

  const updated = await prisma.order.update({
    where: { id: order.id },
    data: { status },
    include: { statusHistory: { orderBy: { createdAt: 'asc' } } },
  });

  await prisma.orderStatusHistory.create({
    data: { orderId: order.id, status, note },
  });

  broadcastOrderUpdate(merchantId, updated);
  return updated;
}

export async function cancelOrder(merchantId: string, id: string) {
  const order = await getOrder(merchantId, id);
  const nonCancellable: OrderStatus[] = [OrderStatus.DELIVERED, OrderStatus.CANCELLED];
  if (nonCancellable.includes(order.status)) {
    throw new AppError(400, `Cannot cancel an order with status ${order.status}`);
  }
  return updateOrderStatus(merchantId, id, OrderStatus.CANCELLED, 'Cancelled by merchant');
}
