import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/colors.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _HistoryOrder {
  final String id;
  final int items;
  final bool fast;
  final String status;
  final String initials;
  final String customer;
  final String driver;
  final String location;
  final String datetime;
  final String deliveryTime;
  const _HistoryOrder({
    required this.id,
    required this.items,
    required this.fast,
    required this.status,
    required this.initials,
    required this.customer,
    required this.driver,
    required this.location,
    required this.datetime,
    required this.deliveryTime,
  });
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  String _search = '';
  String _timePeriod = 'all';

  final _historyOrders = const [
    _HistoryOrder(
      id: '#BZ-2401',
      items: 3,
      fast: true,
      status: 'Delivered',
      initials: 'AH',
      customer: 'Ahmad Hassan',
      driver: 'Mohammed Ali',
      location: 'Khalda, Amman',
      datetime: 'Dec 15 · 2:30 PM',
      deliveryTime: '35 min delivery',
    ),
    _HistoryOrder(
      id: '#BZ-2402',
      items: 1,
      fast: false,
      status: 'Delivered',
      initials: 'SA',
      customer: 'Sara Ali',
      driver: 'Ahmad K.',
      location: 'Swefieh, Amman',
      datetime: 'Dec 15 · 1:15 PM',
      deliveryTime: '52 min delivery',
    ),
  ];

  List<_HistoryOrder> get _filtered {
    if (_search.isEmpty) return _historyOrders;
    final q = _search.toLowerCase();
    return _historyOrders
        .where((o) =>
            o.id.toLowerCase().contains(q) ||
            o.customer.toLowerCase().contains(q) ||
            o.location.toLowerCase().contains(q))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;
    final filtered = _filtered;

    return Scaffold(
      backgroundColor: BazzColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: BazzColors.textPrimary),
          onPressed: () => context.go('/home'),
        ),
        title: Text(
          isAr ? 'سجل الطلبات' : 'Order History',
          style: font(fontSize: 17, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download_outlined, color: BazzColors.textSecondary),
            onPressed: () {},
            tooltip: isAr ? 'تحميل' : 'Download',
          ),
        ],
      ),
      body: Column(
        children: [
          // All Time Stats card
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Container(
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
                        style: font(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: BazzColors.textPrimary),
                      ),
                      Text(
                        isAr ? 'منذ يناير 2024' : 'Since Jan 2024',
                        style: font(fontSize: 11, color: BazzColors.textSecondary),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _AllTimeStat(
                          value: '1,248',
                          label: isAr ? 'إجمالي' : 'Total',
                          color: BazzColors.primary,
                          font: font),
                      _AllTimeStat(
                          value: '1,180 ✓',
                          label: isAr ? 'تم التوصيل' : 'Delivered',
                          color: BazzColors.success,
                          font: font),
                      _AllTimeStat(
                          value: '48 ×',
                          label: isAr ? 'ملغاة' : 'Cancelled',
                          color: BazzColors.error,
                          font: font),
                      _AllTimeStat(
                          value: '94% ↑',
                          label: isAr ? 'نجاح' : 'Success',
                          color: BazzColors.success,
                          font: font),
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
              trailing: const [Icon(Icons.mic_rounded, color: BazzColors.textHint)],
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

          // Filter dropdowns row
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
            child: Row(
              children: [
                _DropdownChip(label: isAr ? 'كل الأوقات ▼' : 'All Time ▼', font: font),
                const SizedBox(width: 8),
                _DropdownChip(label: isAr ? 'كل الحالات ▼' : 'All Status ▼', font: font),
                const SizedBox(width: 8),
                _DropdownChip(label: isAr ? 'كل المناطق ▼' : 'All Areas ▼', font: font),
              ],
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
                  _TimePeriodChip(
                      label: isAr ? 'كل الأوقات' : 'All Time',
                      value: 'all',
                      selected: _timePeriod == 'all',
                      onTap: () => setState(() => _timePeriod = 'all'),
                      font: font),
                  const SizedBox(width: 8),
                  _TimePeriodChip(
                      label: isAr ? 'اليوم' : 'Today',
                      value: 'today',
                      selected: _timePeriod == 'today',
                      onTap: () => setState(() => _timePeriod = 'today'),
                      font: font),
                  const SizedBox(width: 8),
                  _TimePeriodChip(
                      label: isAr ? 'أمس' : 'Yesterday',
                      value: 'yesterday',
                      selected: _timePeriod == 'yesterday',
                      onTap: () => setState(() => _timePeriod = 'yesterday'),
                      font: font),
                  const SizedBox(width: 8),
                  _TimePeriodChip(
                      label: isAr ? 'آخر 7 أيام' : 'Last 7 Days',
                      value: 'week',
                      selected: _timePeriod == 'week',
                      onTap: () => setState(() => _timePeriod = 'week'),
                      font: font),
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
            child: filtered.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(24)),
                          child: const Icon(Icons.search_off_rounded,
                              color: BazzColors.textHint, size: 40),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          isAr ? 'لا توجد نتائج' : 'No orders found',
                          style: font(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: BazzColors.textPrimary),
                        ),
                      ],
                    ).animate().fadeIn(),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    children: [
                      // Date group header
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isAr ? 'اليوم · 15 ديس 2024' : 'Today · Dec 15, 2024',
                              style: font(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: BazzColors.textPrimary),
                            ),
                            Text(
                              isAr ? '3 طلبات' : '3 orders',
                              style: font(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: BazzColors.accent),
                            ),
                          ],
                        ),
                      ),
                      ...filtered.asMap().entries.map(
                            (e) => Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _HistoryCard(
                                order: e.value,
                                isAr: isAr,
                                font: font,
                              )
                                  .animate(delay: (e.key * 60).ms)
                                  .fadeIn(duration: 250.ms)
                                  .slideY(begin: 0.05),
                            ),
                          ),
                    ],
                  ),
          ),
        ],
      ),
      // Download FAB
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: BazzColors.primary,
        foregroundColor: Colors.white,
        child: const Icon(Icons.file_download_outlined),
      ),
    );
  }
}

