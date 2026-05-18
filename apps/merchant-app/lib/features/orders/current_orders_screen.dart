import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/orders_service.dart';
import '../../theme/colors.dart';

class CurrentOrdersScreen extends StatefulWidget {
  const CurrentOrdersScreen({super.key});

  @override
  State<CurrentOrdersScreen> createState() => _CurrentOrdersScreenState();
}

class _CurrentOrdersScreenState extends State<CurrentOrdersScreen> {
  OrderStatus? _statusFilter;
  String _search = '';
  late Future<OrdersResult> _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = OrdersService.instance.listOrders(
      status: _statusFilter,
      search: _search,
      limit: 50,
    );
  }

  void _refresh() => setState(_load);

  Future<void> _cancel(Order order, bool isAr) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(isAr ? 'تأكيد الإلغاء' : 'Cancel Order'),
        content: Text(isAr
            ? 'هل تريد إلغاء الطلب ${order.orderId}؟'
            : 'Cancel order ${order.orderId}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(isAr ? 'لا' : 'No'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: BazzColors.error),
            child: Text(isAr ? 'نعم، إلغاء' : 'Yes, Cancel'),
          ),
        ],
      ),
    );
    if (confirm != true || !mounted) return;
    try {
      await OrdersService.instance.cancelOrder(order.id);
      _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isAr ? 'تم إلغاء الطلب' : 'Order cancelled'),
        backgroundColor: BazzColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isAr ? 'تعذر الإلغاء' : 'Could not cancel order'),
        backgroundColor: BazzColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    return Scaffold(
      backgroundColor: BazzColors.surface,
      appBar: AppBar(
        backgroundColor: BazzColors.primary,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          isAr ? 'الطلبات الحالية' : 'Current Orders',
          style: font(fontSize: 17, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: _refresh,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(color: BazzColors.success, shape: BoxShape.circle),
                ),
                const SizedBox(width: 6),
                Text(isAr ? 'تحديثات مباشرة' : 'Live Updates',
                    style: font(fontSize: 12, color: Colors.white70)),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SearchBar(
              hintText: isAr
                  ? 'البحث بالاسم أو رقم الطلب أو المنطقة...'
                  : 'Search by name, order ID or area...',
              leading: const Icon(Icons.search_rounded, color: BazzColors.textHint),
              onChanged: (v) { _search = v; _refresh(); },
              backgroundColor: WidgetStateProperty.all(Colors.white),
              shadowColor: WidgetStateProperty.all(Colors.transparent),
              side: WidgetStateProperty.all(const BorderSide(color: BazzColors.divider)),
              shape: WidgetStateProperty.all(
                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 16)),
              textStyle: WidgetStateProperty.all(
                  GoogleFonts.inter(fontSize: 14, color: BazzColors.textPrimary)),
              hintStyle: WidgetStateProperty.all(
                  GoogleFonts.inter(fontSize: 14, color: BazzColors.textHint)),
            ),
          ),
          // Filter chips
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChipItem(label: isAr ? 'الكل' : 'All', selected: _statusFilter == null,
                      onTap: () { setState(() { _statusFilter = null; _load(); }); }, font: font),
                  const SizedBox(width: 8),
                  _FilterChipItem(label: isAr ? '⏰ انتظار' : '⏰ Pending',
                      selected: _statusFilter == OrderStatus.pending,
                      onTap: () { setState(() { _statusFilter = OrderStatus.pending; _load(); }); }, font: font),
                  const SizedBox(width: 8),
                  _FilterChipItem(label: isAr ? '🔄 معالجة' : '🔄 Processing',
                      selected: _statusFilter == OrderStatus.processing,
                      onTap: () { setState(() { _statusFilter = OrderStatus.processing; _load(); }); }, font: font),
                  const SizedBox(width: 8),
                  _FilterChipItem(label: isAr ? '🚚 في الطريق' : '🚚 On The Way',
                      selected: _statusFilter == OrderStatus.inDelivery,
                      onTap: () { setState(() { _statusFilter = OrderStatus.inDelivery; _load(); }); }, font: font),
                ],
              ),
            ),
          ),
          // Order list
          Expanded(
            child: FutureBuilder<OrdersResult>(
              future: _future,
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: BazzColors.primary));
                }
                if (snap.hasError) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.wifi_off_rounded, color: BazzColors.textHint, size: 48),
                      const SizedBox(height: 12),
                      Text(isAr ? 'تعذر الاتصال بالخادم' : 'Could not reach server',
                          style: font(fontSize: 14, color: BazzColors.textSecondary)),
                      const SizedBox(height: 12),
                      FilledButton(onPressed: _refresh,
                          child: Text(isAr ? 'إعادة المحاولة' : 'Retry')),
                    ]),
                  );
                }
                final orders = snap.data!.data;
                if (orders.isEmpty) {
                  return Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 80, height: 80,
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(24)),
                          child: const Icon(Icons.inbox_rounded, color: BazzColors.textHint, size: 40)),
                      const SizedBox(height: 16),
                      Text(isAr ? 'لا توجد طلبات' : 'No orders',
                          style: font(fontSize: 16, fontWeight: FontWeight.w700,
                              color: BazzColors.textPrimary)),
                    ]).animate().fadeIn(),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 10, 16, 100),
                  itemCount: orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (_, i) => _OrderCard(
                    order: orders[i],
                    isAr: isAr,
                    font: font,
                    onCancel: () => _cancel(orders[i], isAr),
                  ).animate(delay: (i * 60).ms).fadeIn(duration: 250.ms).slideX(begin: 0.05),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/orders/add'),
        backgroundColor: BazzColors.accent,
        foregroundColor: BazzColors.primary,
        child: const Icon(Icons.add_rounded, size: 26),
      ),
    );
  }
}

