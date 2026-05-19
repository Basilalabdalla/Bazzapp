import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../../providers/app_state.dart';
import '../../../theme/colors.dart';
import '../bazz_logo.dart';
import 'need_help_sheet.dart';

void showProfileSheet(BuildContext context) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    builder: (_) => ChangeNotifierProvider.value(
      value: context.read<AppState>(),
      child: const ProfileSheet(),
    ),
  );
}

class ProfileSheet extends StatefulWidget {
  const ProfileSheet({super.key});

  @override
  State<ProfileSheet> createState() => _ProfileSheetState();
}

class _ProfileSheetState extends State<ProfileSheet> {
  bool _notificationsEnabled = true;

  TextStyle _f(bool isAr, {FontWeight fw = FontWeight.w400, double fs = 14, Color? color}) {
    final c = color ?? BazzColors.textPrimary;
    return isAr
        ? GoogleFonts.cairo(fontWeight: fw, fontSize: fs, color: c)
        : GoogleFonts.inter(fontWeight: fw, fontSize: fs, color: c);
  }

  String _initials(String name) {
    final parts = name.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    if (parts[0].isNotEmpty) return parts[0].substring(0, parts[0].length.clamp(0, 2)).toUpperCase();
    return '?';
  }

  void _showLanguagePicker(BuildContext context, AppState appState) {
    final isAr = appState.isArabic;
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: const Color(0xFFE0E0E0), borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(height: 16),
            Text(
              isAr ? 'اختر اللغة' : 'Select Language',
              style: _f(isAr, fw: FontWeight.w800, fs: 17),
            ),
            const SizedBox(height: 16),
            _LangOption(
              label: 'English',
              selected: !isAr,
              onTap: () {
                if (isAr) appState.toggleLanguage();
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 10),
            _LangOption(
              label: 'العربية',
              selected: isAr,
              onTap: () {
                if (!isAr) appState.toggleLanguage();
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final name = appState.merchantName.isNotEmpty ? appState.merchantName : '';
    final phone = appState.merchant?.phone ?? '';
    final memberSince = appState.merchant?.memberSinceLabel ?? '';

    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Header: BazZ logo + X close
            Row(
              children: [
                const BazzLogo(fontSize: 20),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 30, height: 30,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.close, size: 16, color: BazzColors.textSecondary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Avatar + online dot
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80, height: 80,
                    decoration: BoxDecoration(
                      color: BazzColors.accent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: BazzColors.accent.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      _initials(name),
                      style: GoogleFonts.inter(
                        fontWeight: FontWeight.w800,
                        fontSize: 28,
                        color: BazzColors.primary,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 2, right: 2,
                    child: Container(
                      width: 14, height: 14,
                      decoration: BoxDecoration(
                        color: BazzColors.success,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Store name
            Center(
              child: Text(
                name,
                style: _f(isAr, fw: FontWeight.w800, fs: 18),
              ),
            ),
            const SizedBox(height: 4),

            // Phone
            if (phone.isNotEmpty)
              Center(
                child: Text(
                  phone,
                  style: _f(isAr, fs: 13, color: BazzColors.textSecondary),
                ),
              ),
            if (memberSince.isNotEmpty) ...[
              const SizedBox(height: 2),
              // Member since
              Center(
                child: Text(
                  '${isAr ? 'عضو منذ' : 'Member since'} $memberSince',
                  style: _f(isAr, fs: 12, color: BazzColors.textHint),
                ),
              ),
            ],
            const SizedBox(height: 20),

            // Menu items
            _MenuItem(
              icon: Icons.person_outline_rounded,
              iconColor: BazzColors.primary,
              label: isAr ? 'المعلومات الشخصية' : 'Personal Info',
              trailing: const Icon(Icons.chevron_right_rounded, color: BazzColors.textHint, size: 20),
              onTap: () {},
              isAr: isAr,
            ),
            _Divider(),

            _MenuItem(
              icon: Icons.settings_outlined,
              iconColor: BazzColors.primary,
              label: isAr ? 'إعدادات الحساب' : 'Account Settings',
              trailing: const Icon(Icons.chevron_right_rounded, color: BazzColors.textHint, size: 20),
              onTap: () {},
              isAr: isAr,
            ),
            _Divider(),

            _MenuItem(
              icon: Icons.shield_outlined,
              iconColor: const Color(0xFF34A853),
              label: isAr ? 'الأمان' : 'Security',
              subtitle: isAr ? 'التحقق الثنائي، كلمة المرور' : '2FA, Password',
              trailing: const Icon(Icons.chevron_right_rounded, color: BazzColors.textHint, size: 20),
              onTap: () {},
              isAr: isAr,
            ),
            _Divider(),

            _MenuItem(
              icon: Icons.language_rounded,
              iconColor: const Color(0xFFF4A923),
              label: isAr ? 'اللغة' : 'Language',
              trailing: Text(
                isAr ? 'العربية' : 'English',
                style: _f(isAr, fw: FontWeight.w600, fs: 13, color: BazzColors.textSecondary),
              ),
              onTap: () => _showLanguagePicker(context, appState),
              isAr: isAr,
            ),
            _Divider(),

            _MenuItem(
              icon: Icons.notifications_outlined,
              iconColor: BazzColors.primary,
              label: isAr ? 'الإشعارات' : 'Notifications',
              trailing: Switch(
                value: _notificationsEnabled,
                onChanged: (v) => setState(() => _notificationsEnabled = v),
                activeColor: BazzColors.primary,
              ),
              onTap: () => setState(() => _notificationsEnabled = !_notificationsEnabled),
              isAr: isAr,
            ),
            _Divider(),

            _MenuItem(
              icon: Icons.help_outline_rounded,
              iconColor: BazzColors.primary,
              label: isAr ? 'المساعدة والدعم' : 'Help & Support',
              trailing: const Icon(Icons.chevron_right_rounded, color: BazzColors.textHint, size: 20),
              onTap: () => showNeedHelpSheet(context, isAr: isAr),
              isAr: isAr,
            ),
            _Divider(),

            _MenuItem(
              icon: Icons.logout_rounded,
              iconColor: BazzColors.error,
              label: isAr ? 'تسجيل الخروج' : 'Logout',
              labelColor: BazzColors.error,
              onTap: () async {
                Navigator.pop(context);
                await appState.logout();
                if (context.mounted) context.go('/login');
              },
              isAr: isAr,
            ),

            const SizedBox(height: 16),

            // Version
            Center(
              child: Text(
                'BazZ v1.0.0',
                style: _f(isAr, fs: 12, color: BazzColors.textHint),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── sub-widgets ──────────────────────────────────────────────────────

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String? subtitle;
  final Color? labelColor;
  final Widget? trailing;
  final VoidCallback onTap;
  final bool isAr;

  const _MenuItem({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.onTap,
    required this.isAr,
    this.subtitle,
    this.labelColor,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final labelStyle = isAr
        ? GoogleFonts.cairo(fontSize: 15, fontWeight: FontWeight.w600, color: labelColor ?? BazzColors.textPrimary)
        : GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600, color: labelColor ?? BazzColors.textPrimary);
    final subtitleStyle = isAr
        ? GoogleFonts.cairo(fontSize: 12, color: BazzColors.textSecondary)
        : GoogleFonts.inter(fontSize: 12, color: BazzColors.textSecondary);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 13, horizontal: 4),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: labelStyle),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(subtitle!, style: subtitleStyle),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => const Divider(height: 1, color: Color(0xFFF1F5F9));
}

class _LangOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _LangOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? BazzColors.primary.withOpacity(0.06) : const Color(0xFFF8FAFF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? BazzColors.primary : const Color(0xFFE8EDF5),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: selected ? BazzColors.primary : BazzColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (selected)
              const Icon(Icons.check_circle_rounded, color: BazzColors.primary, size: 20),
          ],
        ),
      ),
    );
  }
}
