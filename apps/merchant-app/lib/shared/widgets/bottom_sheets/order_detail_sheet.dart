import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../shared/models/order.dart';
import '../../../theme/colors.dart';
import '../status_badge.dart';

void showOrderDetailSheet(BuildContext context, OrderModel order) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    // M3 ModalBottomSheet — elevation 2
    elevation: 2,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<AppState>(),
      child: OrderDetailSheet(order: order),
    ),
  );
}

class OrderDetailSheet extends StatelessWidget {
  final OrderModel order;
  const OrderDetailSheet({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.92,
      expand: false,
      builder: (_, ctrl) => Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 16),
            width: 40, height: 4,
            decoration: BoxDecoration(color: BazzColors.divider, borderRadius: BorderRadius.circular(2)),
          ),
          Expanded(
            child: ListView(
              controller: ctrl,
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(order.id, style: font(fontSize: 20, fontWeight: FontWeight.w800, color: BazzColors.textPrimary)),
                      const SizedBox(height: 4),
                      Text(order.createdAt, style: font(fontSize: 13, color: BazzColors.textSecondary)),
                    ]),
                    StatusBadge(status: order.status, isArabic: isAr),
                  ],
                ),
                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 16),
                _Section(title: isAr ? 'المستلم' : 'Recipient', font: font, child: Column(children: [
                  _Row(label: isAr ? 'الاسم' : 'Name', value: order.recipientName, font: font),
                  const SizedBox(height: 8),
                  _Row(label: isAr ? 'الهاتف' : 'Phone', value: order.recipientPhone, font: font),
                  const SizedBox(height: 8),
                  _Row(label: isAr ? 'العنوان' : 'Address', value: order.address, font: font),
                ])),
                const SizedBox(height: 16),
                _Section(title: isAr ? 'الطرد' : 'Package', font: font, child: Column(children: [
                  _Row(label: isAr ? 'الحجم' : 'Size', value: order.packageSize.toUpperCase(), font: font),
                  if (order.isFragile) ...[
                    const SizedBox(height: 8),
                    _Row(label: isAr ? 'هش' : 'Fragile', value: isAr ? 'نعم ⚠️' : 'Yes ⚠️', font: font, highlight: true),
                  ],
                  if (order.isCod) ...[
                    const SizedBox(height: 8),
                    _Row(label: isAr ? 'الدفع عند الاستلام' : 'COD', value: 'JOD ${order.codAmount.toStringAsFixed(2)}', font: font, highlight: true),
                  ],
                ])),
                if (order.driver != null) ...[
                  const SizedBox(height: 16),
                  _Section(title: isAr ? 'السائق' : 'Driver', font: font, child: Row(children: [
                    Container(
                      width: 44, height: 44,
                      decoration: BoxDecoration(color: BazzColors.primary.withOpacity(0.1), shape: BoxShape.circle),
                      alignment: Alignment.center,
                      child: Text(order.driver!.initials, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w800, color: BazzColors.primary)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(order.driver!.name, style: font(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
                      Text(order.driver!.phone, style: font(fontSize: 12, color: BazzColors.textSecondary)),
                    ])),
                    IconButton(icon: const Icon(Icons.call_rounded, color: BazzColors.success), onPressed: () {}),
                  ])),
                ],
                const SizedBox(height: 24),
                if (order.status == OrderStatus.pending)
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BazzColors.error,
                      side: const BorderSide(color: BazzColors.error),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    icon: const Icon(Icons.cancel_outlined, size: 18),
                    label: Text(isAr ? 'إلغاء الطلب' : 'Cancel Order', style: font(fontWeight: FontWeight.w600)),
                    onPressed: () => Navigator.pop(context),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final Widget child;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _Section({required this.title, required this.child, required this.font});

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: font(fontSize: 12, fontWeight: FontWeight.w700, color: BazzColors.textHint)),
      const SizedBox(height: 10),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: BazzColors.surface, borderRadius: BorderRadius.circular(12)),
        child: child,
      ),
    ]);
  }
}

class _Row extends StatelessWidget {
  final String label, value;
  final bool highlight;
  final TextStyle Function({double? fontSize, FontWeight? fontWeight, Color? color}) font;
  const _Row({required this.label, required this.value, required this.font, this.highlight = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: font(fontSize: 12, color: BazzColors.textSecondary)),
        Text(value, style: font(fontSize: 13, fontWeight: FontWeight.w600, color: highlight ? BazzColors.primary : BazzColors.textPrimary)),
      ],
    );
  }
}