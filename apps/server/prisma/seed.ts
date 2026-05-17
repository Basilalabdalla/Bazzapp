import { PrismaClient, OrderStatus, PackageSize } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Create your merchant account
  const yourHash = await bcrypt.hash('1996', 12);
  const merchant = await prisma.merchant.upsert({
    where: { phone: '9961001437' },
    update: { passwordHash: yourHash },
    create: {
      phone: '9961001437',
      name: 'Al Noor Store',
      nameAr: 'متجر النور',
      passwordHash: yourHash,
    },
  });

  // Keep test merchant too
  const passwordHash = await bcrypt.hash('password123', 12);
  await prisma.merchant.upsert({
    where: { phone: '+962791234567' },
    update: {},
    create: {
      phone: '+962791234567',
      name: 'Test Store',
      nameAr: 'متجر تجريبي',
      passwordHash,
    },
  });

  console.log(`✅ Merchant created: ${merchant.name} (${merchant.phone})`);

  // Helper: generate order ID
  let counter = 2390;
  const nextId = () => `#BZ-${++counter}`;

  // Create sample orders
  const orders = [
    {
      orderId: nextId(),
      status: OrderStatus.DELIVERED,
      recipientName: 'Ahmad Hassan',
      recipientPhone: '+962791111111',
      address: 'Abdoun, near 4th circle',
      area: 'Abdoun', areaAr: 'عبدون',
      governorate: 'Amman', governorateAr: 'عمّان',
      packageSize: PackageSize.MEDIUM,
      driverName: 'Mohammed A.', driverNameAr: 'محمد أ.', driverPhone: '+962795550101',
    },
    {
      orderId: nextId(),
      status: OrderStatus.DELIVERED,
      recipientName: 'Sara Ali',
      recipientPhone: '+962792222222',
      address: 'Swefieh, Rainbow Street',
      area: 'Swefieh', areaAr: 'الصويفية',
      governorate: 'Amman', governorateAr: 'عمّان',
      packageSize: PackageSize.SMALL,
      isCod: true, codAmount: 15.5,
      driverName: 'Khalil M.', driverNameAr: 'خليل م.', driverPhone: '+962795550303',
    },
    {
      orderId: nextId(),
      status: OrderStatus.CANCELLED,
      recipientName: 'Fares Jaber',
      recipientPhone: '+962793333333',
      address: 'Irbid City Center',
      area: 'Irbid', areaAr: 'إربد',
      governorate: 'Irbid', governorateAr: 'إربد',
      packageSize: PackageSize.SMALL,
    },
    {
      orderId: nextId(),
      status: OrderStatus.IN_DELIVERY,
      recipientName: 'Omar Khalil',
      recipientPhone: '+962794444444',
      address: 'Zarqa Downtown, Industrial Area',
      area: 'Zarqa Downtown', areaAr: 'وسط الزرقاء',
      governorate: 'Zarqa', governorateAr: 'الزرقاء',
      packageSize: PackageSize.LARGE,
      isFragile: true,
      driverName: 'Ahmad K.', driverNameAr: 'أحمد ك.', driverPhone: '+962795550202',
    },
    {
      orderId: nextId(),
      status: OrderStatus.PENDING,
      recipientName: 'Lina Nasser',
      recipientPhone: '+962795555555',
      address: 'Khalda, University Street',
      area: 'Khalda', areaAr: 'خلدا',
      governorate: 'Amman', governorateAr: 'عمّان',
      packageSize: PackageSize.MEDIUM,
    },
    {
      orderId: nextId(),
      status: OrderStatus.PROCESSING,
      recipientName: 'Nour Haddad',
      recipientPhone: '+962796666666',
      address: 'Aqaba, King Hussein Street',
      area: 'Aqaba', areaAr: 'العقبة',
      governorate: 'Aqaba', governorateAr: 'العقبة',
      packageSize: PackageSize.LARGE,
      isCod: true, codAmount: 32.0,
      notes: 'Leave at door',
    },
  ];

  for (const orderData of orders) {
    const existing = await prisma.order.findUnique({ where: { orderId: orderData.orderId } });
    if (existing) {
      console.log(`  ⏭️  Order ${orderData.orderId} already exists — skipping`);
      continue;
    }
    const order = await prisma.order.create({
      data: { ...orderData, merchantId: merchant.id },
    });
    await prisma.orderStatusHistory.create({
      data: { orderId: order.id, status: order.status },
    });
    console.log(`  📦 Order ${order.orderId} — ${order.status}`);
  }

  console.log('\n🎉 Seed complete!');
  console.log('─────────────────────────────');
  console.log('Test credentials:');
  console.log('  Phone:    +962791234567');
  console.log('  Password: password123');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
