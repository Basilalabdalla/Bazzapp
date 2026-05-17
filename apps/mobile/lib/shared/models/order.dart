enum OrderStatus { pending, inDelivery, delivered, cancelled, processing }

class OrderModel {
  final String id;
  final OrderStatus status;
  final int items;
  final String recipientName;
  final String recipientPhone;
  final String address;
  final String customerName;
  final String customerNameAr;
  final String phone;
  final String area;
  final String areaAr;
  final String governorate;
  final String governorateAr;
  final String date;
  final String dateAr;
  final String createdAt;
  final String packageSize;
  final bool isFragile;
  final bool isCod;
  final double codAmount;
  final DriverInfo? driver;
  final String? notes;

  const OrderModel({
    required this.id,
    required this.status,
    required this.items,
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
    required this.customerName,
    required this.customerNameAr,
    required this.phone,
    required this.area,
    required this.areaAr,
    required this.governorate,
    required this.governorateAr,
    required this.date,
    required this.dateAr,
    required this.createdAt,
    this.packageSize = 'medium',
    this.isFragile = false,
    this.isCod = false,
    this.codAmount = 0,
    this.driver,
    this.notes,
  });
}

class DriverInfo {
  final String name;
  final String nameAr;
  final String initials;
  final String phone;
  final double rating;

  const DriverInfo({
    required this.name,
    required this.nameAr,
    required this.initials,
    required this.phone,
    required this.rating,
  });
}

final List<OrderModel> mockOrders = [
  OrderModel(
    id: '#BZ-2401', status: OrderStatus.inDelivery, items: 3,
    recipientName: 'Ahmad Hassan', recipientPhone: '+962 79 123 4567',
    address: 'Abdoun, Amman — near 4th circle',
    customerName: 'Ahmad Hassan', customerNameAr: 'أحمد حسن',
    phone: '+962791234567', area: 'Abdoun', areaAr: 'عبدون',
    governorate: 'Amman', governorateAr: 'عمّان',
    date: 'Dec 15, 2:30 PM', dateAr: '15 ديس، 2:30 م',
    createdAt: 'Dec 15, 2024 · 2:30 PM',
    driver: const DriverInfo(name: 'Mohammed A.', nameAr: 'محمد أ.', initials: 'MA', phone: '+962 79 555 0101', rating: 4.9),
  ),
  OrderModel(
    id: '#BZ-2402', status: OrderStatus.pending, items: 1,
    recipientName: 'Sara Ali', recipientPhone: '+962 79 123 4568',
    address: 'Swefieh, Amman — Rainbow Street',
    customerName: 'Sara Ali', customerNameAr: 'سارة علي',
    phone: '+962791234568', area: 'Swefieh', areaAr: 'الصويفية',
    governorate: 'Amman', governorateAr: 'عمّان',
    date: 'Dec 15, 1:15 PM', dateAr: '15 ديس، 1:15 م',
    createdAt: 'Dec 15, 2024 · 1:15 PM',
    packageSize: 'small', isCod: true, codAmount: 15.5,
  ),
  OrderModel(
    id: '#BZ-2403', status: OrderStatus.inDelivery, items: 5,
    recipientName: 'Omar Khalil', recipientPhone: '+962 79 123 4569',
    address: 'Zarqa Downtown — Industrial Area',
    customerName: 'Omar Khalil', customerNameAr: 'عمر خليل',
    phone: '+962791234569', area: 'Zarqa Downtown', areaAr: 'وسط الزرقاء',
    governorate: 'Zarqa', governorateAr: 'الزرقاء',
    date: 'Dec 15, 11:00 AM', dateAr: '15 ديس، 11:00 ص',
    createdAt: 'Dec 15, 2024 · 11:00 AM',
    packageSize: 'large', isFragile: true,
    driver: const DriverInfo(name: 'Ahmad K.', nameAr: 'أحمد ك.', initials: 'AK', phone: '+962 79 555 0202', rating: 4.7),
  ),
  OrderModel(
    id: '#BZ-2404', status: OrderStatus.delivered, items: 2,
    recipientName: 'Lina Nasser', recipientPhone: '+962 79 123 4570',
    address: 'Khalda, Amman — University Street',
    customerName: 'Lina Nasser', customerNameAr: 'لينا ناصر',
    phone: '+962791234570', area: 'Khalda', areaAr: 'خلدا',
    governorate: 'Amman', governorateAr: 'عمّان',
    date: 'Dec 15, 10:00 AM', dateAr: '15 ديس، 10:00 ص',
    createdAt: 'Dec 15, 2024 · 10:00 AM',
    driver: const DriverInfo(name: 'Khalil M.', nameAr: 'خليل م.', initials: 'KM', phone: '+962 79 555 0303', rating: 4.6),
  ),
  OrderModel(
    id: '#BZ-2405', status: OrderStatus.cancelled, items: 1,
    recipientName: 'Fares Jaber', recipientPhone: '+962 79 123 4571',
    address: 'Irbid City Center — Al-Yarmouk',
    customerName: 'Fares Jaber', customerNameAr: 'فارس جابر',
    phone: '+962791234571', area: 'Irbid', areaAr: 'إربد',
    governorate: 'Irbid', governorateAr: 'إربد',
    date: 'Dec 14, 3:00 PM', dateAr: '14 ديس، 3:00 م',
    createdAt: 'Dec 14, 2024 · 3:00 PM',
    packageSize: 'small',
  ),
  OrderModel(
    id: '#BZ-2400', status: OrderStatus.processing, items: 4,
    recipientName: 'Nour Haddad', recipientPhone: '+962 79 123 4572',
    address: 'Aqaba — King Hussein Street',
    customerName: 'Nour Haddad', customerNameAr: 'نور حداد',
    phone: '+962791234572', area: 'Aqaba', areaAr: 'العقبة',
    governorate: 'Aqaba', governorateAr: 'العقبة',
    date: 'Dec 14, 9:00 AM', dateAr: '14 ديس، 9:00 ص',
    createdAt: 'Dec 14, 2024 · 9:00 AM',
    packageSize: 'large', isCod: true, codAmount: 32.0,
  ),
];