import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _period = 'month';
  int _chartType = 0; // 0=bar, 1=line, 2=pie

  BarChartGroupData _bar(int x, double y, Color color) => BarChartGroupData(x: x, barRods: [
    BarChartRodData(
        toY: y,
        color: color,
        width: 22,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
  ]);

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    final periods = [
      ('today', isAr ? 'اليوم' : 'Today'),
      ('week', isAr ? 'أسبوع' : 'Week'),
      ('month', isAr ? 'شهر' : 'Month'),
      ('year', isAr ? 'سنة' : 'Year'),
      ('custom', isAr ? 'مخصص' : 'Custom'),
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
          onPressed: () => context.go('/home'),
        ),
        title: Column(
          children: [
            Text(
              isAr ? 'التقارير والتحليلات' : 'Reports & Analytics',
              style: font(
                  fontSize: 17, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
            ),
            Text(
              'Dec 15, 2024',
              style: font(fontSize: 11, color: BazzColors.textSecondary),
            ),
          ],
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
      body: SingleChildScrollView(
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
                      onTap: () => setState(() => _period = p.$1),
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

            // This Month Overview card
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Header row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isAr ? 'نظرة عامة لهذا الشهر' : 'This Month Overview',
                        style: font(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: BazzColors.textPrimary),
                      ),
                      Row(children: [
                        const Icon(Icons.calendar_today_outlined,
                            size: 14, color: BazzColors.textHint),
                        const SizedBox(width: 4),
                        Text(
                          isAr ? 'ديسمبر 2024' : 'December 2024',
                          style: font(fontSize: 11, color: BazzColors.textSecondary),
                        ),
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
                    '248',
                    style: font(
                        fontSize: 44, fontWeight: FontWeight.w800, color: BazzColors.primary),
                  ),
                  // Growth indicator
                  Text(
                    isAr ? '↑ +12% مقارنة بنوفمبر' : '↑ +12% vs November',
                    style: font(fontSize: 12, color: BazzColors.success),
                  ),
                  const SizedBox(height: 20),
                  // 3 stats row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _MonthStat(
                        icon: Icons.check_circle_rounded,
                        iconColor: BazzColors.success,
                        value: '232',
                        label: isAr ? 'تم التوصيل' : 'Delivered',
                        subLabel: '93.5%',
                        subColor: BazzColors.success,
                        font: font,
                      ),
                      Container(width: 1, height: 50, color: BazzColors.divider),
                      _MonthStat(
                        icon: Icons.cancel_rounded,
                        iconColor: BazzColors.error,
                        value: '16',
                        label: isAr ? 'ملغاة' : 'Cancelled',
                        subLabel: '6.5%',
                        subColor: BazzColors.error,
                        font: font,
                      ),
                      Container(width: 1, height: 50, color: BazzColors.divider),
                      _MonthStat(
                        icon: Icons.bolt_rounded,
                        iconColor: BazzColors.accent,
                        value: '42m',
                        label: isAr ? 'متوسط التوصيل' : 'Avg Delivery',
                        subLabel: isAr ? '↓ 8 دقائق أسرع' : '↓ 8min faster',
                        subColor: BazzColors.success,
                        font: font,
                      ),
                    ],
                  ),
                ],
              ),
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

            // Orders Overview section with chart toggle
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'نظرة عامة على الطلبات' : 'Orders Overview',
                  style: font(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: BazzColors.textPrimary),
                ),
                Row(children: [
                  _ChartToggleBtn(
                    icon: Icons.bar_chart_rounded,
                    selected: _chartType == 0,
                    onTap: () => setState(() => _chartType = 0),
                  ),
                  const SizedBox(width: 4),
                  _ChartToggleBtn(
                    icon: Icons.show_chart_rounded,
                    selected: _chartType == 1,
                    onTap: () => setState(() => _chartType = 1),
                  ),
                  const SizedBox(width: 4),
                  _ChartToggleBtn(
                    icon: Icons.pie_chart_rounded,
                    selected: _chartType == 2,
                    onTap: () => setState(() => _chartType = 2),
                  ),
                ]),
              ],
            ),
            const SizedBox(height: 12),

            // Bar chart
            Container(
              height: 180,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 2))
                ],
              ),
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              child: BarChart(BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: 60,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (v, _) {
                        final days = isAr
                            ? ['أح', 'إث', 'ث', 'أر', 'خ', 'ج', 'س']
                            : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
                        final i = v.toInt();
                        if (i < 0 || i >= days.length) return const SizedBox.shrink();
                        return Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(days[i],
                              style: GoogleFonts.inter(
                                  fontSize: 10, color: BazzColors.textHint)),
                        );
                      },
                    ),
                  ),
                ),
                gridData: FlGridData(
                  drawHorizontalLine: true,
                  horizontalInterval: 20,
                  getDrawingHorizontalLine: (_) =>
                      FlLine(color: BazzColors.divider.withOpacity(0.5), strokeWidth: 1),
                  drawVerticalLine: false,
                ),
                borderData: FlBorderData(show: false),
                barGroups: [
                  _bar(0, 28, BazzColors.primary.withOpacity(0.3)),
                  _bar(1, 42, BazzColors.primary),
                  _bar(2, 35, BazzColors.primary.withOpacity(0.3)),
                  _bar(3, 55, BazzColors.primary),
                  _bar(4, 48, BazzColors.primary.withOpacity(0.3)),
                  _bar(5, 20, BazzColors.primary.withOpacity(0.3)),
                  _bar(6, 15, BazzColors.primary.withOpacity(0.3)),
                ],
              )),
            ).animate(delay: 300.ms).fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}

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
        Text(value,
            style: font(fontSize: 18, fontWeight: FontWeight.w800, color: iconColor)),
        Text(label, style: font(fontSize: 11, color: BazzColors.textSecondary)),
        Text(subLabel, style: font(fontSize: 10, color: subColor)),
      ],
    );
  }
}

class _ReportCard {
  final String emoji, title, route;
  final Color bgColor;
  const _ReportCard({
    required this.emoji,
    required this.title,
    required this.bgColor,
    required this.route,
  });
}

class _ReportCardWidget extends StatelessWidget {
  final _ReportCard card;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _ReportCardWidget({required this.card, required this.font});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.go(card.route),
      child: Container(
        decoration: BoxDecoration(
          color: card.bgColor,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
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
                    style: font(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: BazzColors.textPrimary)),
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
        child: Icon(icon,
            size: 16, color: selected ? Colors.white : BazzColors.textSecondary),
      ),
    );
  }
}
