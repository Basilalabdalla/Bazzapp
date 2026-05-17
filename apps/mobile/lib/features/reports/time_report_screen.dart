import 'dart:math' as math;
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/colors.dart';

class TimeReportScreen extends StatelessWidget {
  const TimeReportScreen({super.key});

  static const _hourlyAvg = [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0,3.2,2.8,2.5,2.2,1.8,2.0,2.3,2.6,2.9,3.1,2.4,1.9,0.0,0.0,0.0,0.0];
  static const _breakdown = [
    _TB('< 1 hour','أقل من ساعة',18,BazzColors.success),
    _TB('1–2 hours','1–2 ساعة',34,Color(0xFF22C55E)),
    _TB('2–4 hours','2–4 ساعات',31,Color(0xFFF59E0B)),
    _TB('4–6 hours','4–6 ساعات',12,Color(0xFFF97316)),
    _TB('> 6 hours','أكثر من 6',5,BazzColors.error),
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
        leading: IconButton(icon: const Icon(Icons.arrow_back_rounded, color: BazzColors.textPrimary), onPressed: () => context.go('/reports')),
        title: Text(isAr ? 'توقيت التوصيل' : 'Delivery Timing', style: font(fontSize: 17, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Speedometer
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            padding: const EdgeInsets.all(20),
            child: Column(children: [
              Text(isAr ? 'متوسط وقت التوصيل' : 'Average Delivery Time', style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              const SizedBox(height: 20),
              Center(child: CustomPaint(size: const Size(220, 120), painter: _SpeedoPainter(value: 2.4),
                child: SizedBox(width: 220, height: 120, child: Align(alignment: Alignment.bottomCenter,
                  child: Padding(padding: const EdgeInsets.only(bottom: 8), child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('2.4h', style: font(fontSize: 28, fontWeight: FontWeight.w800, color: BazzColors.textPrimary)),
                    Text(isAr ? 'معدل التوصيل' : 'Avg Delivery', style: font(fontSize: 12, color: BazzColors.textSecondary)),
                  ])))))),
            ]),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          // Breakdown
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isAr ? 'توزيع وقت التوصيل' : 'Time Breakdown', style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              const SizedBox(height: 14),
              ..._breakdown.map((b) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text(isAr ? b.labelAr : b.label, style: font(fontSize: 12, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
                  Text('${b.pct}%', style: font(fontSize: 12, fontWeight: FontWeight.w700, color: b.color)),
                ]),
                const SizedBox(height: 4),
                ClipRRect(borderRadius: BorderRadius.circular(3), child: LinearProgressIndicator(value: b.pct / 100, backgroundColor: const Color(0xFFE2E8F0), color: b.color, minHeight: 8)),
              ]))),
            ]),
          ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          // Line chart
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isAr ? 'معدل التوصيل بالساعة' : 'Avg Delivery by Hour', style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              const SizedBox(height: 14),
              SizedBox(height: 120, child: LineChart(LineChartData(
                lineTouchData: const LineTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, interval: 4, getTitlesWidget: (v, _) {
                    final i = v.toInt();
                    if (i % 4 != 0) return const SizedBox.shrink();
                    return Text('${i}h', style: GoogleFonts.inter(fontSize: 9, color: BazzColors.textHint));
                  })),
                ),
                gridData: FlGridData(drawHorizontalLine: true, horizontalInterval: 1,
                  getDrawingHorizontalLine: (_) => FlLine(color: BazzColors.divider.withOpacity(0.4), strokeWidth: 1), drawVerticalLine: false),
                borderData: FlBorderData(show: false),
                lineBarsData: [LineChartBarData(
                  spots: List.generate(24, (i) => FlSpot(i.toDouble(), _hourlyAvg[i])),
                  isCurved: true, color: BazzColors.primary, barWidth: 2.5,
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: true, gradient: LinearGradient(
                    begin: Alignment.topCenter, end: Alignment.bottomCenter,
                    colors: [BazzColors.primary.withOpacity(0.2), BazzColors.primary.withOpacity(0)],
                  )),
                )],
                minY: 0, maxY: 4,
              ))),
            ]),
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 16),
          // Heatmap
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))]),
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(isAr ? 'خريطة الحرارة' : 'Weekly Heatmap', style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
              const SizedBox(height: 14),
              _Heatmap(isAr: isAr, font: font),
            ]),
          ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }
}

