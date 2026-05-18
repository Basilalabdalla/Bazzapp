import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/colors.dart';

class DriversReportScreen extends StatefulWidget {
  const DriversReportScreen({super.key});
  @override
  State<DriversReportScreen> createState() => _DriversReportScreenState();
}

class _DriversReportScreenState extends State<DriversReportScreen> {
  int? _expanded;

  static const _drivers = [
    _D('Mohammed A.', 'محمد أ.', 'MA', 4.9, 47, 96),
    _D('Ahmad K.', 'أحمد ك.', 'AK', 4.7, 41, 93),
    _D('Khalil M.', 'خليل م.', 'KM', 4.6, 38, 90),
    _D('Sami R.', 'سامي ر.', 'SR', 4.4, 29, 88),
    _D('Faisal N.', 'فيصل ن.', 'FN', 4.2, 22, 85),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    return Scaffold(
      backgroundColor: BazzColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: BazzColors.textPrimary), onPressed: () => context.canPop() ? context.pop() : context.go('/reports')),
        title: Text(isAr ? 'أداء السائقين' : 'Drivers Performance', style: font(fontSize: 17, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isAr ? 'الطلبات لكل سائق' : 'Orders per Driver', style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              const SizedBox(height: 14),
              SizedBox(height: 150, child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround, maxY: 60,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i < 0 || i >= _drivers.length) return const SizedBox.shrink();
                    return Padding(padding: const EdgeInsets.only(top: 4), child: Text(_drivers[i].initials, style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: BazzColors.textHint)));
                  })),
                ),
                gridData: FlGridData(drawHorizontalLine: true, horizontalInterval: 20, getDrawingHorizontalLine: (_) => FlLine(color: BazzColors.divider.withOpacity(0.5), strokeWidth: 1), drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                barGroups: List.generate(_drivers.length, (i) => BarChartGroupData(x: i, barRods: [
                  BarChartRodData(toY: _drivers[i].orders.toDouble(), color: i == 0 ? BazzColors.primary : BazzColors.primary.withOpacity(0.4), width: 28, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
                ])),
              ))),
            ]),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 20),
          Text(isAr ? 'تفاصيل السائقين' : 'Driver Details', style: font(fontSize: 15, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
          const SizedBox(height: 10),
          ...List.generate(_drivers.length, (i) {
            final d = _drivers[i]; final exp = _expanded == i;
            return Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(
              onTap: () => setState(() => _expanded = exp ? null : i),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: exp ? BazzColors.primary.withOpacity(0.3) : BazzColors.divider, width: exp ? 1.5 : 1),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
                child: Column(children: [
                  Padding(padding: const EdgeInsets.all(14), child: Row(children: [
                    Stack(clipBehavior: Clip.none, children: [
                      Container(width: 44, height: 44,
                        decoration: BoxDecoration(color: i == 0 ? BazzColors.accent : BazzColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                        alignment: Alignment.center,
                        child: Text(d.initials, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: BazzColors.primary))),
                      Positioned(bottom: -2, right: -2, child: Container(width: 18, height: 18,
                        decoration: BoxDecoration(color: i == 0 ? const Color(0xFFFFD700) : const Color(0xFFF1F5F9), shape: BoxShape.circle, border: Border.all(color: Colors.white, width: 1.5)),
                        alignment: Alignment.center,
                        child: Text('#${i + 1}', style: GoogleFonts.inter(fontSize: 8, fontWeight: FontWeight.w800, color: i == 0 ? BazzColors.primary : BazzColors.textHint)))),
                    ]),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(isAr ? d.nameAr : d.name, style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                      const SizedBox(height: 2),
                      Row(children: [
                        const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 14),
                        const SizedBox(width: 2),
                        Text(d.rating.toString(), style: font(fontSize: 12, fontWeight: FontWeight.w600, color: BazzColors.textSecondary)),
                        const SizedBox(width: 8),
                        Text('${d.orders} ${isAr ? 'طلب' : 'orders'}', style: font(fontSize: 12, color: BazzColors.textSecondary)),
                      ]),
                    ])),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('${d.successRate}%', style: font(fontSize: 16, fontWeight: FontWeight.w800, color: BazzColors.success)),
                      Text(isAr ? 'نجاح' : 'success', style: font(fontSize: 10, color: BazzColors.textHint)),
                    ]),
                    const SizedBox(width: 4),
                    Icon(exp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: BazzColors.textHint, size: 20),
                  ])),
                  if (exp) Container(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(children: [
                      const Divider(color: BazzColors.divider),
                      const SizedBox(height: 8),
                      SizedBox(height: 60, child: BarChart(BarChartData(
                        barTouchData: BarTouchData(enabled: false),
                        titlesData: const FlTitlesData(leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)), bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                        gridData: const FlGridData(show: false),
                        borderData: FlBorderData(show: false),
                        barGroups: [5,8,7,10,9,6,2].asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
                          BarChartRodData(toY: e.value.toDouble(), color: BazzColors.primary.withOpacity(e.key == 3 ? 1 : 0.35), width: 20, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
                        ])).toList(),
                      ))),
                    ]),
                  ),
                ]),
              ).animate(delay: (i * 60).ms).fadeIn(duration: 250.ms),
            ));
          }),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _D {
  final String name, nameAr, initials; final double rating; final int orders, successRate;
  const _D(this.name, this.nameAr, this.initials, this.rating, this.orders, this.successRate);
}