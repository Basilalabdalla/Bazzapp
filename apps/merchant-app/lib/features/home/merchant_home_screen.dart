import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../shared/models/order.dart';
import '../../shared/widgets/bazz_logo.dart';
import '../../shared/widgets/bottom_sheets/profile_sheet.dart';
import '../../theme/colors.dart';

class MerchantHomeScreen extends StatefulWidget {
  const MerchantHomeScreen({super.key});

  @override
  State<MerchantHomeScreen> createState() => _MerchantHomeScreenState();
}

class _MerchantHomeScreenState extends State<MerchantHomeScreen> {
  int _navIndex = 0;

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

    final activeCount = appState.localOrders
            .where((o) => o.status == OrderStatus.pending)
            .length +
        mockOrders
            .where((o) =>
                o.status == OrderStatus.inDelivery ||
                o.status == OrderStatus.pending ||
                o.status == OrderStatus.processing)
            .length;

    return Scaffold(
      backgroundColor: BazzColors.surface,
      body: _HomeBody(isAr: isAr, font: font),
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

// ─── Home Body ───────────────────────────────────────────────────────────────
class _HomeBody extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _HomeBody({required this.isAr, required this.font});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Navy header card
        SliverToBoxAdapter(child: _HeaderCard(isAr: isAr, font: font)),

        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Stats card
              _StatsCard(isAr: isAr, font: font)
                  .animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),

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
              _ActiveOrdersSection(isAr: isAr, font: font),

              const SizedBox(height: 24),

              // Recent Deliveries section
              _RecentDeliveriesSection(isAr: isAr, font: font),

              const SizedBox(height: 20),

              // This Month Performance card
              _PerformanceCard(isAr: isAr, font: font)
                  .animate(delay: 400.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }
}

// ─── Header card (navy gradient, rounded bottom) ─────────────────────────────
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
          ],      // Stack children
        ),        // Stack
      ),          // ClipRRect
    );            // Container
  }
}

// ─── Stats card (two columns, one card) ──────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _StatsCard({required this.isAr, required this.font});

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
            // Left stat: Delivered This Month
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isAr ? 'التوصيل هذا الشهر' : 'Delivered This Month',
                    style: font(fontSize: 12, color: BazzColors.textSecondary),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '248',
                    style: font(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: BazzColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr ? '↑ 12% مقارنة بالشهر الماضي' : '↑ 12% vs last month',
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
                    '312',
                    style: font(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: BazzColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    isAr ? 'هذا الشهر' : 'This Month',
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
  const _ActiveOrdersSection({required this.isAr, required this.font});

  @override
  Widget build(BuildContext context) {
    final orders = [
      _ActiveOrder(
        id: '#BZ-2401',
        status: isAr ? 'قيد التوصيل' : 'In Delivery',
        location: isAr ? 'عمان، عبدون' : 'Amman, Abdoun',
        time: '2:30 PM',
        driver: isAr ? 'محمد أ.' : 'Mohammed A.',
        isInDelivery: true,
      ),
      _ActiveOrder(
        id: '#BZ-2402',
        status: isAr ? 'قيد المعالجة' : 'Processing',
        location: isAr ? 'عمان، الصويفية' : 'Amman, Swefieh',
        time: '1:15 PM',
        driver: isAr ? 'أحمد ك.' : 'Ahmad K.',
        isInDelivery: false,
      ),
    ];

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
        SizedBox(
          height: 170,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: orders.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (_, i) => _ActiveOrderCard(order: orders[i], font: font),
          ),
        ),
      ],
    );
  }
}

class _ActiveOrder {
  final String id, status, location, time, driver;
  final bool isInDelivery;
  const _ActiveOrder({
    required this.id,
    required this.status,
    required this.location,
    required this.time,
    required this.driver,
    required this.isInDelivery,
  });
}

class _ActiveOrderCard extends StatelessWidget {
  final _ActiveOrder order;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _ActiveOrderCard({required this.order, required this.font});

