import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/reports_service.dart';
import '../../theme/colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod _period = ReportPeriod.month;
  int _chartType = 0; // 0=bar, 1=line, 2=pie

  ReportSummary? _summary;
  List<ChartPoint>? _chartData;
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
        ReportsService.instance.getSummary(_period),
        ReportsService.instance.getOrdersChart(_period),
      ]);
      if (!mounted) return;
      setState(() {
        _summary = results[0] as ReportSummary;
        _chartData = results[1] as List<ChartPoint>;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _setPeriod(ReportPeriod p) {
    if (_period == p) return;
    setState(() => _period = p);
    _loadData();
  }

  String _periodLabel(bool isAr) {
    final now = DateTime.now();
    switch (_period) {
      case ReportPeriod.today:
        return isAr ? 'اليوم' : 'Today';
      case ReportPeriod.week:
        return isAr ? 'آخر 7 أيام' : 'Last 7 Days';
      case ReportPeriod.month:
        final months = isAr
            ? ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر']
            : ['January','February','March','April','May','June','July','August','September','October','November','December'];
        return '${months[now.month - 1]} ${now.year}';
      case ReportPeriod.year:
        return '${now.year}';
    }
  }

  String get _todayStr {
    final now = DateTime.now();
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[now.month - 1]} ${now.day}, ${now.year}';
  }

  BarChartGroupData _bar(int x, double y, Color color) => BarChartGroupData(
    x: x,
    barRods: [BarChartRodData(toY: y, color: color, width: 22, borderRadius: const BorderRadius.vertical(top: Radius.circular(6)))],
  );

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    final periods = [
      (ReportPeriod.today, isAr ? 'اليوم' : 'Today'),
      (ReportPeriod.week, isAr ? 'أسبوع' : 'Week'),
      (ReportPeriod.month, isAr ? 'شهر' : 'Month'),
      (ReportPeriod.year, isAr ? 'سنة' : 'Year'),
    ];

    final reportCards = [
      _ReportCard(
        emoji: '📦',
        title: isAr ? 'تقرير الطلبات' : 'Orders Report',
        bgColor: const Color(0xFFFFF8F0),
        route: '/reports/orders',
      ),
      _ReportCard(
        emoji: '🚗',
        title: isAr ? 'تقرير السائقين' : 'Drivers Report',
        bgColor: const Color(0xFFF0FFF4),
        route: '/reports/drivers',
      ),
      _ReportCard(
        emoji: '📍',
        title: isAr ? 'تقرير المناطق' : 'Areas Report',
        bgColor: const Color(0xFFFFFDE7),
        route: '/reports/areas',
      ),
      _ReportCard(
        emoji: '⏱',
        title: isAr ? 'تحليل الوقت' : 'Time Analysis',
        bgColor: const Color(0xFFFFF0F0),
        route: '/reports/time',
      ),
    ];

    return Scaffold(
      backgroundColor: BazzColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: BazzColors.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/home'),
        ),
        title: Column(
          children: [
            Text(
              isAr ? 'التقارير والتحليلات' : 'Reports & Analytics',
              style: font(fontSize: 17, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
            ),
            Text(
              _todayStr,
              style: font(fontSize: 11, color: BazzColors.textSecondary),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: _loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: BazzColors.textSecondary),
                  )
                : const Icon(Icons.refresh_rounded, color: BazzColors.textSecondary),
            onPressed: _loading ? null : _loadData,
            tooltip: isAr ? 'تحديث' : 'Refresh',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadData,
        color: BazzColors.primary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period filter chips
              SizedBox(
                height: 36,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: periods.map((p) {
                    final sel = _period == p.$1;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => _setPeriod(p.$1),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? BazzColors.accent : Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: sel ? BazzColors.accent : BazzColors.divider),
                          ),
                          child: Text(
                            p.$2,
                            style: font(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: sel ? BazzColors.primary : BazzColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ).animate().fadeIn(duration: 300.ms),

              const SizedBox(height: 16),

              // Overview card
              if (_loading)
                _OverviewSkeleton()
              else if (_error != null)
                _ErrorCard(isAr: isAr, font: font)
              else
                _OverviewCard(
                  isAr: isAr,
                  font: font,
                  summary: _summary!,
                  periodLabel: _periodLabel(isAr),
                ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

              const SizedBox(height: 24),

              // 2×2 Report cards grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.3,
                ),
                itemCount: reportCards.length,
                itemBuilder: (_, i) => _ReportCardWidget(card: reportCards[i], font: font)
                    .animate(delay: (i * 80 + 200).ms)
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.1, end: 0),
              ),

              const SizedBox(height: 24),

              // Orders Overview chart
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'نظرة عامة على الطلبات' : 'Orders Overview',
                    style: font(fontSize: 15, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
                  ),
                  Row(children: [
                    _ChartToggleBtn(icon: Icons.bar_chart_rounded, selected: _chartType == 0, onTap: () => setState(() => _chartType = 0)),
                    const SizedBox(width: 4),
                    _ChartToggleBtn(icon: Icons.show_chart_rounded, selected: _chartType == 1, onTap: () => setState(() => _chartType = 1)),
                    const SizedBox(width: 4),
                    _ChartToggleBtn(icon: Icons.pie_chart_rounded, selected: _chartType == 2, onTap: () => setState(() => _chartType = 2)),
                  ]),
                ],
              ),
              const SizedBox(height: 12),

              Container(
                height: 180,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                child: _loading
                    ? const Center(child: CircularProgressIndicator(strokeWidth: 2, color: BazzColors.primary))
                    : (_chartData == null || _chartData!.isEmpty)
                        ? Center(child: Text(isAr ? 'لا توجد بيانات' : 'No data', style: font(fontSize: 13, color: BazzColors.textHint)))
                        : _buildChart(isAr, font),
              ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChart(bool isAr, TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font) {
    final points = _chartData!;
    final maxY = points.map((p) => p.total.toDouble()).fold(0.0, (a, b) => a > b ? a : b);
    final chartMax = maxY < 5 ? 5.0 : (maxY * 1.3).ceilToDouble();

    // Use last N points to keep chart readable
    final displayPoints = points.length > 7 ? points.sublist(points.length - 7) : points;

    return BarChart(BarChartData(
      alignment: BarChartAlignment.spaceAround,
      maxY: chartMax,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
          getTooltipItem: (group, groupIndex, rod, rodIndex) {
            final p = displayPoints[group.x];
            return BarTooltipItem(
              '${p.total}',
              GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white),
            );
          },
        ),
      ),
      titlesData: FlTitlesData(
        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            getTitlesWidget: (v, _) {
              final i = v.toInt();
              if (i < 0 || i >= displayPoints.length) return const SizedBox.shrink();
              final date = displayPoints[i].date; // "2024-12-15"
              final parts = date.split('-');
              if (parts.length < 3) return const SizedBox.shrink();
              final label = _period == ReportPeriod.today
                  ? '${parts[2]}/${parts[1]}'
                  : _period == ReportPeriod.year
                      ? _monthShort(int.tryParse(parts[1]) ?? 1, isAr)
                      : '${int.tryParse(parts[2]) ?? parts[2]}';
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(label, style: GoogleFonts.inter(fontSize: 10, color: BazzColors.textHint)),
              );
            },
          ),
        ),
      ),
      gridData: FlGridData(
        drawHorizontalLine: true,
        horizontalInterval: chartMax / 4,
        getDrawingHorizontalLine: (_) => FlLine(color: BazzColors.divider.withOpacity(0.5), strokeWidth: 1),
        drawVerticalLine: false,
      ),
      borderData: FlBorderData(show: false),
      barGroups: displayPoints.asMap().entries.map((e) {
        final highlight = e.value.total == displayPoints.map((p) => p.total).fold(0, (a, b) => a > b ? a : b);
        return _bar(e.key, e.value.total.toDouble(),
            highlight ? BazzColors.primary : BazzColors.primary.withOpacity(0.35));
      }).toList(),
    ));
  }

  String _monthShort(int month, bool isAr) {
    final ar = ['يناير','فبراير','مارس','أبريل','مايو','يونيو','يوليو','أغسطس','سبتمبر','أكتوبر','نوفمبر','ديسمبر'];
    final en = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    if (month < 1 || month > 12) return '';
    return isAr ? ar[month - 1] : en[month - 1];
  }
}

