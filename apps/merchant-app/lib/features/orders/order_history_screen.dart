import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/orders_service.dart';
import '../../theme/colors.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _search = '';
  String _timePeriod = 'all';

  // Stats
  int _totalOrders = 0;
  int _totalDelivered = 0;
  int _totalCancelled = 0;

  // Full delivered list (loaded once)
  List<Order> _allOrders = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final results = await Future.wait([
        OrdersService.instance.listOrders(limit: 100),                              // all recent for display
        OrdersService.instance.listOrders(status: OrderStatus.delivered, limit: 1), // total delivered
        OrdersService.instance.listOrders(status: OrderStatus.cancelled, limit: 1), // total cancelled
      ]);
      final all = results[0];
      if (!mounted) return;
      setState(() {
        _allOrders = all.data;
        _totalOrders = all.total;
        _totalDelivered = results[1].total;
        _totalCancelled = results[2].total;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  List<Order> get _filtered {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    return _allOrders.where((o) {
      // Period filter
      final d = DateTime(o.createdAt.year, o.createdAt.month, o.createdAt.day);
      if (_timePeriod == 'today' && d != today) return false;
      if (_timePeriod == 'yesterday' && d != yesterday) return false;
      if (_timePeriod == 'week' && o.createdAt.isBefore(weekAgo)) return false;

      // Search filter
      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        return o.orderId.toLowerCase().contains(q) ||
            o.recipientName.toLowerCase().contains(q) ||
            o.area.toLowerCase().contains(q) ||
            o.governorate.toLowerCase().contains(q);
      }
      return true;
    }).toList();
  }

  /// Group orders by date label
  Map<String, List<Order>> _groupByDate(List<Order> orders) {
    final map = <String, List<Order>>{};
    for (final o in orders) {
      final key = _dateKey(o.createdAt);
      map.putIfAbsent(key, () => []).add(o);
    }
    return map;
  }

  String _dateKey(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(dt.year, dt.month, dt.day);
    if (d == today) return 'today';
    if (d == today.subtract(const Duration(days: 1))) return 'yesterday';
    return dt.toIso8601String().substring(0, 10); // "2024-12-15"
  }

  String _dateLabel(String key, bool isAr) {
    if (key == 'today') {
      final now = DateTime.now();
      return '${isAr ? 'اليوم' : 'Today'} · ${_formatDate(now, isAr)}';
    }
    if (key == 'yesterday') {
      final y = DateTime.now().subtract(const Duration(days: 1));
      return '${isAr ? 'أمس' : 'Yesterday'} · ${_formatDate(y, isAr)}';
    }
    final dt = DateTime.tryParse(key);
    if (dt == null) return key;
    return _formatDate(dt, isAr);
  }

  String _formatDate(DateTime dt, bool isAr) {
    const enMonths = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    const arMonths = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    final month = isAr ? arMonths[dt.month - 1] : enMonths[dt.month - 1];
    return isAr ? '${dt.day} $month ${dt.year}' : '$month ${dt.day}, ${dt.year}';
  }

  int get _successRate {
    if (_totalOrders == 0) return 0;
    return (_totalDelivered / _totalOrders * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;
    final memberSince = appState.merchant?.memberSinceLabel ?? '';
    final filtered = _filtered;
    final grouped = _groupByDate(filtered);

    return Scaffold(
      backgroundColor: BazzColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: BazzColors.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Text(
          isAr ? 'سجل الطلبات' : 'Order History',
          style: font(fontSize: 17, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _loading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: BazzColors.textSecondary))
                : const Icon(Icons.refresh_rounded, color: BazzColors.textSecondary),
            onPressed: _loading ? null : _loadData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: BazzColors.primary,
        child: Column(
          children: [
            // All Time Stats card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: _loading
                  ? Container(
                      height: 76,
                      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(14)),
                    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.white54)
                  : Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: BazzColors.divider),
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isAr ? 'إحصائيات كل الأوقات' : 'All Time Stats',
                                style: font(fontSize: 13, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
                              ),
                              Text(
                                memberSince.isNotEmpty
                                    ? '${isAr ? 'منذ' : 'Since'} $memberSince'
                                    : '',
                                style: font(fontSize: 11, color: BazzColors.textSecondary),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _AllTimeStat(
                                value: '$_totalOrders',
                                label: isAr ? 'إجمالي' : 'Total',
                                color: BazzColors.primary,
                                font: font,
                              ),
                              _AllTimeStat(
                                value: '$_totalDelivered ✓',
                                label: isAr ? 'تم التوصيل' : 'Delivered',
                                color: BazzColors.success,
                                font: font,
                              ),
                              _AllTimeStat(
                                value: '$_totalCancelled ×',
                                label: isAr ? 'ملغاة' : 'Cancelled',
                                color: BazzColors.error,
                                font: font,
                              ),
                              _AllTimeStat(
                                value: '$_successRate% ↑',
                                label: isAr ? 'نجاح' : 'Success',
                                color: BazzColors.success,
                                font: font,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
            ),

            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
              child: SearchBar(
                hintText: isAr
                    ? 'البحث في الطلبات، العملاء، المناطق...'
                    : 'Search orders, customers, areas...',
                leading: const Icon(Icons.search_rounded, color: BazzColors.textHint),
                onChanged: (v) => setState(() => _search = v),
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

            // Time period chips
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _TimePeriodChip(label: isAr ? 'كل الأوقات' : 'All Time', value: 'all', selected: _timePeriod == 'all', onTap: () => setState(() => _timePeriod = 'all'), font: font),
                    const SizedBox(width: 8),
                    _TimePeriodChip(label: isAr ? 'اليوم' : 'Today', value: 'today', selected: _timePeriod == 'today', onTap: () => setState(() => _timePeriod = 'today'), font: font),
                    const SizedBox(width: 8),
                    _TimePeriodChip(label: isAr ? 'أمس' : 'Yesterday', value: 'yesterday', selected: _timePeriod == 'yesterday', onTap: () => setState(() => _timePeriod = 'yesterday'), font: font),
                    const SizedBox(width: 8),
                    _TimePeriodChip(label: isAr ? 'آخر 7 أيام' : 'Last 7 Days', value: 'week', selected: _timePeriod == 'week', onTap: () => setState(() => _timePeriod = 'week'), font: font),
                  ],
                ),
              ),
            ),

            // Showing count
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  isAr ? 'عرض ${filtered.length} طلبات' : 'Showing ${filtered.length} orders',
                  style: font(fontSize: 12, color: BazzColors.textSecondary),
                ),
              ),
            ),

            // Order list
            Expanded(
              child: _error != null
                  ? Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.wifi_off_rounded, size: 40, color: BazzColors.textHint),
                          const SizedBox(height: 12),
                          Text(isAr ? 'تعذّر التحميل' : 'Failed to load', style: font(fontSize: 15, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                          const SizedBox(height: 4),
                          Text(isAr ? 'اسحب للأسفل للمحاولة' : 'Pull down to retry', style: font(fontSize: 13, color: BazzColors.textSecondary)),
                        ],
                      ),
                    )
                  : filtered.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 80, height: 80,
                                decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(24)),
                                child: const Icon(Icons.search_off_rounded, color: BazzColors.textHint, size: 40),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                isAr ? 'لا توجد نتائج' : 'No orders found',
                                style: font(fontSize: 16, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
                              ),
                            ],
                          ).animate().fadeIn(),
                        )
                      : ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: grouped.entries.length,
                          itemBuilder: (_, gi) {
                            final entry = grouped.entries.elementAt(gi);
                            final orders = entry.value;
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _dateLabel(entry.key, isAr),
                                        style: font(fontSize: 13, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
                                      ),
                                      Text(
                                        isAr ? '${orders.length} طلبات' : '${orders.length} orders',
                                        style: font(fontSize: 12, fontWeight: FontWeight.w600, color: BazzColors.accent),
                                      ),
                                    ],
                                  ),
                                ),
                                ...orders.asMap().entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: _HistoryCard(order: e.value, isAr: isAr, font: font)
                                      .animate(delay: (e.key * 60).ms)
                                      .fadeIn(duration: 250.ms)
                                      .slideY(begin: 0.05),
                                )),
                              ],
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stat widget ──────────────────────────────────────────────────────────────
class _AllTimeStat extends StatelessWidget {
  final String value, label;
  final Color color;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _AllTimeStat({required this.value, required this.label, required this.color, required this.font});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value, style: font(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: font(fontSize: 10, color: BazzColors.textSecondary)),
      ],
    );
  }
}