  @override
  Widget build(BuildContext context) {
    final borderColor = order.isInDelivery ? BazzColors.accent : BazzColors.primary;
    final chipBg = order.isInDelivery ? BazzColors.accent : BazzColors.primary;
    final chipText = order.isInDelivery ? BazzColors.primary : Colors.white;

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
              Text(order.id,
                  style: font(
                      fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: chipBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(order.status,
                    style: font(fontSize: 10, fontWeight: FontWeight.w700, color: chipText)),
              ),
            ],
          ),
          // Location
          Row(children: [
            const Text('📍', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Expanded(
                child: Text(order.location,
                    style: font(fontSize: 12, color: BazzColors.textSecondary),
                    overflow: TextOverflow.ellipsis)),
          ]),
          // Time
          Row(children: [
            const Text('🕐', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Text(order.time, style: font(fontSize: 12, color: BazzColors.textSecondary)),
          ]),
          // Driver
          Row(children: [
            const Text('🚚', style: TextStyle(fontSize: 12)),
            const SizedBox(width: 4),
            Expanded(
                child: Text(order.driver,
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
  const _RecentDeliveriesSection({required this.isAr, required this.font});

  @override
  Widget build(BuildContext context) {
    final deliveries = [
      _Delivery(id: '#BZ-2398', location: isAr ? 'عمان، خلدا' : 'Amman, Khalda', date: 'Dec 12', items: 3),
      _Delivery(id: '#BZ-2395', location: isAr ? 'عمان، شارع مكة' : 'Amman, Mecca St.', date: 'Dec 11', items: 1),
      _Delivery(id: '#BZ-2391', location: isAr ? 'إربد، وسط البلد' : 'Irbid, Downtown', date: 'Dec 10', items: 5),
    ];

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
        ...deliveries.asMap().entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DeliveryTile(delivery: e.value, font: font)
                    .animate(delay: (e.key * 60 + 200).ms)
                    .fadeIn(duration: 250.ms),
              ),
            ),
      ],
    );
  }
}

class _Delivery {
  final String id, location, date;
  final int items;
  const _Delivery({required this.id, required this.location, required this.date, required this.items});
}

class _DeliveryTile extends StatelessWidget {
  final _Delivery delivery;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _DeliveryTile({required this.delivery, required this.font});

  @override
  Widget build(BuildContext context) {
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
        title: Text(delivery.id,
            style: font(fontSize: 13, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
        subtitle: Text(delivery.location,
            style: font(fontSize: 12, color: BazzColors.textSecondary)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(delivery.date, style: font(fontSize: 11, color: BazzColors.textSecondary)),
            const SizedBox(height: 2),
            Text(
              '${delivery.items} items',
              style: font(fontSize: 12, fontWeight: FontWeight.w700, color: BazzColors.accent),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── This Month Performance card ──────────────────────────────────────────────
class _PerformanceCard extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _PerformanceCard({required this.isAr, required this.font});

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
                isAr ? 'أداء هذا الشهر' : 'This Month Performance',
                style: font(
                    fontSize: 15, fontWeight: FontWeight.w800, color: BazzColors.primary),
              ),
              const Text('🚀', style: TextStyle(fontSize: 20)),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            isAr ? 'أنت تؤدي بشكل رائع! 🎉' : "You're doing great! 🎉",
            style: font(fontSize: 12, color: const Color(0xFF0D2347)),
          ),
          const SizedBox(height: 16),
          // 3 stat boxes
          Row(
            children: [
              Expanded(
                child: _PerfBox(
                  icon: '✅',
                  value: '248',
                  label: isAr ? 'تم التوصيل' : 'Delivered',
                  font: font,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PerfBox(
                  icon: '⚠️',
                  iconColor: Colors.orange,
                  value: '12',
                  label: isAr ? 'قيد الانتظار' : 'Pending',
                  font: font,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _PerfBox(
                  icon: '❌',
                  iconColor: BazzColors.error,
                  value: '3',
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
