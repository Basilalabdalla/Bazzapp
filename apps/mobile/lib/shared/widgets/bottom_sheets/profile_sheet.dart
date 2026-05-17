import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../theme/colors.dart';

void showProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    // M3 ModalBottomSheet — elevation 2, rounded top corners
    elevation: 2,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<AppState>(),
      child: const ProfileSheet(),
    ),
  );
}

class ProfileSheet extends StatelessWidget {
  const ProfileSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 20),
            width: 40, height: 4,
            decoration: BoxDecoration(color: BazzColors.divider, borderRadius: BorderRadius.circular(2)),
          ),
          Container(
            width: 72, height: 72,
            decoration: const BoxDecoration(color: BazzColors.accent, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('AN', style: GoogleFonts.inter(fontWeight: FontWeight.w800, fontSize: 26, color: BazzColors.primary)),
          ),
          const SizedBox(height: 12),
          Text(isAr ? 'متجر النور' : 'Al Noor Store',
            style: font(fontSize: 18, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
          const SizedBox(height: 4),
          Text('+962 79 123 4567', style: GoogleFonts.inter(fontSize: 13, color: BazzColors.textSecondary)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(color: BazzColors.accent, borderRadius: BorderRadius.circular(20)),
            child: Text(isAr ? '🏪 التاجر' : '🏪 Merchant',
              style: font(fontSize: 12, fontWeight: FontWeight.w700, color: BazzColors.primary)),
          ),
          const SizedBox(height: 20),
          const Divider(indent: 24, endIndent: 24),
          _tile(context, Icons.language_rounded, isAr ? 'تغيير اللغة' : 'Change Language', () {
            appState.toggleLanguage();
            Navigator.pop(context);
          }),
          _tile(context, Icons.help_outline_rounded, isAr ? 'المساعدة' : 'Help & Support', () => Navigator.pop(context)),
          _tile(context, Icons.logout_rounded, isAr ? 'تسجيل الخروج' : 'Log Out', () {
            Navigator.pop(context);
            context.go('/login');
          }, color: BazzColors.error),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _tile(BuildContext context, IconData icon, String label, VoidCallback onTap, {Color? color}) {
    final appState = context.read<AppState>();
    final tileStyle = appState.isArabic
        ? GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? BazzColors.textPrimary)
        : GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: color ?? BazzColors.textPrimary);
    return ListTile(
      leading: Icon(icon, color: color ?? BazzColors.primary, size: 24),
      title: Text(label, style: tileStyle),
      trailing: const Icon(Icons.chevron_right_rounded, color: BazzColors.textHint),
      onTap: onTap,
      minLeadingWidth: 24,
    );
  }
}