import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { v4 as uuidv4 } from 'uuid';
import { prisma } from '../../lib/prisma';
import { AppError } from '../../middleware/error.middleware';

const JWT_SECRET = () => process.env.JWT_SECRET!;
const REFRESH_SECRET = () => process.env.REFRESH_TOKEN_SECRET!;
const JWT_EXPIRES = process.env.JWT_EXPIRES_IN ?? '15m';
const REFRESH_EXPIRES_DAYS = 30;

function signAccess(merchantId: string) {
  return jwt.sign({ sub: merchantId }, JWT_SECRET(), { expiresIn: JWT_EXPIRES } as jwt.SignOptions);
}

function signRefresh(merchantId: string, tokenId: string) {
  return jwt.sign({ sub: merchantId, jti: tokenId }, REFRESH_SECRET(), {
    expiresIn: `${REFRESH_EXPIRES_DAYS}d`,
  } as jwt.SignOptions);
}

export async function login(phone: string, password: string) {
  const merchant = await prisma.merchant.findUnique({ where: { phone } });
  if (!merchant || !merchant.isActive) throw new AppError(401, 'Invalid credentials');

  // Admin accounts are blocked from the merchant app — use the admin portal
  if (merchant.role === 'ADMIN') throw new AppError(403, 'Please use the admin portal to log in');

  const valid = await bcrypt.compare(password, merchant.passwordHash);
  if (!valid) throw new AppError(401, 'Invalid credentials');

  const tokenId = uuidv4();
  const accessToken = signAccess(merchant.id);
  const refreshToken = signRefresh(merchant.id, tokenId);

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + REFRESH_EXPIRES_DAYS);

  await prisma.refreshToken.create({
    data: { token: tokenId, merchantId: merchant.id, expiresAt },
  });

  return {
    accessToken,
    refreshToken,
    merchant: {
      id: merchant.id,
      phone: merchant.phone,
      name: merchant.name,
      nameAr: merchant.nameAr,
      role: merchant.role,
    },
  };
}

export async function refresh(refreshToken: string) {
  let payload: { sub: string; jti: string };
  try {
    payload = jwt.verify(refreshToken, REFRESH_SECRET()) as typeof payload;
  } catch {
    throw new AppError(401, 'Invalid or expired refresh token');
  }

  const stored = await prisma.refreshToken.findUnique({ where: { token: payload.jti } });
  if (!stored || stored.merchantId !== payload.sub || stored.expiresAt < new Date()) {
    throw new AppError(401, 'Refresh token revoked or expired');
  }

  // Rotate refresh token
  const newTokenId = uuidv4();
  const newAccessToken = signAccess(payload.sub);
  const newRefreshToken = signRefresh(payload.sub, newTokenId);

  const expiresAt = new Date();
  expiresAt.setDate(expiresAt.getDate() + REFRESH_EXPIRES_DAYS);

  await prisma.$transaction([
    prisma.refreshToken.delete({ where: { token: payload.jti } }),
    prisma.refreshToken.create({
      data: { token: newTokenId, merchantId: payload.sub, expiresAt },
    }),
  ]);

  return { accessToken: newAccessToken, refreshToken: newRefreshToken };
}

export async function logout(refreshToken: string) {
  try {
    const payload = jwt.verify(refreshToken, REFRESH_SECRET()) as { jti: string };
    await prisma.refreshToken.deleteMany({ where: { token: payload.jti } });
  } catch {
    // Token already invalid — that's fine
  }
}
