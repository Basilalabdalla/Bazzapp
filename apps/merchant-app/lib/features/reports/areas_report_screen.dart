import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/reports_service.dart';
import '../../theme/colors.dart';

class AreasReportScreen extends StatefulWidget {
  const AreasReportScreen({super.key});
  @override
  State<AreasReportScreen> createState() => _AreasReportScreenState();
}

class _AreasReportScreenState extends State<AreasReportScreen> {
  ReportPeriod _period = ReportPeriod.month;
  List<AreaStat> _areas = [];
  bool _loading = true;
  String? _error;

  static const _colors = [
    BazzColors.primary,
    Color(0xFF0891B2),
    Color(0xFF7C3AED),
    BazzColors.success,
    Color(0xFFF59E0B),
    Color(0xFFEF4444),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final areas = await ReportsService.instance.getAreaStats(_period);
      if (!mounted) return;
      setState(() {
        _areas = areas;
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

  int get _total => _areas.fold(0, (sum, a) => sum + a.count);

  Color _colorFor(int i) => _colors[i % _colors.length];

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

    return Scaffold(
      backgroundColor: BazzColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: BazzColors.textPrimary),
          onPressed: () => context.canPop() ? context.pop() : context.go('/reports'),
        ),
        title: Text(
          isAr ? 'تحليل المناطق' : 'Areas Analysis',
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
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Period filter
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
                          child: Text(p.$2,
                              style: font(fontSize: 12, fontWeight: FontWeight.w600,
                                  color: sel ? BazzColors.primary : BazzColors.textSecondary)),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),

              if (_loading) ...[
                _skeleton(200),
                const SizedBox(height: 16),
                _skeleton(200),
              ] else if (_error != null)
                _ErrorCard(isAr: isAr, font: font)
              else if (_areas.isEmpty)
                Container(
                  padding: const EdgeInsets.all(32),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
                  child: Center(
                    child: Column(
                      children: [
                        const Icon(Icons.location_off_rounded, size: 40, color: BazzColors.textHint),
                        const SizedBox(height: 12),
                        Text(isAr ? 'لا توجد بيانات في هذه الفترة' : 'No data for this period',
                            style: font(fontSize: 14, color: BazzColors.textSecondary)),
                      ],
                    ),
                  ),
                )
              else ...[
                // Progress bars card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isAr ? 'طلبات حسب المحافظة' : 'Orders by Governorate',
                        style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
                      ),
                      const SizedBox(height: 16),
                      ..._areas.asMap().entries.map((e) {
                        final a = e.value;
                        final maxCount = _areas.first.count; // already sorted by count desc
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(a.governorate,
                                      style: font(fontSize: 12, fontWeight: FontWeight.w600, color: BazzColors.textPrimary)),
                                  Text('${a.count}',
                                      style: font(fontSize: 12, fontWeight: FontWeight.w700, color: _colorFor(e.key))),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(3),
                                child: LinearProgressIndicator(
                                  value: maxCount > 0 ? a.count / maxCount : 0,
                                  backgroundColor: const Color(0xFFE2E8F0),
                                  color: _colorFor(e.key),
                                  minHeight: 8,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 16),

                // Donut chart card
                if (_areas.length > 1)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isAr ? 'توزيع الطلبات' : 'Distribution',
                          style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            SizedBox(
                              width: 120,
                              height: 120,
                              child: PieChart(PieChartData(
                                sections: _areas.asMap().entries.map((e) => PieChartSectionData(
                                  color: _colorFor(e.key),
                                  value: e.value.count.toDouble(),
                                  title: '',
                                  radius: 36,
                                )).toList(),
                                centerSpaceRadius: 30,
                              )),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                children: _areas.asMap().entries.map((e) => Padding(
                                  padding: const EdgeInsets.only(bottom: 6),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 8, height: 8,
                                        decoration: BoxDecoration(color: _colorFor(e.key), shape: BoxShape.circle),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(e.value.governorate,
                                            style: font(fontSize: 11, color: BazzColors.textSecondary)),
                                      ),
                                      Text('${e.value.count}',
                                          style: font(fontSize: 11, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                                    ],
                                  ),
                                )).toList(),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 300.ms),

                const SizedBox(height: 20),

                // Governorate list
                Text(
                  isAr ? 'تفاصيل المناطق' : 'Area Details',
                  style: font(fontSize: 15, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
                ),
                const SizedBox(height: 10),
                ..._areas.asMap().entries.map((e) {
                  final a = e.value;
                  final pct = _total > 0 ? (a.count / _total * 100).toStringAsFixed(1) : '0';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: BazzColors.divider),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 6)],
                      ),
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        children: [
                          Container(
                            width: 40, height: 40,
                            decoration: BoxDecoration(
                              color: _colorFor(e.key).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.location_city_rounded, color: _colorFor(e.key), size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(a.governorate,
                                    style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                                Text('${a.count} ${isAr ? 'طلب' : 'orders'} · $pct%',
                                    style: font(fontSize: 12, color: BazzColors.textSecondary)),
                              ],
                            ),
                          ),
                          Text('${a.count}',
                              style: font(fontSize: 18, fontWeight: FontWeight.w800, color: _colorFor(e.key))),
                        ],
                      ),
                    ).animate(delay: (e.key * 60).ms).fadeIn(duration: 250.ms),
                  );
                }),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _skeleton(double height) => Container(
    height: height,
    decoration: BoxDecoration(color: Colors.grey.shade200, borderRadius: BorderRadius.circular(16)),
  ).animate(onPlay: (c) => c.repeat()).shimmer(duration: 1200.ms, color: Colors.white54);
}

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
          Text(isAr ? 'تعذّر تحميل البيانات' : 'Failed to load', style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
          const SizedBox(height: 4),
          Text(isAr ? 'اسحب للأسفل لإعادة المحاولة' : 'Pull down to retry', style: font(fontSize: 12, color: BazzColors.textSecondary)),
        ],
      ),
    );
  }
}
