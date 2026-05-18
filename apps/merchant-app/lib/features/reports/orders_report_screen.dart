import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../shared/models/order.dart';
import '../../shared/widgets/status_badge.dart';
import '../../theme/colors.dart';

class OrdersReportScreen extends StatefulWidget {
  const OrdersReportScreen({super.key});

  @override
  State<OrdersReportScreen> createState() => _OrdersReportScreenState();
}

class _OrdersReportScreenState extends State<OrdersReportScreen> {
  int _touchedIndex = -1;

  static const _pie = [
    _PE('Delivered', 'تم التوصيل', 63, BazzColors.success),
    _PE('In Delivery', 'في الطريق', 18, BazzColors.primary),
    _PE('Cancelled', 'ملغي', 11, BazzColors.error),
    _PE('Pending', 'انتظار', 8, Color(0xFFF59E0B)),
  ];
  static const _hourly = [8.0,12.0,22.0,30.0,28.0,35.0,42.0,38.0,25.0,18.0,12.0,6.0];

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
        title: Text(isAr ? 'تقرير الطلبات' : 'Orders Report', style: font(fontSize: 17, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            _Chip('284', isAr ? 'إجمالي' : 'Total', BazzColors.primary, font),
            const SizedBox(width: 8),
            _Chip('179', isAr ? 'تم' : 'Done', BazzColors.success, font),
            const SizedBox(width: 8),
            _Chip('31', isAr ? 'ملغي' : 'Cancelled', BazzColors.error, font),
          ]).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 20),
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? 'توزيع الحالات' : 'Status Distribution', style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
            const SizedBox(height: 16),
            Row(children: [
              SizedBox(width: 140, height: 140, child: PieChart(PieChartData(
                pieTouchData: PieTouchData(touchCallback: (_, r) => setState(() => _touchedIndex = r?.touchedSection?.touchedSectionIndex ?? -1)),
                sections: List.generate(_pie.length, (i) {
                  final d = _pie[i]; final t = i == _touchedIndex;
                  return PieChartSectionData(color: d.color, value: d.pct.toDouble(),
                    title: '${d.pct}%', titleStyle: GoogleFonts.inter(fontSize: t ? 13 : 10, fontWeight: FontWeight.w700, color: Colors.white),
                    radius: t ? 56 : 48);
                }),
                centerSpaceRadius: 28,
              ))),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: _pie.map((d) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: d.color, shape: BoxShape.circle)),
                  const SizedBox(width: 8),
                  Expanded(child: Text(isAr ? d.labelAr : d.label, style: font(fontSize: 12, color: BazzColors.textSecondary))),
                  Text('${d.pct}%', style: font(fontSize: 12, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                ]),
              )).toList())),
            ]),
          ])).animate(delay: 100.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          _Card(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isAr ? 'طلبات بالساعة' : 'Orders by Hour', style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
            const SizedBox(height: 14),
            SizedBox(height: 120, child: BarChart(BarChartData(
              alignment: BarChartAlignment.spaceAround,
              barTouchData: BarTouchData(enabled: false),
              titlesData: FlTitlesData(
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, _) {
                  final hours = ['8','9','10','11','12','13','14','15','16','17','18','19'];
                  final i = v.toInt();
                  if (i < 0 || i >= hours.length) return const SizedBox.shrink();
                  return Text(hours[i], style: GoogleFonts.inter(fontSize: 9, color: BazzColors.textHint));
                })),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: List.generate(_hourly.length, (i) => BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: _hourly[i], color: BazzColors.primary.withOpacity(i == 6 ? 1 : 0.4),
                  width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(4))),
              ])),
            ))),
          ])).animate(delay: 200.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          Text(isAr ? 'آخر الطلبات' : 'Recent Orders', style: font(fontSize: 15, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
          const SizedBox(height: 10),
          ...mockOrders.map((o) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 4)]),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(children: [
              Text(o.id, style: font(fontSize: 13, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              const SizedBox(width: 8),
              Expanded(child: Text(o.recipientName, style: font(fontSize: 12, color: BazzColors.textSecondary), overflow: TextOverflow.ellipsis)),
              StatusBadge(status: o.status, isArabic: isAr),
            ]),
          ))),
        ]),
      ),
    );
  }
}

Widget _Chip(String v, String l, Color c, TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) f) => Expanded(child: Container(
  padding: const EdgeInsets.symmetric(vertical: 12),
  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 6)]),
  child: Column(children: [Text(v, style: f(fontSize: 20, fontWeight: FontWeight.w800, color: c)), Text(l, style: f(fontSize: 11, color: BazzColors.textSecondary))]),
));

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});
  @override
  Widget build(BuildContext context) => Container(width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]), padding: const EdgeInsets.all(16), child: child);
}

class _PE {
  final String label, labelAr; final int pct; final Color color;
  const _PE(this.label, this.labelAr, this.pct, this.color);
}