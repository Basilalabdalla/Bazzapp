import { PrismaClient } from '@prisma/client';
import bcrypt from 'bcryptjs';

const prisma = new PrismaClient();

async function main() {
  const hash = await bcrypt.hash('197555', 12);

  const admin = await prisma.merchant.upsert({
    where: { phone: '0785930123' },
    update: {
      passwordHash: hash,
      role: 'ADMIN',
      isActive: true,
    },
    create: {
      phone: '0785930123',
      name: 'BazZ Admin',
      nameAr: 'مدير بازز',
      passwordHash: hash,
      role: 'ADMIN',
    },
  });

  console.log(`✅ Admin account ready`);
  console.log(`   Phone:    ${admin.phone}`);
  console.log(`   Role:     ${admin.role}`);
  console.log(`   Active:   ${admin.isActive}`);
  console.log(`   Password: 197555`);
}

main()
  .catch((e) => { console.error('❌', e.message); process.exit(1); })
  .finally(() => prisma.$disconnect());