// ─── Overview card ────────────────────────────────────────────────────────────
class _OverviewCard extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  final ReportSummary summary;
  final String periodLabel;
  const _OverviewCard({
    required this.isAr,
    required this.font,
    required this.summary,
    required this.periodLabel,
  });

  @override
  Widget build(BuildContext context) {
    final cancelRate = summary.total > 0
        ? (summary.cancelled / summary.total * 100).toStringAsFixed(1)
        : '0.0';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Header row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                isAr ? 'نظرة عامة' : 'Overview',
                style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
              ),
              Row(children: [
                const Icon(Icons.calendar_today_outlined, size: 14, color: BazzColors.textHint),
                const SizedBox(width: 4),
                Text(periodLabel, style: font(fontSize: 11, color: BazzColors.textSecondary)),
              ]),
            ],
          ),
          const SizedBox(height: 16),
          // Total orders big number
          Text(
            isAr ? 'إجمالي الطلبات' : 'Total Orders',
            style: font(fontSize: 12, color: BazzColors.textSecondary),
          ),
          const SizedBox(height: 4),
          Text(
            '${summary.total}',
            style: font(fontSize: 44, fontWeight: FontWeight.w800, color: BazzColors.primary),
          ),
          // Success rate
          if (summary.total > 0)
            Text(
              isAr
                  ? '${summary.successRate}% معدل النجاح'
                  : '${summary.successRate}% success rate',
              style: font(fontSize: 12, color: BazzColors.success),
            )
          else
            Text(
              isAr ? 'لا توجد طلبات في هذه الفترة' : 'No orders in this period',
              style: font(fontSize: 12, color: BazzColors.textSecondary),
            ),
          const SizedBox(height: 20),
          // 3 stats row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _MonthStat(
                icon: Icons.check_circle_rounded,
                iconColor: BazzColors.success,
                value: '${summary.delivered}',
                label: isAr ? 'تم التوصيل' : 'Delivered',
                subLabel: summary.total > 0 ? '${summary.successRate}%' : '-',
                subColor: BazzColors.success,
                font: font,
              ),
              Container(width: 1, height: 50, color: BazzColors.divider),
              _MonthStat(
                icon: Icons.cancel_rounded,
                iconColor: BazzColors.error,
                value: '${summary.cancelled}',
                label: isAr ? 'ملغاة' : 'Cancelled',
                subLabel: summary.total > 0 ? '$cancelRate%' : '-',
                subColor: BazzColors.error,
                font: font,
              ),
              Container(width: 1, height: 50, color: BazzColors.divider),
              _MonthStat(
                icon: Icons.local_shipping_rounded,
                iconColor: BazzColors.accent,
                value: '${summary.inDelivery + summary.processing + summary.pending}',
                label: isAr ? 'قيد التنفيذ' : 'In Progress',
                subLabel: isAr ? 'نشط' : 'active',
                subColor: BazzColors.accent,
                font: font,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Overview skeleton ────────────────────────────────────────────────────────
class _OverviewSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
    ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.white54);
  }
}