// ─── Period chip ──────────────────────────────────────────────────────────────
class _TimePeriodChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _TimePeriodChip({required this.label, required this.value, required this.selected, required this.onTap, required this.font});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? BazzColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? BazzColors.primary : BazzColors.divider),
        ),
        child: Text(
          label,
          style: font(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : BazzColors.textSecondary),
        ),
      ),
    );
  }
}

// ─── History card ─────────────────────────────────────────────────────────────
class _HistoryCard extends StatelessWidget {
  final Order order;
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _HistoryCard({required this.order, required this.isAr, required this.font});

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    return '?';
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $period';
  }

  Color get _statusColor {
    return switch (order.status) {
      OrderStatus.delivered => BazzColors.success,
      OrderStatus.cancelled => BazzColors.error,
      OrderStatus.inDelivery => BazzColors.accent,
      _ => BazzColors.primary,
    };
  }

  @override
  Widget build(BuildContext context) {
    final location = isAr
        ? '${order.areaAr ?? order.area}، ${order.governorateAr ?? order.governorate}'
        : '${order.area}, ${order.governorate}';
    final driver = isAr
        ? (order.driverNameAr ?? order.driverName ?? (isAr ? 'غير محدد' : 'Unassigned'))
        : (order.driverName ?? 'Unassigned');
    const enMonths = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    final dateStr = '${enMonths[order.createdAt.month - 1]} ${order.createdAt.day} · ${_formatTime(order.createdAt)}';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: _statusColor, width: 4)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: order ID + status chip
          Row(
            children: [
              Text(order.orderId,
                  style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              const Spacer(),
              if (order.isCod) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(color: BazzColors.accent, borderRadius: BorderRadius.circular(6)),
                  child: Text('COD ${order.codAmount.toStringAsFixed(0)} JD',
                      style: font(fontSize: 9, fontWeight: FontWeight.w700, color: BazzColors.primary)),
                ),
                const SizedBox(width: 6),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: _statusColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.status.label(isAr),
                  style: font(fontSize: 10, fontWeight: FontWeight.w700, color: _statusColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: avatar + customer + driver
          Row(
            children: [
              Container(
                width: 32, height: 32,
                decoration: const BoxDecoration(color: BazzColors.accent, shape: BoxShape.circle),
                alignment: Alignment.center,
                child: Text(_initials(order.recipientName),
                    style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w800, color: BazzColors.primary)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(order.recipientName,
                    style: font(fontSize: 13, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              ),
              const Text('🚚', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(driver, style: font(fontSize: 12, color: BazzColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: location
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(location, style: font(fontSize: 12, color: BazzColors.textSecondary)),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 4: datetime
          Row(
            children: [
              const Text('🕐', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(dateStr, style: font(fontSize: 11, color: BazzColors.textSecondary)),
            ],
          ),
        ],
      ),
    );
  }
}
