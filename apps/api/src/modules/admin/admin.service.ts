import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { OrderStatus, UserRole } from '@prisma/client';
import { prisma } from '../../lib/prisma';
import { AppError } from '../../middleware/error.middleware';
import { broadcastOrderUpdate } from '../../lib/websocket';
import { sendPushNotification } from '../../lib/firebase';

const STATUS_LABELS: Record<OrderStatus, string> = {
  PENDING: 'Pending',
  PROCESSING: 'Processing',
  IN_DELIVERY: 'Out for Delivery',
  DELIVERED: 'Delivered',
  CANCELLED: 'Cancelled',
};

const REFRESH_EXPIRES_DAYS = 30;

// ── Admin Auth ─────────────────────────────────────────────────────────────

export async function adminLogin(phone: string, password: string) {
  const merchant = await prisma.merchant.findUnique({ where: { phone } });
  if (!merchant || !merchant.isActive) throw new AppError(401, 'Invalid credentials');

  // Only ADMIN accounts can log in here — block merchants
  if (merchant.role !== 'ADMIN') throw new AppError(403, 'Access denied');

  const valid = await bcrypt.compare(password, merchant.passwordHash);
  if (!valid) throw new AppError(401, 'Invalid credentials');

  const tokenId = uuidv4();
  const accessToken = jwt.sign({ sub: merchant.id }, process.env.JWT_SECRET!, {
    expiresIn: process.env.JWT_EXPIRES_IN ?? '15m',
  } as jwt.SignOptions);
  const refreshToken = jwt.sign({ sub: merchant.id, jti: tokenId }, process.env.REFRESH_TOKEN_SECRET!, {
    expiresIn: `${REFRESH_EXPIRES_DAYS}d`,
  } as jwt.SignOptions);

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + REFRESH_EXPIRES_DAYS);
  await prisma.refreshToken.create({ data: { token: tokenId, merchantId: merchant.id, expiresAt } });

  return {
    accessToken,
    refreshToken,
    admin: { id: merchant.id, phone: merchant.phone, name: merchant.name, role: merchant.role },
  };
}

// ── Merchant Management ────────────────────────────────────────────────────

export interface ListMerchantsDto {
  search?: string;
  page?: number;
  limit?: number;
  isActive?: boolean;
}

export async function listMerchants(dto: ListMerchantsDto) {
  const page = dto.page ?? 1;
  const limit = Math.min(dto.limit ?? 20, 100);
  const skip = (page - 1) * limit;

  const where = {
    ...(dto.isActive !== undefined && { isActive: dto.isActive }),
    ...(dto.search && {
      OR: [
        { name: { contains: dto.search, mode: 'insensitive' as const } },
        { phone: { contains: dto.search, mode: 'insensitive' as const } },
      ],
    }),
  };

  const [merchants, total] = await prisma.$transaction([
    prisma.merchant.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
      select: {
        id: true,
        phone: true,
        name: true,
        nameAr: true,
        role: true,
        isActive: true,
        createdAt: true,
        _count: { select: { orders: true } },
      },
    }),
    prisma.merchant.count({ where }),
  ]);

  return { data: merchants, meta: { page, limit, total, totalPages: Math.ceil(total / limit) } };
}

export interface CreateMerchantDto {
  phone: string;
  name: string;
  nameAr?: string;
  password: string;
  role?: UserRole;
}

export async function createMerchant(dto: CreateMerchantDto) {
  const existing = await prisma.merchant.findUnique({ where: { phone: dto.phone } });
  if (existing) throw new AppError(409, 'A merchant with this phone already exists');

  const passwordHash = await bcrypt.hash(dto.password, 12);
  return prisma.merchant.create({
    data: {
      phone: dto.phone,
      name: dto.name,
      nameAr: dto.nameAr,
      passwordHash,
      role: dto.role ?? UserRole.MERCHANT,
    },
    select: { id: true, phone: true, name: true, nameAr: true, role: true, isActive: true, createdAt: true },
  });
}

