export type OrderStatus = 'PENDING' | 'PROCESSING' | 'IN_DELIVERY' | 'DELIVERED' | 'CANCELLED';
export type PackageSize = 'SMALL' | 'MEDIUM' | 'LARGE';
export type UserRole = 'MERCHANT' | 'ADMIN';

export interface Admin {
  id: string;
  phone: string;
  name: string;
  role: UserRole;
}

export interface Merchant {
  id: string;
  phone: string;
  name: string;
  nameAr?: string;
  role: UserRole;
  isActive: boolean;
  createdAt: string;
  _count?: { orders: number };
}

export interface StatusHistory {
  id: string;
  status: OrderStatus;
  note?: string;
  createdAt: string;
}

export interface Order {
  id: string;
  orderId: string;
  merchantId: string;
  merchant?: { id: string; name: string; phone: string };
  recipientName: string;
  recipientPhone: string;
  address: string;
  area: string;
  areaAr?: string;
  governorate: string;
  governorateAr?: string;
  packageSize: PackageSize;
  isFragile: boolean;
  isCod: boolean;
  codAmount: number;
  notes?: string;
  status: OrderStatus;
  driverName?: string;
  driverNameAr?: string;
  driverPhone?: string;
  statusHistory: StatusHistory[];
  createdAt: string;
  updatedAt: string;
}

export interface PaginatedResponse<T> {
  data: T[];
  meta: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}

export interface PlatformStats {
  merchants: { total: number; active: number };
  orders: {
    total: number;
    today: number;
    pending: number;
    processing: number;
    inDelivery: number;
    delivered: number;
    cancelled: number;
  };
  cod: { totalCollected: number };
}
