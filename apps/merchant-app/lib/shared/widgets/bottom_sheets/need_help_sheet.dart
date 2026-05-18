import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../theme/colors.dart';
import '../bazz_logo.dart';

void showNeedHelpSheet(BuildContext context, {required bool isAr}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => NeedHelpSheet(isAr: isAr),
  );
}

class NeedHelpSheet extends StatelessWidget {
  final bool isAr;
  const NeedHelpSheet({super.key, required this.isAr});

  TextStyle _f({FontWeight fw = FontWeight.w400, double fs = 14, Color? color}) {
    final c = color ?? BazzColors.textPrimary;
    return isAr
        ? GoogleFonts.cairo(fontWeight: fw, fontSize: fs, color: c)
        : GoogleFonts.inter(fontWeight: fw, fontSize: fs, color: c);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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

            // Header: logo + title + X
            Row(
              children: [
                const BazzLogo(fontSize: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    isAr ? 'كيف يمكننا مساعدتك؟' : 'How can we help?',
                    style: _f(fw: FontWeight.w800, fs: 17, color: BazzColors.textPrimary),
                  ),
                ),
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

            // Contact Us + WhatsApp Us
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Contact Us — navy card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => launchUrl(Uri.parse('tel:+966110000000')), // TODO: backend number
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: BazzColors.primary,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.phone_outlined, color: Colors.white, size: 20),
                            ),
                            const SizedBox(height: 12),
                            Text(isAr ? 'اتصل بنا' : 'Contact Us',
                                style: _f(fw: FontWeight.w800, fs: 14, color: Colors.white)),
                            const SizedBox(height: 4),
                            Text(isAr ? 'فريقنا متاح' : 'Our team is online',
                                style: _f(fs: 12, color: Colors.white70)),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // WhatsApp Us — green card
                  Expanded(
                    child: GestureDetector(
                      onTap: () => launchUrl( // TODO: backend number
                        Uri.parse('https://wa.me/966500000000'),
                        mode: LaunchMode.externalApplication,
                      ),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F8EF),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: const Color(0xFF25D366).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const FaIcon(FontAwesomeIcons.whatsapp,
                                  color: Color(0xFF25D366), size: 20),
                            ),
                            const SizedBox(height: 12),
                            Text(isAr ? 'واتساب' : 'WhatsApp Us',
                                style: _f(fw: FontWeight.w800, fs: 14, color: Color(0xFF1B6B3A))),
                            const SizedBox(height: 4),
                            Text(
                              isAr ? 'وكلاؤنا جاهزون لمساعدتك' : 'Our agents are available to assist you',
                              style: _f(fs: 12, color: Color(0xFF4A9065)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Website section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: BazzColors.primary.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: BazzColors.primary,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.language_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(isAr ? 'الموقع الإلكتروني' : 'Website',
                                style: _f(fw: FontWeight.w800, fs: 14, color: BazzColors.textPrimary)),
                            Text(
                              isAr
                                  ? 'استعرض خدماتنا وتتبع طلباتك بسهولة'
                                  : 'Explore our services and track your deliveries easily',
                              style: _f(fs: 12, color: BazzColors.textSecondary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: BazzColors.textPrimary,
                      side: BorderSide(color: BazzColors.primary.withOpacity(0.3)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      minimumSize: const Size.fromHeight(40),
                    ),
                    onPressed: () {},
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(isAr ? 'تصفح الموقع' : 'Browse the Site',
                            style: _f(fw: FontWeight.w700, fs: 14)),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right_rounded, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Follow Us
            Center(
              child: Text(isAr ? 'تابعنا' : 'Follow Us',
                  style: _f(fw: FontWeight.w700, fs: 14, color: BazzColors.textPrimary)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                _SocialIcon(faIcon: FontAwesomeIcons.xTwitter, bg: Colors.black, fg: Colors.white),
                SizedBox(width: 10),
                _SocialIcon(faIcon: FontAwesomeIcons.instagram, bg: Color(0xFFE1306C), fg: Colors.white),
                SizedBox(width: 10),
                _SocialIcon(faIcon: FontAwesomeIcons.facebookF, bg: Color(0xFF1877F2), fg: Colors.white),
                SizedBox(width: 10),
                _SocialIcon(faIcon: FontAwesomeIcons.whatsapp, bg: Color(0xFF25D366), fg: Colors.white),
                SizedBox(width: 10),
                _SocialIcon(faIcon: FontAwesomeIcons.telegram, bg: Color(0xFF229ED9), fg: Colors.white),
              ],
            ),
            const SizedBox(height: 20),

            // Privacy Policy + App Version
            Center(
              child: Text('Privacy Policy',
                  style: _f(fw: FontWeight.w700, fs: 13, color: BazzColors.textPrimary)),
            ),
            const SizedBox(height: 4),
            Center(
              child: Text('App Version 1.0.0',
                  style: _f(fs: 12, color: BazzColors.textSecondary)),
            ),
            const SizedBox(height: 16),

            // Close button
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                foregroundColor: BazzColors.textPrimary,
                side: BorderSide(color: BazzColors.primary.withOpacity(0.2)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(48),
              ),
              onPressed: () => Navigator.of(context).pop(),
              child: Text(isAr ? 'إغلاق' : 'Close', style: _f(fw: FontWeight.w700, fs: 15)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData faIcon;
  final Color bg, fg;
  const _SocialIcon({super.key, required this.faIcon, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44, height: 44,
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Center(child: FaIcon(faIcon, color: fg, size: 20)),
    );
  }
}