export interface UpdateMerchantDto {
  name?: string;
  nameAr?: string;
  phone?: string;
}

export async function updateMerchant(id: string, dto: UpdateMerchantDto) {
  const merchant = await prisma.merchant.findUnique({ where: { id } });
  if (!merchant) throw new AppError(404, 'Merchant not found');

  if (dto.phone && dto.phone !== merchant.phone) {
    const existing = await prisma.merchant.findUnique({ where: { phone: dto.phone } });
    if (existing) throw new AppError(409, 'Phone already in use by another merchant');
  }

  return prisma.merchant.update({
    where: { id },
    data: dto,
    select: { id: true, phone: true, name: true, nameAr: true, role: true, isActive: true, updatedAt: true },
  });
}

export async function toggleMerchantStatus(id: string) {
  const merchant = await prisma.merchant.findUnique({ where: { id } });
  if (!merchant) throw new AppError(404, 'Merchant not found');

  return prisma.merchant.update({
    where: { id },
    data: { isActive: !merchant.isActive },
    select: { id: true, name: true, isActive: true },
  });
}

// ── Order Management ───────────────────────────────────────────────────────

export interface AdminListOrdersDto {
  merchantId?: string;
  status?: OrderStatus;
  search?: string;
  page?: number;
  limit?: number;
  from?: string;
  to?: string;
}

export async function adminListOrders(dto: AdminListOrdersDto) {
  const page = dto.page ?? 1;
  const limit = Math.min(dto.limit ?? 20, 100);
  const skip = (page - 1) * limit;

  const where = {
    ...(dto.merchantId && { merchantId: dto.merchantId }),
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
        { merchant: { name: { contains: dto.search, mode: 'insensitive' as const } } },
      ],
    }),
  };

  const [orders, total] = await prisma.$transaction([
    prisma.order.findMany({
      where,
      orderBy: { createdAt: 'desc' },
      skip,
      take: limit,
      include: {
        merchant: { select: { id: true, name: true, phone: true } },
        statusHistory: { orderBy: { createdAt: 'asc' } },
      },
    }),
    prisma.order.count({ where }),
  ]);

  return { data: orders, meta: { page, limit, total, totalPages: Math.ceil(total / limit) } };
}

export async function adminGetOrder(id: string) {
  const order = await prisma.order.findFirst({
    where: { OR: [{ id }, { orderId: id }] },
    include: {
      merchant: { select: { id: true, name: true, phone: true } },
      statusHistory: { orderBy: { createdAt: 'asc' } },
    },
  });
  if (!order) throw new AppError(404, 'Order not found');
  return order;
}

export async function adminUpdateOrderStatus(id: string, status: OrderStatus, note?: string) {
  const order = await adminGetOrder(id);

  const updated = await prisma.order.update({
    where: { id: order.id },
    data: { status },
    include: {
      merchant: { select: { id: true, name: true, phone: true } },
      statusHistory: { orderBy: { createdAt: 'asc' } },
    },
  });

  await prisma.orderStatusHistory.create({
    data: { orderId: order.id, status, note },
  });

  broadcastOrderUpdate(order.merchantId, updated);

  const merchant = await prisma.merchant.findUnique({ where: { id: order.merchantId }, select: { fcmToken: true } });
  if (merchant?.fcmToken) {
    await sendPushNotification(
      merchant.fcmToken,
      'Order Updated',
      `${order.orderId} is now ${STATUS_LABELS[status]}`,
      { orderId: order.id, status },
    );
  }

  return updated;
}

export interface AssignDriverDto {
  driverName: string;
  driverNameAr?: string;
  driverPhone: string;
}