class _AllTimeStat extends StatelessWidget {
  final String value, label;
  final Color color;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _AllTimeStat({required this.value, required this.label, required this.color, required this.font});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: font(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 2),
        Text(label, style: font(fontSize: 10, color: BazzColors.textSecondary)),
      ],
    );
  }
}

class _DropdownChip extends StatelessWidget {
  final String label;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _DropdownChip({required this.label, required this.font});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: BazzColors.divider),
      ),
      child: Text(label, style: font(fontSize: 11, color: BazzColors.textSecondary)),
    );
  }
}

class _TimePeriodChip extends StatelessWidget {
  final String label, value;
  final bool selected;
  final VoidCallback onTap;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _TimePeriodChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
    required this.font,
  });

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
          style: font(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : BazzColors.textSecondary,
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final _HistoryOrder order;
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _HistoryCard({required this.order, required this.isAr, required this.font});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: const Border(left: BorderSide(color: BazzColors.success, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: order# + items + Fast chip + status chip
          Row(
            children: [
              Text(order.id,
                  style: font(
                      fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              const SizedBox(width: 6),
              Text('· ${order.items} ${isAr ? 'عناصر' : 'items'}',
                  style: font(fontSize: 12, color: BazzColors.textSecondary)),
              const Spacer(),
              if (order.fast) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                  decoration: BoxDecoration(
                    color: BazzColors.accent,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(children: [
                    const Text('⚡', style: TextStyle(fontSize: 9)),
                    const SizedBox(width: 2),
                    Text(isAr ? 'سريع' : 'Fast',
                        style: font(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: BazzColors.primary)),
                  ]),
                ),
                const SizedBox(width: 6),
              ],
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F8EF),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(children: [
                  const Text('✅', style: TextStyle(fontSize: 9)),
                  const SizedBox(width: 3),
                  Text(isAr ? 'تم التوصيل' : 'Delivered',
                      style: font(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: BazzColors.success)),
                ]),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Row 2: avatar + customer + driver
          Row(
            children: [
              // Golden avatar
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: BazzColors.accent,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  order.initials,
                  style: GoogleFonts.inter(
                      fontSize: 11, fontWeight: FontWeight.w800, color: BazzColors.primary),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(order.customer,
                    style: font(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: BazzColors.textPrimary)),
              ),
              const Text('🚚', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Text(order.driver, style: font(fontSize: 12, color: BazzColors.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),

          // Row 3: location + rate link
          Row(
            children: [
              const Text('📍', style: TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(order.location,
                    style: font(fontSize: 12, color: BazzColors.textSecondary)),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  isAr ? '★ تقييم ←' : '★ Rate →',
                  style: font(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: BazzColors.accent),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Row 4: datetime + delivery time + Details link
          Row(
            children: [
              const Text('🕐', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 4),
              Text(order.datetime,
                  style: font(fontSize: 11, color: BazzColors.textSecondary)),
              const SizedBox(width: 8),
              const Text('⚡', style: TextStyle(fontSize: 11)),
              const SizedBox(width: 2),
              Text(order.deliveryTime,
                  style: font(fontSize: 11, color: BazzColors.textSecondary)),
              const Spacer(),
              GestureDetector(
                onTap: () {},
                child: Text(
                  isAr ? 'التفاصيل →' : 'Details →',
                  style: font(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: BazzColors.accent),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
