import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/orders_service.dart';
import '../../shared/widgets/bazz_logo.dart';
import '../../shared/widgets/bottom_sheets/profile_sheet.dart';
import '../../theme/colors.dart';

// ─── Data container ───────────────────────────────────────────────────────────
class _HomeData {
  final List<Order> recentOrders;
  final int totalDelivered;
  final int totalOrders;
  final int totalCancelled;

  const _HomeData({
    required this.recentOrders,
    required this.totalDelivered,
    required this.totalOrders,
    required this.totalCancelled,
  });

  List<Order> get activeOrders => recentOrders
      .where((o) =>
          o.status == OrderStatus.pending ||
          o.status == OrderStatus.processing ||
          o.status == OrderStatus.inDelivery)
      .toList();

  List<Order> get recentDeliveries => recentOrders
      .where((o) => o.status == OrderStatus.delivered)
      .take(3)
      .toList();

  int get pendingCount => recentOrders
      .where((o) => o.status == OrderStatus.pending)
      .length;
}

// ─── Root screen ──────────────────────────────────────────────────────────────
class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  int _navIndex = 0;
  _HomeData? _homeData;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        OrdersService.instance.listOrders(limit: 50),
        OrdersService.instance.listOrders(status: OrderStatus.delivered, limit: 1),
        OrdersService.instance.listOrders(status: OrderStatus.cancelled, limit: 1),
      ]);
      if (!mounted) return;
      setState(() {
        _homeData = _HomeData(
          recentOrders: results[0].data,
          totalDelivered: results[1].total,
          totalOrders: results[0].total,
          totalCancelled: results[2].total,
        );
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  void _onNavTap(int i) {
    if (i == 1) { context.push('/orders/current'); return; }
    if (i == 2) { context.push('/reports'); return; }
    if (i == 3) { showProfileSheet(context); return; }
    setState(() => _navIndex = i);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    final activeCount = _homeData?.activeOrders.length ?? 0;

    return Scaffold(
      backgroundColor: BazzColors.surface,
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: BazzColors.primary,
        child: _HomeBody(
          isAr: isAr,
          font: font,
          homeData: _homeData,
          loading: _loading,
          error: _error,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/orders/add'),
        backgroundColor: BazzColors.accent,
        foregroundColor: BazzColors.primary,
        elevation: 4,
        tooltip: isAr ? 'طلب جديد' : 'New Order',
        child: const Icon(Icons.add_rounded, size: 28),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        elevation: 8,
        shadowColor: const Color(0x14000000),
        notchMargin: 8,
        shape: const CircularNotchedRectangle(),
        padding: EdgeInsets.zero,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavItem(
              icon: Icons.home_outlined,
              selectedIcon: Icons.home_rounded,
              label: isAr ? 'الرئيسية' : 'Home',
              selected: _navIndex == 0,
              onTap: () => _onNavTap(0),
            ),
            _NavItem(
              icon: Icons.local_shipping_outlined,
              selectedIcon: Icons.local_shipping_rounded,
              label: isAr ? 'الطلبات' : 'Orders',
              selected: _navIndex == 1,
              onTap: () => _onNavTap(1),
              badge: activeCount > 0 ? activeCount : null,
            ),
            // Center gap for FAB
            const SizedBox(width: 72),
            _NavItem(
              icon: Icons.analytics_outlined,
              selectedIcon: Icons.analytics_rounded,
              label: isAr ? 'التقارير' : 'Reports',
              selected: _navIndex == 2,
              onTap: () => _onNavTap(2),
            ),
            _NavItem(
              icon: Icons.person_outline_rounded,
              selectedIcon: Icons.person_rounded,
              label: isAr ? 'الحساب' : 'Profile',
              selected: _navIndex == 3,
              onTap: () => _onNavTap(3),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Nav item ─────────────────────────────────────────────────────────────────
class _NavItem extends StatelessWidget {
  final IconData icon, selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? badge;

  const _NavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              badge != null
                  ? Badge(
                      label: Text('$badge',
                          style: GoogleFonts.inter(fontSize: 9, fontWeight: FontWeight.w700)),
                      backgroundColor: BazzColors.error,
                      textColor: Colors.white,
                      child: Icon(selected ? selectedIcon : icon,
                          color: selected ? BazzColors.primary : BazzColors.textHint, size: 24),
                    )
                  : Icon(selected ? selectedIcon : icon,
                      color: selected ? BazzColors.primary : BazzColors.textHint, size: 24),
              const SizedBox(height: 2),
              Text(label,
                  style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      color: selected ? BazzColors.primary : BazzColors.textHint)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Home Body ────────────────────────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  final _HomeData? homeData;
  final bool loading;
  final String? error;

  const _HomeBody({
    required this.isAr,
    required this.font,
    required this.homeData,
    required this.loading,
    required this.error,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Navy header card
        SliverToBoxAdapter(child: _HeaderCard(isAr: isAr, font: font)),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              if (loading) ...[
                _LoadingSkeleton(),
              ] else if (error != null) ...[
                _ErrorCard(
                  isAr: isAr,
                  font: font,
                  message: error!,
                ),
              ] else if (homeData != null) ...[
                // Stats card
                _StatsCard(
                  isAr: isAr,
                  font: font,
                  totalDelivered: homeData!.totalDelivered,
                  totalOrders: homeData!.totalOrders,
                ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 20),

                // Quick Actions label
                Text(
                  isAr ? 'إجراءات سريعة' : 'Quick Actions',
                  style: font(fontSize: 16, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
                ),
                const SizedBox(height: 12),

                // Quick Actions row — 4 items
                _QuickActionsRow(isAr: isAr, font: font),

                const SizedBox(height: 24),

                // Active Orders section
                _ActiveOrdersSection(
                  isAr: isAr,
                  font: font,
                  orders: homeData!.activeOrders,
                ),

                const SizedBox(height: 24),

                // Recent Deliveries section
                _RecentDeliveriesSection(
                  isAr: isAr,
                  font: font,
                  deliveries: homeData!.recentDeliveries,
                ),

                const SizedBox(height: 20),

                // This Month Performance card
                _PerformanceCard(
                  isAr: isAr,
                  font: font,
                  delivered: homeData!.totalDelivered,
                  pending: homeData!.pendingCount,
                  cancelled: homeData!.totalCancelled,
                ).animate(delay: 400.ms).fadeIn(duration: 300.ms),
              ],

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─── Loading skeleton ─────────────────────────────────────────────────────────
class _LoadingSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SkeletonBox(height: 90, borderRadius: 16),
        const SizedBox(height: 20),
        _SkeletonBox(height: 20, width: 140, borderRadius: 8),
        const SizedBox(height: 12),
        Row(
          children: List.generate(4, (_) => Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _SkeletonBox(height: 72, borderRadius: 12),
            ),
          )),
        ),
        const SizedBox(height: 24),
        _SkeletonBox(height: 180, borderRadius: 12),
        const SizedBox(height: 24),
        _SkeletonBox(height: 56, borderRadius: 12),
        const SizedBox(height: 8),
        _SkeletonBox(height: 56, borderRadius: 12),
        const SizedBox(height: 8),
        _SkeletonBox(height: 56, borderRadius: 12),
        const SizedBox(height: 20),
        _SkeletonBox(height: 140, borderRadius: 16),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white54);
  }
}

class _SkeletonBox extends StatelessWidget {
  final double height;
  final double? width;
  final double borderRadius;
  const _SkeletonBox({required this.height, this.width, required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }
}

// ─── Error card ───────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  final String message;
  const _ErrorCard({required this.isAr, required this.font, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: BazzColors.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.wifi_off_rounded, size: 40, color: BazzColors.textHint),
          const SizedBox(height: 12),
          Text(
            isAr ? 'تعذّر تحميل البيانات' : 'Failed to load data',
            style: font(fontSize: 15, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
          ),
          const SizedBox(height: 6),
          Text(
            isAr ? 'اسحب للأسفل لإعادة المحاولة' : 'Pull down to retry',
            style: font(fontSize: 13, color: BazzColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Header card (navy gradient, rounded bottom) ──────────────────────────────
String _greeting(bool isAr) {
  final h = DateTime.now().hour;
  if (h < 12) return isAr ? 'صباح الخير 👋' : 'Good Morning 👋';
  if (h < 17) return isAr ? 'مساء الخير 👋' : 'Good Afternoon 👋';
  return isAr ? 'مساء النور 👋' : 'Good Evening 👋';
}

class _HeaderCard extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _HeaderCard({required this.isAr, required this.font});

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.read<AppState>();
    final name = appState.merchantName;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1A3C6E), Color(0xFF0D2347)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Stack(
          children: [
            Positioned.fill(child: CustomPaint(painter: _HeaderLinePainter())),
            Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 12,
                left: 20,
                right: 20,
                bottom: 24,
              ),
              child: Column(
                children: [
                  // Top row: BazZ logo left | avatar right
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BazzLogoWhite(fontSize: 22),
                      GestureDetector(
                        onTap: () => showProfileSheet(context),
                        child: Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: BazzColors.accent,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            _initials(name),
                            style: GoogleFonts.inter(
                                fontSize: 13, fontWeight: FontWeight.w800, color: BazzColors.primary),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Greeting + store name
                  Align(
                    alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment:
                          isAr ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting(isAr),
                          style: font(fontSize: 14, color: Colors.white70),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          name,
                          style: font(
                              fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Stats card ───────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  final int totalDelivered;
  final int totalOrders;
  const _StatsCard({
    required this.isAr,
    required this.font,
    required this.totalDelivered,
    required this.totalOrders,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Left stat: Total Delivered
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'إجمالي التوصيلات' : 'Total Delivered',
                    style: font(fontSize: 12, color: BazzColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$totalDelivered',
                    style: font(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: BazzColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr ? 'طلب مكتمل' : 'completed orders',
                    style: font(fontSize: 11, color: BazzColors.success),
                  ),
                ],
              ),
            ),
            Container(width: 1, height: 60, color: BazzColors.divider),
            const SizedBox(width: 16),
            // Right stat: Total Orders
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'إجمالي الطلبات' : 'Total Orders',
                    style: font(fontSize: 12, color: BazzColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '$totalOrders',
                    style: font(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: BazzColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr ? 'جميع الطلبات' : 'all time',
                    style: font(fontSize: 11, color: BazzColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Quick Actions row ────────────────────────────────────────────────────────
class _QuickActionsRow extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _QuickActionsRow({required this.isAr, required this.font});

  @override
  Widget build(BuildContext context) {
    final actions = [
      _QA(
        label: isAr ? 'طلب جديد' : 'New Order',
        icon: Icons.add_rounded,
        bgColor: BazzColors.accent,
        iconColor: BazzColors.primary,
        route: '/orders/add',
      ),
      _QA(
        label: isAr ? 'الحالية' : 'Current',
        icon: Icons.local_shipping_rounded,
        bgColor: const Color(0xFFE8F4FD),
        iconColor: const Color(0xFF1565C0),
        route: '/orders/current',
      ),
      _QA(
        label: isAr ? 'السجل' : 'History',
        icon: Icons.history_rounded,
        bgColor: const Color(0xFFE8F8EF),
        iconColor: BazzColors.success,
        route: '/orders/history',
      ),
      _QA(
        label: isAr ? 'التقارير' : 'Reports',
        icon: Icons.bar_chart_rounded,
        bgColor: const Color(0xFFFFF8E1),
        iconColor: const Color(0xFFFFB300),
        route: '/reports',
      ),
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: actions
          .asMap()
          .entries
          .map((e) => _QuickActionItem(qa: e.value, font: font)
              .animate(delay: (e.key * 60).ms)
              .fadeIn(duration: 250.ms)
              .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1)))
          .toList(),
    );
  }
}

class _QA {
  final String label, route;
  final IconData icon;
  final Color bgColor, iconColor;
  const _QA({
    required this.label,
    required this.icon,
    required this.bgColor,
    required this.iconColor,
    required this.route,
  });
}

class _QuickActionItem extends StatelessWidget {
  final _QA qa;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _QuickActionItem({required this.qa, required this.font});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(qa.route),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(color: qa.bgColor, shape: BoxShape.circle),
            child: Icon(qa.icon, color: qa.iconColor, size: 26),
          ),
          const SizedBox(height: 6),
          Text(
            qa.label,
            style: font(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: BazzColors.textPrimary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Active Orders section ────────────────────────────────────────────────────
class _ActiveOrdersSection extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  final List<Order> orders;
  const _ActiveOrdersSection({required this.isAr, required this.font, required this.orders});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? 'الطلبات النشطة' : 'Active Orders',
              style: font(
                  fontSize: 16, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
            ),
            TextButton(
              onPressed: () => context.push('/orders/current'),
              child: Text(
                isAr ? 'عرض الكل ←' : 'See All →',
                style: font(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: BazzColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (orders.isEmpty)
          _EmptyState(
            isAr: isAr,
            font: font,
            message: isAr ? 'لا توجد طلبات نشطة حالياً' : 'No active orders right now',
            icon: Icons.local_shipping_outlined,
          )
        else
          SizedBox(
            height: 170,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (_, i) => _ActiveOrderCard(order: orders[i], isAr: isAr, font: font),
            ),
          ),
      ],
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  final Order order;
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _ActiveOrderCard({required this.order, required this.isAr, required this.font});

  String _formatTime(DateTime dt) {
    final h = dt.hour;
    final m = dt.minute.toString().padLeft(2, '0');
    final period = h >= 12 ? 'PM' : 'AM';
    final hour12 = h % 12 == 0 ? 12 : h % 12;
    return '$hour12:$m $period';
  }

  @override
  Widget build(BuildContext context) {
    final isInDelivery = order.status == OrderStatus.inDelivery;
    final borderColor = isInDelivery ? BazzColors.accent : BazzColors.primary;
    final chipBg = isInDelivery ? BazzColors.accent : BazzColors.primary;
    final chipText = isInDelivery ? BazzColors.primary : Colors.white;
    final location = isAr
        ? '${order.areaAr ?? order.area}، ${order.governorateAr ?? order.governorate}'
        : '${order.area}, ${order.governorate}';
    final driver = isAr
        ? (order.driverNameAr ?? order.driverName ?? (isAr ? 'غير محدد' : 'Unassigned'))
        : (order.driverName ?? 'Unassigned');

    return Container(
      width: 220,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: borderColor, width: 4)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))
        ],
      ),
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Order ID + Status chip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(order.orderId,
                  style: font(
                      fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.status.label(isAr),
                    style: font(fontSize: 10, fontWeight: FontWeight.w700, color: chipText)),
              ),
            ],
          ),
          // Location
          Row(children: [
            const Text('📍', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Expanded(
                child: Text(location,
                    style: font(fontSize: 12, color: BazzColors.textSecondary),
                    overflow: TextOverflow.ellipsis)),
          ]),
          // Time
          Row(children: [
            const Text('🕐', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(_formatTime(order.createdAt),
                style: font(fontSize: 12, color: BazzColors.textSecondary)),
          ]),
          // Driver
          Row(children: [
            const Text('🚚', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Expanded(
                child: Text(driver,
                    style: font(fontSize: 12, color: BazzColors.textSecondary),
                    overflow: TextOverflow.ellipsis)),
          ]),
        ],
      ),
    );
  }
}

// ─── Recent Deliveries section ────────────────────────────────────────────────
class _RecentDeliveriesSection extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  final List<Order> deliveries;
  const _RecentDeliveriesSection({
    required this.isAr,
    required this.font,
    required this.deliveries,
  });

  String _formatDate(DateTime dt) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              isAr ? 'التوصيلات الأخيرة' : 'Recent Deliveries',
              style: font(
                  fontSize: 16, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
            ),
            TextButton(
              onPressed: () => context.push('/orders/history'),
              child: Text(
                isAr ? 'عرض الكل ←' : 'See All →',
                style: font(
                    fontSize: 13, fontWeight: FontWeight.w600, color: BazzColors.accent),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (deliveries.isEmpty)
          _EmptyState(
            isAr: isAr,
            font: font,
            message: isAr ? 'لا توجد توصيلات مكتملة بعد' : 'No deliveries yet',
            icon: Icons.check_circle_outline_rounded,
          )
        else
          ...deliveries.asMap().entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: _DeliveryTile(
                    order: e.value,
                    isAr: isAr,
                    font: font,
                    date: _formatDate(e.value.createdAt),
                  ).animate(delay: (e.key * 60 + 200).ms).fadeIn(duration: 250.ms),
                ),
              ),
      ],
    );
  }
}

class _DeliveryTile extends StatelessWidget {
  final Order order;
  final bool isAr;
  final String date;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _DeliveryTile({
    required this.order,
    required this.isAr,
    required this.date,
    required this.font,
  });

  @override
  Widget build(BuildContext context) {
    final location = isAr
        ? '${order.areaAr ?? order.area}، ${order.governorateAr ?? order.governorate}'
        : '${order.area}, ${order.governorate}';
    final codLabel = order.isCod
        ? 'COD ${order.codAmount.toStringAsFixed(0)} JD'
        : (isAr ? 'مدفوع مسبقاً' : 'Pre-paid');

    return Card(
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: Container(
          width: 40,
          height: 40,
          decoration: const BoxDecoration(color: Color(0xFFE8F8EF), shape: BoxShape.circle),
          child: const Icon(Icons.check_rounded, color: BazzColors.success, size: 20),
        ),
        title: Text(order.orderId,
            style: font(fontSize: 13, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
        subtitle: Text(location,
            style: font(fontSize: 12, color: BazzColors.textSecondary)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(date, style: font(fontSize: 11, color: BazzColors.textSecondary)),
            const SizedBox(height: 2),
            Text(
              codLabel,
              style: font(fontSize: 12, fontWeight: FontWeight.w700, color: BazzColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Empty state widget ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  final String message;
  final IconData icon;
  const _EmptyState({
    required this.isAr,
    required this.font,
    required this.message,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(icon, size: 36, color: BazzColors.textHint),
          const SizedBox(height: 8),
          Text(message, style: font(fontSize: 13, color: BazzColors.textSecondary)),
        ],
      ),
    );
  }
}

// ─── This Month Performance card ──────────────────────────────────────────────
class _PerformanceCard extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  final int delivered;
  final int pending;
  final int cancelled;
  const _PerformanceCard({
    required this.isAr,
    required this.font,
    required this.delivered,
    required this.pending,
    required this.cancelled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: BazzColors.accent,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: BazzColors.accent.withOpacity(0.3),
              blurRadius: 16,
              offset: const Offset(0, 6))
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'إحصائيات الطلبات' : 'Order Statistics',
                style: font(
                    fontSize: 15, fontWeight: FontWeight.w800, color: BazzColors.primary),
              ),
              const Text('🚀', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            delivered > 0
                ? (isAr ? 'أنت تؤدي بشكل رائع! 🎉' : "You're doing great! 🎉")
                : (isAr ? 'ابدأ أول طلب لك اليوم!' : 'Start your first order today!'),
            style: font(fontSize: 12, color: const Color(0xFF0D2347)),
          ),
          const SizedBox(height: 16),
          // 3 stat boxes
          Row(
            children: [
              Expanded(
                child: _PerfBox(
                  icon: '✅',
                  value: '$delivered',
                  label: isAr ? 'تم التوصيل' : 'Delivered',
                  font: font,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PerfBox(
                  icon: '⏳',
                  value: '$pending',
                  label: isAr ? 'قيد الانتظار' : 'Pending',
                  font: font,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PerfBox(
                  icon: '❌',
                  value: '$cancelled',
                  label: isAr ? 'ملغاة' : 'Cancelled',
                  font: font,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PerfBox extends StatelessWidget {
  final String icon, value, label;
  final Color? iconColor;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _PerfBox({
    required this.icon,
    required this.value,
    required this.label,
    required this.font,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFFFED4D).withOpacity(0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(icon, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(value,
              style: font(fontSize: 18, fontWeight: FontWeight.w800, color: BazzColors.primary)),
          Text(label, style: font(fontSize: 10, color: const Color(0xFF0D2347))),
        ],
      ),
    );
  }
}

// ─── Header line painter ──────────────────────────────────────────────────────
class _HeaderLinePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.07)
      ..strokeWidth = 1.2;
    const spacing = 22.0;
    final count = (size.width + size.height) ~/ spacing + 2;
    for (int i = -2; i < count; i++) {
      final x = i * spacing;
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_HeaderLinePainter old) => false;
}