// ─── Error card ───────────────────────────────────────────────────────────────
class _ErrorCard extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _ErrorCard({required this.isAr, required this.font});

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
          const Icon(Icons.wifi_off_rounded, size: 36, color: BazzColors.textHint),
          const SizedBox(height: 12),
          Text(
            isAr ? 'تعذّر تحميل البيانات' : 'Failed to load',
            style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            isAr ? 'اسحب للأسفل لإعادة المحاولة' : 'Pull down to retry',
            style: font(fontSize: 12, color: BazzColors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ─── Month stat item ──────────────────────────────────────────────────────────
class _MonthStat extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value, label, subLabel;
  final Color subColor;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _MonthStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.subLabel,
    required this.subColor,
    required this.font,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 20),
        const SizedBox(height: 4),
        Text(value, style: font(fontSize: 18, fontWeight: FontWeight.w800, color: iconColor)),
        Text(label, style: font(fontSize: 11, color: BazzColors.textSecondary)),
        Text(subLabel, style: font(fontSize: 10, color: subColor)),
      ],
    );
  }
}

// ─── Report nav card ──────────────────────────────────────────────────────────
class _ReportCard {
  final String emoji, title, route;
  final Color bgColor;
  const _ReportCard({required this.emoji, required this.title, required this.bgColor, required this.route});
}

class _ReportCardWidget extends StatelessWidget {
  final _ReportCard card;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _ReportCardWidget({required this.card, required this.font});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(card.route),
      child: Container(
        decoration: BoxDecoration(
          color: card.bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(card.emoji, style: const TextStyle(fontSize: 28)),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(card.title,
                    style: font(fontSize: 13, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                const SizedBox(height: 2),
                Text(
                  'Tap to view',
                  style: font(fontSize: 11, color: BazzColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Chart toggle button ──────────────────────────────────────────────────────
class _ChartToggleBtn extends StatelessWidget {
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  const _ChartToggleBtn({required this.icon, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: selected ? BazzColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: selected ? BazzColors.primary : BazzColors.divider),
        ),
        child: Icon(icon, size: 16, color: selected ? Colors.white : BazzColors.textSecondary),
      ),
    );
  }
}
