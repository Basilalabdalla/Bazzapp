import 'api_client.dart';

enum OrderStatus { pending, processing, inDelivery, delivered, cancelled }

extension OrderStatusX on OrderStatus {
  String get apiValue => switch (this) {
        OrderStatus.pending => 'PENDING',
        OrderStatus.processing => 'PROCESSING',
        OrderStatus.inDelivery => 'IN_DELIVERY',
        OrderStatus.delivered => 'DELIVERED',
        OrderStatus.cancelled => 'CANCELLED',
      };

  static OrderStatus fromApi(String s) => switch (s) {
        'PENDING' => OrderStatus.pending,
        'PROCESSING' => OrderStatus.processing,
        'IN_DELIVERY' => OrderStatus.inDelivery,
        'DELIVERED' => OrderStatus.delivered,
        'CANCELLED' => OrderStatus.cancelled,
        _ => OrderStatus.pending,
      };

  String label(bool isAr) => switch (this) {
        OrderStatus.pending => isAr ? 'قيد الانتظار' : 'Pending',
        OrderStatus.processing => isAr ? 'قيد المعالجة' : 'Processing',
        OrderStatus.inDelivery => isAr ? 'في الطريق' : 'In Delivery',
        OrderStatus.delivered => isAr ? 'تم التوصيل' : 'Delivered',
        OrderStatus.cancelled => isAr ? 'ملغي' : 'Cancelled',
      };
}

class Order {
  final String id;
  final String orderId;
  final String recipientName;
  final String recipientPhone;
  final String address;
  final String area;
  final String? areaAr;
  final String governorate;
  final String? governorateAr;
  final OrderStatus status;
  final String? driverName;
  final String? driverNameAr;
  final String? driverPhone;
  final bool isCod;
  final double codAmount;
  final bool isFragile;
  final String? notes;
  final DateTime createdAt;

  const Order({
    required this.id,
    required this.orderId,
    required this.recipientName,
    required this.recipientPhone,
    required this.address,
    required this.area,
    this.areaAr,
    required this.governorate,
    this.governorateAr,
    required this.status,
    this.driverName,
    this.driverNameAr,
    this.driverPhone,
    required this.isCod,
    required this.codAmount,
    required this.isFragile,
    this.notes,
    required this.createdAt,
  });

  factory Order.fromJson(Map<String, dynamic> j) => Order(
        id: j['id'] as String,
        orderId: j['orderId'] as String,
        recipientName: j['recipientName'] as String,
        recipientPhone: j['recipientPhone'] as String,
        address: j['address'] as String,
        area: j['area'] as String,
        areaAr: j['areaAr'] as String?,
        governorate: j['governorate'] as String,
        governorateAr: j['governorateAr'] as String?,
        status: OrderStatusX.fromApi(j['status'] as String),
        driverName: j['driverName'] as String?,
        driverNameAr: j['driverNameAr'] as String?,
        driverPhone: j['driverPhone'] as String?,
        isCod: j['isCod'] as bool? ?? false,
        codAmount: (j['codAmount'] as num?)?.toDouble() ?? 0,
        isFragile: j['isFragile'] as bool? ?? false,
        notes: j['notes'] as String?,
        createdAt: DateTime.parse(j['createdAt'] as String),
      );
}

class OrdersResult {
  final List<Order> data;
  final int total;
  final int page;
  final int totalPages;

  const OrdersResult({
    required this.data,
    required this.total,
    required this.page,
    required this.totalPages,
  });
}

class OrdersService {
  OrdersService._();
  static final OrdersService instance = OrdersService._();

  final _api = ApiClient.instance;

  Future<OrdersResult> listOrders({
    OrderStatus? status,
    String? search,
    int page = 1,
    int limit = 20,
  }) async {
    final params = <String, String>{
      'page': '$page',
      'limit': '$limit',
      if (status != null) 'status': status.apiValue,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final query = params.entries.map((e) => '${e.key}=${e.value}').join('&');
    final res = await _api.get('/orders?$query');
    final list = (res['data'] as List).map((e) => Order.fromJson(e as Map<String, dynamic>)).toList();
    final meta = res['meta'] as Map<String, dynamic>;
    return OrdersResult(
      data: list,
      total: meta['total'] as int,
      page: meta['page'] as int,
      totalPages: meta['totalPages'] as int,
    );
  }

  Future<Order> getOrder(String id) async {
    final res = await _api.get('/orders/$id');
    return Order.fromJson(res);
  }

  Future<Order> createOrder(Map<String, dynamic> dto) async {
    final res = await _api.post('/orders', dto);
    return Order.fromJson(res);
  }

  Future<Order> cancelOrder(String id) async {
    final res = await _api.delete('/orders/$id');
    return Order.fromJson(res);
  }
}
