import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../shared/widgets/bazz_logo.dart';
import '../../shared/widgets/lang_toggle.dart';
import '../../theme/colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _role = 'driver';

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    return Scaffold(
      backgroundColor: BazzColors.surface,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          SafeArea(
            child: Column(
              children: [
                // Top bar — 24dp horizontal margin per spec
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 60),
                      const BazzLogo(fontSize: 28),
                      const LangToggle(),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    // Spec: 24dp outer horizontal margins
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 32),
                        Text(isAr ? 'أهلاً بك' : 'Welcome',
                          style: font(fontSize: 32, fontWeight: FontWeight.w800, color: BazzColors.textPrimary),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 400.ms, delay: 100.ms).slideY(begin: 0.2, end: 0),
                        const SizedBox(height: 8),
                        Text(isAr ? 'تسجيل الدخول إلى حسابك' : 'Login to your BazZ account',
                          style: font(fontSize: 15, color: BazzColors.textSecondary),
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
                        const SizedBox(height: 40),
                        // M3 SegmentedButton for role selection
                        Container(
                          decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(16)),
                          padding: const EdgeInsets.all(4),
                          child: Row(children: [
                            _RoleTab(label: isAr ? 'السائق' : 'Driver', emoji: '🚚', selected: _role == 'driver', onTap: () => setState(() => _role = 'driver')),
                            _RoleTab(label: isAr ? 'التاجر' : 'Merchant', emoji: '🏪', selected: _role == 'merchant', onTap: () => setState(() => _role = 'merchant')),
                          ]),
                        ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
                        const SizedBox(height: 32),
                        // M3 FilledButton — biometrics (primary navy)
                        SizedBox(
                          height: 54,
                          child: FilledButton.icon(
                            style: FilledButton.styleFrom(
                              backgroundColor: BazzColors.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            icon: const Icon(Icons.fingerprint_rounded, size: 22),
                            label: Text(isAr ? 'تسجيل الدخول ببصمة الإصبع' : 'Login with Biometrics',
                              style: font(fontWeight: FontWeight.w700, fontSize: 15)),
                            onPressed: () => context.go('/home'),
                          ),
                        ).animate().fadeIn(duration: 400.ms, delay: 400.ms),
                        const Spacer(),
                        // OR divider
                        Row(children: [
                          const Expanded(child: Divider(color: BazzColors.divider)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(isAr ? 'أو' : 'OR',
                              style: font(fontSize: 12, fontWeight: FontWeight.w600, color: BazzColors.textHint)),
                          ),
                          const Expanded(child: Divider(color: BazzColors.divider)),
                        ]),
                        const SizedBox(height: 12),
                        // Golden CTA — "Sign In" (ElevatedButton with accent color)
                        SizedBox(
                          height: 54,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BazzColors.accent,
                              foregroundColor: BazzColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => context.go('/login/form', extra: _role),
                            child: Text(isAr ? 'تسجيل الدخول' : 'Sign In',
                              style: font(fontWeight: FontWeight.w800, fontSize: 15)),
                          ),
                        ),
                        const SizedBox(height: 12),
                        // M3 OutlinedButton — "Need Help?"
                        SizedBox(
                          height: 48,
                          child: OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              foregroundColor: BazzColors.textSecondary,
                              side: const BorderSide(color: BazzColors.divider),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                            ),
                            onPressed: () => _showHelpSheet(context, isAr, font),
                            child: Text(isAr ? 'تحتاج مساعدة؟' : 'Need Help?',
                              style: font(fontWeight: FontWeight.w600, fontSize: 14)),
                          ),
                        ),
                        const SizedBox(height: 28),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showHelpSheet(BuildContext context, bool isAr, Function font) {
    showModalBottomSheet(
      context: context,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFFE2E8F0), borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 20),
              Text(isAr ? 'كيف يمكننا مساعدتك؟' : 'How can we help?',
                style: GoogleFonts.inter(fontSize: 18, fontWeight: FontWeight.w800, color: BazzColors.textPrimary)),
              const SizedBox(height: 6),
              Text(isAr ? 'تواصل معنا عبر' : 'Reach our support team via',
                style: GoogleFonts.inter(fontSize: 13, color: BazzColors.textSecondary)),
              const SizedBox(height: 24),
              _HelpOption(icon: Icons.phone_rounded, color: BazzColors.success, title: isAr ? 'اتصل بنا' : 'Call Us', subtitle: '+962 6 500 0000'),
              const SizedBox(height: 12),
              _HelpOption(icon: Icons.chat_rounded, color: const Color(0xFF25D366), title: 'WhatsApp', subtitle: isAr ? 'راسلنا على واتساب' : 'Chat on WhatsApp'),
              const SizedBox(height: 12),
              _HelpOption(icon: Icons.email_rounded, color: BazzColors.primary, title: isAr ? 'البريد الإلكتروني' : 'Email Us', subtitle: 'support@bazz.jo'),
            ],
          ),
        );
      },
    );
  }
}

class _HelpOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title, subtitle;
  const _HelpOption({required this.icon, required this.color, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 44, height: 44,
        decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(title, style: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w700, color: BazzColors.textPrimary)),
      subtitle: Text(subtitle, style: GoogleFonts.inter(fontSize: 12, color: BazzColors.textSecondary)),
      trailing: const Icon(Icons.chevron_right_rounded, color: BazzColors.textHint),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: BazzColors.divider),
      ),
      tileColor: Colors.white,
    );
  }
}

class _RoleTab extends StatelessWidget {
  final String label, emoji;
  final bool selected;
  final VoidCallback onTap;

  const _RoleTab({required this.label, required this.emoji, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(
            color: selected ? BazzColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 6),
              Text(label, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w700,
                color: selected ? Colors.white : BazzColors.textSecondary)),
              if (selected) ...[
                const SizedBox(width: 5),
                Container(width: 6, height: 6, decoration: const BoxDecoration(color: BazzColors.accent, shape: BoxShape.circle)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = BazzColors.primary.withOpacity(0.03)..strokeWidth = 1;
    const step = 20.0;
    for (double i = 0; i < size.width + size.height; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
      canvas.drawLine(Offset(size.width - i, size.height), Offset(size.width, size.height - i), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}