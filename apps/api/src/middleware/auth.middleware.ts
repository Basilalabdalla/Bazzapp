import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { prisma } from '../lib/prisma';

export interface AuthRequest extends Request {
  merchantId: string;
}

export function requireAuth(req: Request, res: Response, next: NextFunction) {
  const header = req.headers.authorization;
  if (!header?.startsWith('Bearer ')) {
    res.status(401).json({ error: 'Missing or invalid Authorization header' });
    return;
  }

  const token = header.slice(7);
  try {
    const payload = jwt.verify(token, process.env.JWT_SECRET!) as { sub: string };
    (req as AuthRequest).merchantId = payload.sub;
    next();
  } catch (err) {
    if (err instanceof jwt.TokenExpiredError) {
      res.status(401).json({ error: 'Token expired' });
    } else {
      res.status(401).json({ error: 'Invalid token' });
    }
  }
}

export function requireAdmin(req: Request, res: Response, next: NextFunction) {
  requireAuth(req, res, async () => {
    try {
      const merchant = await prisma.merchant.findUnique({
        where: { id: (req as AuthRequest).merchantId },
        select: { role: true, isActive: true },
      });
      if (!merchant || !merchant.isActive || merchant.role !== 'ADMIN') {
        res.status(403).json({ error: 'Admin access required' });
        return;
      }
      next();
    } catch {
      res.status(500).json({ error: 'Internal server error' });
    }
  });
}
