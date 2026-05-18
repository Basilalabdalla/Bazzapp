import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../shared/models/order.dart';
import '../../theme/colors.dart';

class StatusBadge extends StatelessWidget {
  final OrderStatus status;
  final bool isArabic;

  const StatusBadge({super.key, required this.status, this.isArabic = false});

  @override
  Widget build(BuildContext context) {
    final config = _config(status);
    final textStyle = isArabic
        ? GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w700, color: config.fg)
        : GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w700, color: config.fg);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: config.bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        isArabic ? config.labelAr : config.label,
        style: textStyle,
      ),
    );
  }

  _StatusConfig _config(OrderStatus s) {
    switch (s) {
      case OrderStatus.inDelivery:
        return _StatusConfig('In Delivery', 'في الطريق', BazzColors.inDeliveryBg, BazzColors.inDeliveryText);
      case OrderStatus.processing:
        return _StatusConfig('Processing', 'قيد المعالجة', BazzColors.processingBg, BazzColors.processingText);
      case OrderStatus.pending:
        return _StatusConfig('Pending', 'قيد الانتظار', BazzColors.pendingBg, BazzColors.pendingText);
      case OrderStatus.delivered:
        return _StatusConfig('Delivered', 'تم التوصيل', BazzColors.deliveredBg, BazzColors.deliveredText);
      case OrderStatus.cancelled:
        return _StatusConfig('Cancelled', 'ملغي', BazzColors.cancelledBg, BazzColors.cancelledText);
    }
  }
}

class _StatusConfig {
  final String label, labelAr;
  final Color bg, fg;
  const _StatusConfig(this.label, this.labelAr, this.bg, this.fg);
}