class _FilterChipItem extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _FilterChipItem({required this.label, required this.selected, required this.onTap, required this.font});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? BazzColors.accent : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? BazzColors.accent : BazzColors.divider),
        ),
        child: Text(label, style: font(fontSize: 12, fontWeight: FontWeight.w600,
            color: selected ? BazzColors.primary : BazzColors.textSecondary)),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final bool isAr;
  final VoidCallback onCancel;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _OrderCard({required this.order, required this.isAr, required this.font, required this.onCancel});

  @override
  Widget build(BuildContext context) {
    final status = order.status;
    final initials = order.recipientName.split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join();
    final area = isAr ? (order.areaAr ?? order.area) : order.area;
    final driver = isAr ? (order.driverNameAr ?? order.driverName) : order.driverName;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Text(order.orderId, style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
          const Spacer(),
          _StatusBadge(status: status, isAr: isAr, font: font),
        ]),
        const Divider(height: 14),
        Row(children: [
          Container(
            width: 36, height: 36,
            decoration: const BoxDecoration(color: Color(0xFFF1F5F9), shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text(initials, style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w700, color: BazzColors.textSecondary)),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(order.recipientName, style: font(fontSize: 13, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
            const SizedBox(height: 2),
            Text(order.recipientPhone, style: font(fontSize: 12, color: BazzColors.textSecondary)),
            Row(children: [
              const Icon(Icons.location_on_rounded, size: 12, color: BazzColors.textHint),
              const SizedBox(width: 2),
              Expanded(child: Text('$area, ${isAr ? (order.governorateAr ?? order.governorate) : order.governorate}',
                  style: font(fontSize: 12, color: BazzColors.textSecondary), overflow: TextOverflow.ellipsis)),
            ]),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            if (driver != null)
              Text('🚚 $driver', style: font(fontSize: 11, fontWeight: FontWeight.w600, color: BazzColors.primary))
            else
              Text(isAr ? 'انتظار سائق' : 'Awaiting Driver',
                  style: font(fontSize: 11, fontWeight: FontWeight.w600, color: BazzColors.accent)),
            if (order.isCod)
              Text('COD: ${order.codAmount} JD',
                  style: GoogleFonts.inter(fontSize: 11, color: BazzColors.success, fontWeight: FontWeight.w600)),
          ]),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          const Icon(Icons.calendar_today_rounded, size: 12, color: BazzColors.textHint),
          const SizedBox(width: 4),
          Text(_formatDate(order.createdAt, isAr), style: font(fontSize: 11, color: BazzColors.textSecondary)),
          const Spacer(),
          if (status != OrderStatus.cancelled && status != OrderStatus.delivered)
            OutlinedButton.icon(
              onPressed: onCancel,
              icon: const Icon(Icons.close_rounded, size: 14),
              label: Text(isAr ? 'إلغاء' : 'Cancel', style: font(fontSize: 12, fontWeight: FontWeight.w600)),
              style: OutlinedButton.styleFrom(
                foregroundColor: BazzColors.error,
                side: const BorderSide(color: BazzColors.error),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ]),
      ]),
    );
  }

  String _formatDate(DateTime d, bool isAr) {
    final months = isAr
        ? ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر']
        : ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day} ${months[d.month - 1]}, ${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
  }
}

class _StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _StatusBadge({required this.status, required this.isAr, required this.font});

  @override
  Widget build(BuildContext context) {
    final (bg, fg) = switch (status) {
      OrderStatus.pending    => (BazzColors.pendingBg, BazzColors.pendingText),
      OrderStatus.processing => (BazzColors.processingBg, BazzColors.processingText),
      OrderStatus.inDelivery => (BazzColors.inDeliveryBg, BazzColors.inDeliveryText),
      OrderStatus.delivered  => (BazzColors.deliveredBg, BazzColors.deliveredText),
      OrderStatus.cancelled  => (BazzColors.cancelledBg, BazzColors.cancelledText),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(status.label(isAr), style: font(fontSize: 10, fontWeight: FontWeight.w700, color: fg)),
    );
  }
}