export async function adminAssignDriver(id: string, dto: AssignDriverDto) {
  const order = await adminGetOrder(id);

  const updated = await prisma.order.update({
    where: { id: order.id },
    data: {
      driverName: dto.driverName,
      driverNameAr: dto.driverNameAr,
      driverPhone: dto.driverPhone,
      status: order.status === OrderStatus.PENDING ? OrderStatus.PROCESSING : order.status,
    },
    include: {
      merchant: { select: { id: true, name: true, phone: true } },
      statusHistory: { orderBy: { createdAt: 'asc' } },
    },
  });

  if (order.status === OrderStatus.PENDING) {
    await prisma.orderStatusHistory.create({
      data: { orderId: order.id, status: OrderStatus.PROCESSING, note: `Driver assigned: ${dto.driverName}` },
    });
  }

  broadcastOrderUpdate(order.merchantId, updated);

  const merchant2 = await prisma.merchant.findUnique({ where: { id: order.merchantId }, select: { fcmToken: true } });
  if (merchant2?.fcmToken) {
    await sendPushNotification(
      merchant2.fcmToken,
      'Driver Assigned',
      `${order.orderId} has been assigned to ${dto.driverName}`,
      { orderId: order.id, status: updated.status },
    );
  }

  return updated;
}

// ── Push Notifications ─────────────────────────────────────────────────────

export interface SendNotificationDto {
  merchantId?: string;
  title: string;
  body: string;
}

export async function sendAdminNotification(dto: SendNotificationDto) {
  const { merchantId, title, body } = dto;

  if (merchantId) {
    // Single merchant
    const merchant = await prisma.merchant.findUnique({
      where: { id: merchantId },
      select: { id: true, name: true, fcmToken: true, isActive: true },
    });
    if (!merchant) throw new AppError(404, 'Merchant not found');
    if (!merchant.fcmToken) {
      return { sent: 0, skipped: 1, reason: 'Merchant has no FCM token registered' };
    }
    await sendPushNotification(merchant.fcmToken, title, body, { type: 'admin_broadcast' });
    return { sent: 1, skipped: 0, recipients: [{ id: merchant.id, name: merchant.name }] };
  }

  // Broadcast to all active merchants with an FCM token
  const merchants = await prisma.merchant.findMany({
    where: { role: 'MERCHANT', isActive: true, fcmToken: { not: null } },
    select: { id: true, name: true, fcmToken: true },
  });

  let sent = 0;
  const failed: string[] = [];

  await Promise.allSettled(
    merchants.map(async (m) => {
      try {
        await sendPushNotification(m.fcmToken!, title, body, { type: 'admin_broadcast' });
        sent++;
      } catch {
        failed.push(m.id);
      }
    }),
  );

  return {
    sent,
    skipped: merchants.length - sent,
    total: merchants.length,
    failed: failed.length > 0 ? failed : undefined,
  };
}

// ── Platform Stats ─────────────────────────────────────────────────────────

export async function getPlatformStats() {
  const todayStart = new Date();
  todayStart.setHours(0, 0, 0, 0);

  const [
    totalMerchants,
    activeMerchants,
    totalOrders,
    todayOrders,
    pending,
    processing,
    inDelivery,
    delivered,
    cancelled,
    codResult,
  ] = await prisma.$transaction([
    prisma.merchant.count({ where: { role: 'MERCHANT' } }),
    prisma.merchant.count({ where: { role: 'MERCHANT', isActive: true } }),
    prisma.order.count(),
    prisma.order.count({ where: { createdAt: { gte: todayStart } } }),
    prisma.order.count({ where: { status: OrderStatus.PENDING } }),
    prisma.order.count({ where: { status: OrderStatus.PROCESSING } }),
    prisma.order.count({ where: { status: OrderStatus.IN_DELIVERY } }),
    prisma.order.count({ where: { status: OrderStatus.DELIVERED } }),
    prisma.order.count({ where: { status: OrderStatus.CANCELLED } }),
    prisma.order.aggregate({ _sum: { codAmount: true }, where: { isCod: true, status: OrderStatus.DELIVERED } }),
  ]);

  return {
    merchants: { total: totalMerchants, active: activeMerchants },
    orders: { total: totalOrders, today: todayOrders, pending, processing, inDelivery, delivered, cancelled },
    cod: { totalCollected: codResult._sum.codAmount ?? 0 },
  };
}
