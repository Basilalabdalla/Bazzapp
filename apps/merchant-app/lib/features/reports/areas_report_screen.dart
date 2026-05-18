import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/colors.dart';

class AreasReportScreen extends StatefulWidget {
  const AreasReportScreen({super.key});
  @override
  State<AreasReportScreen> createState() => _AreasReportScreenState();
}

class _AreasReportScreenState extends State<AreasReportScreen> {
  int? _expanded;

  static const _areas = [
    _A('Amman', 'عمّان', 142, 94, [_SA('West Amman','غرب عمان',58),_SA('East Amman','شرق عمان',45),_SA('Abdoun','عبدون',39)]),
    _A('Zarqa', 'الزرقاء', 67, 91, [_SA('Downtown','وسط المدينة',38),_SA('Industrial','المنطقة الصناعية',29)]),
    _A('Irbid', 'إربد', 43, 89, [_SA('City Center','وسط المدينة',25),_SA('Al-Yarmouk','اليرموك',18)]),
    _A('Aqaba', 'العقبة', 22, 95, [_SA('Downtown','وسط المدينة',14),_SA('Industrial','المنطقة الصناعية',8)]),
    _A('Madaba', 'مادبا', 10, 87, [_SA('City Center','وسط المدينة',10)]),
  ];

  static const _colors = [BazzColors.primary, Color(0xFF0891B2), Color(0xFF7C3AED), BazzColors.success, Color(0xFFF59E0B)];

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
        title: Text(isAr ? 'تحليل المناطق' : 'Areas Analysis', style: font(fontSize: 17, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Progress bars
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isAr ? 'طلبات حسب المحافظة' : 'Orders by Governorate', style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              const SizedBox(height: 16),
              ..._areas.map((a) => Padding(padding: const EdgeInsets.only(bottom: 12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(isAr ? a.nameAr : a.name, style: font(fontSize: 12, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
                  Text('${a.orders}', style: font(fontSize: 12, fontWeight: FontWeight.w700, color: BazzColors.primary)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: a.orders / 150, backgroundColor: const Color(0xFFE2E8F0), color: BazzColors.primary, minHeight: 8)),
              ]))),
            ]),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          // Donut
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isAr ? 'توزيع الطلبات' : 'Distribution', style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              const SizedBox(height: 14),
              Row(children: [
                SizedBox(width: 120, height: 120, child: PieChart(PieChartData(
                  sections: _areas.asMap().entries.map((e) => PieChartSectionData(color: _colors[e.key], value: e.value.orders.toDouble(), title: '', radius: 36)).toList(),
                  centerSpaceRadius: 30,
                ))),
                const SizedBox(width: 16),
                Expanded(child: Column(children: _areas.asMap().entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: _colors[e.key], shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Expanded(child: Text(isAr ? e.value.nameAr : e.value.name, style: font(fontSize: 11, color: BazzColors.textSecondary))),
                  Text('${e.value.orders}', style: font(fontSize: 11, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                ]))).toList())),
              ]),
            ]),
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 20),
          Text(isAr ? 'تفاصيل المناطق' : 'Area Details', style: font(fontSize: 15, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
          const SizedBox(height: 10),
          ...List.generate(_areas.length, (i) {
            final a = _areas[i]; final exp = _expanded == i;
            return Padding(padding: const EdgeInsets.only(bottom: 10), child: GestureDetector(
              onTap: () => setState(() => _expanded = exp ? null : i),
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: exp ? BazzColors.primary.withOpacity(0.3) : BazzColors.divider),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)]),
                child: Column(children: [
                  Padding(padding: const EdgeInsets.all(14), child: Row(children: [
                    Container(width: 40, height: 40,
                      decoration: BoxDecoration(color: BazzColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: const Icon(Icons.location_city_rounded, color: BazzColors.primary, size: 20)),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(isAr ? a.nameAr : a.name, style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                      Text('${a.orders} ${isAr ? 'طلب' : 'orders'} · ${a.successRate}%', style: font(fontSize: 12, color: BazzColors.textSecondary)),
                    ])),
                    Icon(exp ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: BazzColors.textHint),
                  ])),
                  if (exp) Container(padding: const EdgeInsets.fromLTRB(14, 0, 14, 14), child: Column(children: [
                    const Divider(color: BazzColors.divider),
                    ...a.subAreas.map((sub) => Padding(padding: const EdgeInsets.only(top: 8), child: Row(children: [
                      const Icon(Icons.subdirectory_arrow_right_rounded, color: BazzColors.textHint, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(isAr ? sub.nameAr : sub.name, style: font(fontSize: 13, color: BazzColors.textPrimary))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: BazzColors.primary.withOpacity(0.08), borderRadius: BorderRadius.circular(20)),
                        child: Text('${sub.orders}', style: font(fontSize: 12, fontWeight: FontWeight.w700, color: BazzColors.primary))),
                    ]))),
                  ])),
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

class _A { final String name, nameAr; final int orders, successRate; final List<_SA> subAreas; const _A(this.name, this.nameAr, this.orders, this.successRate, this.subAreas); }
class _SA { final String name, nameAr; final int orders; const _SA(this.name, this.nameAr, this.orders); }