class _SpeedoPainter extends CustomPainter {
  final double value;
  const _SpeedoPainter({required this.value});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height - 10;
    final r = size.width * 0.43;
    const start = math.pi;
    const sweep = math.pi;

    final bgPaint = Paint()..color = const Color(0xFFE2E8F0)..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round;
    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), start, sweep, false, bgPaint);

    final zones = [(0.0,1.0,BazzColors.success),(1.0,2.0,Color(0xFF22C55E)),(2.0,3.5,Color(0xFFF59E0B)),(3.5,5.0,Color(0xFFF97316)),(5.0,6.0,BazzColors.error)];
    for (final z in zones) {
      final zStart = start + (z.$1 / 6.0) * sweep;
      final zSweep = ((z.$2 - z.$1) / 6.0) * sweep;
      canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), zStart, zSweep, false,
        Paint()..color = z.$3.withOpacity(0.3)..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.butt);
    }

    final valSweep = (value / 6.0).clamp(0.0, 1.0) * sweep;
    Color valColor = BazzColors.success;
    if (value >= 5) valColor = BazzColors.error;
    else if (value >= 3.5) valColor = const Color(0xFFF97316);
    else if (value >= 2) valColor = const Color(0xFFF59E0B);

    canvas.drawArc(Rect.fromCircle(center: Offset(cx, cy), radius: r), start, valSweep, false,
      Paint()..color = valColor..style = PaintingStyle.stroke..strokeWidth = 14..strokeCap = StrokeCap.round);

    final angle = start + valSweep;
    final nx = cx + r * math.cos(angle);
    final ny = cy + r * math.sin(angle);
    canvas.drawCircle(Offset(nx, ny), 7, Paint()..color = valColor);
    canvas.drawCircle(Offset(nx, ny), 4, Paint()..color = Colors.white);
  }

  @override
  bool shouldRepaint(_) => false;
}

class _Heatmap extends StatelessWidget {
  final bool isAr;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _Heatmap({required this.isAr, required this.font});

  static const _data = [[1,2,3,4],[4,5,4,3],[3,4,5,4],[4,5,5,4],[3,4,4,3],[2,3,2,1],[1,2,1,0]];

  @override
  Widget build(BuildContext context) {
    final days = isAr ? ['أح','إث','ث','أر','خ','ج','س'] : ['Sun','Mon','Tue','Wed','Thu','Fri','Sat'];
    final periods = isAr ? ['صباح','ضهر','مساء','ليل'] : ['Morn','Noon','Eve','Night'];

    return Column(children: [
      Row(children: [
        const SizedBox(width: 36),
        ...periods.map((p) => Expanded(child: Text(p, style: font(fontSize: 9, color: BazzColors.textHint), textAlign: TextAlign.center))),
      ]),
      const SizedBox(height: 6),
      ...List.generate(7, (day) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Row(children: [
        SizedBox(width: 36, child: Text(days[day], style: font(fontSize: 10, color: BazzColors.textHint))),
        ..._data[day].map((v) => Expanded(child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 2), height: 24,
          decoration: BoxDecoration(color: BazzColors.primary.withOpacity(v == 0 ? 0.05 : v / 5.0), borderRadius: BorderRadius.circular(4)),
        ))),
      ]))),
      const SizedBox(height: 8),
      Row(mainAxisAlignment: MainAxisAlignment.end, children: [
        Text(isAr ? 'قليل' : 'Low', style: font(fontSize: 10, color: BazzColors.textHint)),
        const SizedBox(width: 4),
        ...List.generate(5, (i) => Container(width: 14, height: 14, margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(color: BazzColors.primary.withOpacity((i + 1) / 5.0), borderRadius: BorderRadius.circular(3)))),
        const SizedBox(width: 4),
        Text(isAr ? 'كثير' : 'High', style: font(fontSize: 10, color: BazzColors.textHint)),
      ]),
    ]);
  }
}

class _TB { final String label, labelAr; final int pct; final Color color; const _TB(this.label, this.labelAr, this.pct, this.color); }