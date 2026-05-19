import 'api_client.dart';

enum ReportPeriod { today, week, month, year }

extension ReportPeriodX on ReportPeriod {
  String get apiValue => switch (this) {
        ReportPeriod.today => 'today',
        ReportPeriod.week => 'week',
        ReportPeriod.month => 'month',
        ReportPeriod.year => 'year',
      };
}

class ReportSummary {
  final int total;
  final int delivered;
  final int pending;
  final int cancelled;
  final int processing;
  final int inDelivery;
  final int successRate;

  const ReportSummary({
    required this.total,
    required this.delivered,
    required this.pending,
    required this.cancelled,
    required this.processing,
    required this.inDelivery,
    required this.successRate,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> j) => ReportSummary(
        total: j['total'] as int? ?? 0,
        delivered: j['delivered'] as int? ?? 0,
        pending: j['pending'] as int? ?? 0,
        cancelled: j['cancelled'] as int? ?? 0,
        processing: j['processing'] as int? ?? 0,
        inDelivery: j['inDelivery'] as int? ?? 0,
        successRate: j['successRate'] as int? ?? 0,
      );

  static ReportSummary empty() => const ReportSummary(
        total: 0,
        delivered: 0,
        pending: 0,
        cancelled: 0,
        processing: 0,
        inDelivery: 0,
        successRate: 0,
      );
}

class ChartPoint {
  final String date; // "2024-12-15"
  final int total;
  final int delivered;
  final int cancelled;

  const ChartPoint({
    required this.date,
    required this.total,
    required this.delivered,
    required this.cancelled,
  });

  factory ChartPoint.fromJson(Map<String, dynamic> j) => ChartPoint(
        date: j['date'] as String,
        total: j['total'] as int? ?? 0,
        delivered: j['delivered'] as int? ?? 0,
        cancelled: j['cancelled'] as int? ?? 0,
      );
}

class AreaStat {
  final String governorate;
  final int count;
  const AreaStat({required this.governorate, required this.count});

  factory AreaStat.fromJson(Map<String, dynamic> j) => AreaStat(
        governorate: j['governorate'] as String? ?? '',
        count: j['count'] as int? ?? 0,
      );
}

class ReportsService {
  ReportsService._();
  static final ReportsService instance = ReportsService._();

  final _api = ApiClient.instance;

  Future<ReportSummary> getSummary(ReportPeriod period) async {
    final res = await _api.get('/reports/summary?period=${period.apiValue}');
    return ReportSummary.fromJson(res);
  }

  Future<List<ChartPoint>> getOrdersChart(ReportPeriod period) async {
    final res = await _api.getList('/reports/orders-chart?period=${period.apiValue}');
    return res.map((e) => ChartPoint.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<AreaStat>> getAreaStats(ReportPeriod period) async {
    final res = await _api.getList('/reports/areas?period=${period.apiValue}');
    return res.map((e) => AreaStat.fromJson(e as Map<String, dynamic>)).toList();
  }
}
