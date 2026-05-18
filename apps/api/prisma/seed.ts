import { PrismaClient, OrderStatus, PackageSize } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  console.log('🌱 Seeding database...');

  // Merchant account — logs in to the mobile app
  const merchantHash = await bcrypt.hash('197555', 12);
  const merchant = await prisma.merchant.upsert({
    where: { phone: '0789900887' },
    update: { passwordHash: merchantHash, role: 'MERCHANT' },
    create: {
      phone: '0789900887',
      name: 'Al Noor Store',
      nameAr: 'متجر النور',
      passwordHash: merchantHash,
      role: 'MERCHANT',
    },
  });

  // Admin account — for the web admin dashboard only
  const adminHash = await bcrypt.hash('197555', 12);
  await prisma.merchant.upsert({
    where: { phone: '0785930123' },
    update: { passwordHash: adminHash },
    create: {
      phone: '0785930123',
      name: 'BazZ Admin',
      nameAr: 'مدير بازز',
      passwordHash: adminHash,
      role: 'ADMIN',
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
  console.log('📱 Merchant app login:');
  console.log('  Phone:    0789900887');
  console.log('  Password: 197555');
  console.log('🖥️  Admin dashboard login:');
  console.log('  Phone:    0785930123');
  console.log('  Password: 197555');
}

main()
  .catch((e) => { console.error(e); process.exit(1); })
  .finally(() => prisma.$disconnect());
