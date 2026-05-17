import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';
import '../../shared/widgets/bazz_logo.dart';
import '../../shared/widgets/lang_toggle.dart';
import '../../theme/colors.dart';

class LoginFormScreen extends StatefulWidget {
  final String role;
  const LoginFormScreen({super.key, required this.role});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  late String _role;
  final _idController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _loading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _role = widget.role;
  }

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final profile = await AuthService.instance.login(
        _idController.text.trim(),
        _passwordController.text,
      );
      if (!mounted) return;
      context.read<AppState>()
        ..setRole(_role)
        ..setMerchant(profile);
      context.go('/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      final isAr = context.read<AppState>().isArabic;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          e.statusCode == 401
              ? (isAr ? 'رقم الهاتف أو كلمة المرور غير صحيحة' : 'Invalid phone or password')
              : (isAr ? 'حدث خطأ، حاول مجدداً' : 'Something went wrong, try again'),
        ),
        backgroundColor: BazzColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } catch (_) {
      if (!mounted) return;
      final isAr = context.read<AppState>().isArabic;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isAr ? 'تعذر الاتصال بالخادم' : 'Could not reach the server'),
        backgroundColor: BazzColors.error,
        behavior: SnackBarBehavior.floating,
      ));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    final roleLabel = _role == 'driver'
        ? (isAr ? 'السائق 🚚' : 'Driver 🚚')
        : (isAr ? 'التاجر 🏪' : 'Merchant 🏪');

    return Scaffold(
      backgroundColor: BazzColors.surface,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          SafeArea(
            child: Column(
              children: [
                // Top bar: back arrow | BazZ logo | EN|عربي toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_rounded, color: BazzColors.primary),
                        onPressed: () {
                          if (context.canPop()) context.pop();
                        },
                      ),
                      const BazzLogo(fontSize: 28),
                      const LangToggle(),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 24),

                          // Role switcher tabs
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(children: [
                              _RoleTab(
                                label: isAr ? 'السائق' : 'Driver',
                                emoji: '🚚',
                                selected: _role == 'driver',
                                onTap: () => setState(() => _role = 'driver'),
                              ),
                              _RoleTab(
                                label: isAr ? 'التاجر' : 'Merchant',
                                emoji: '🏪',
                                selected: _role == 'merchant',
                                onTap: () => setState(() => _role = 'merchant'),
                              ),
                            ]),
                          ).animate().fadeIn(duration: 300.ms),

                          const SizedBox(height: 28),

                          // "Enter Your Credentials" heading
                          Text(
                            isAr ? 'أدخل بياناتك' : 'Enter Your Credentials',
                            style: font(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: BazzColors.primary,
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: 80.ms),

                          const SizedBox(height: 10),

                          // Role badge chip
                          Align(
                            alignment: isAr ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: BazzColors.accent,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                roleLabel,
                                style: font(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: BazzColors.primary,
                                ),
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: 120.ms),

                          const SizedBox(height: 32),

                          // Personal ID field label
                          Text(
                            isAr ? 'الرقم الشخصي' : 'Personal ID',
                            style: font(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: BazzColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _idController,
                            keyboardType: TextInputType.text,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: BazzColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: isAr ? 'أدخل رقمك الشخصي' : 'Enter your ID number',
                              prefixIcon: const Icon(
                                Icons.credit_card_rounded,
                                color: BazzColors.primary,
                                size: 20,
                              ),
                            ),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? (isAr ? 'الرقم الشخصي مطلوب' : 'Personal ID is required')
                                : null,
                          ).animate().fadeIn(duration: 300.ms, delay: 160.ms),

                          const SizedBox(height: 20),

                          // Password field label
                          Text(
                            isAr ? 'كلمة المرور' : 'Password',
                            style: font(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: BazzColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: BazzColors.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: isAr ? 'أدخل كلمة المرور' : 'Enter your password',
                              prefixIcon: const Icon(
                                Icons.lock_rounded,
                                color: BazzColors.primary,
                                size: 20,
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                  color: BazzColors.textHint,
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? (isAr ? 'كلمة المرور مطلوبة' : 'Password is required')
                                : null,
                          ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

                          const SizedBox(height: 8),

                          // Forgot Password — right aligned, golden
                          Align(
                            alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: Text(
                                isAr ? 'نسيت كلمة المرور؟' : 'Forgot Password?',
                                style: font(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: BazzColors.accent,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Sign In — NAVY filled button
                          SizedBox(
                            height: 54,
                            child: FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: BazzColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: _loading ? null : _submit,
                              child: _loading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.5,
                                        color: Colors.white,
                                      ),
                                    )
                                  : Text(
                                      isAr ? 'تسجيل الدخول' : 'Sign In',
                                      style: font(fontWeight: FontWeight.w800, fontSize: 16),
                                    ),
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: 260.ms),

                          const SizedBox(height: 16),

                          // Use Biometrics — outlined button with fingerprint icon
                          SizedBox(
                            height: 54,
                            child: OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(
                                foregroundColor: BazzColors.primary,
                                side: const BorderSide(color: BazzColors.primary, width: 1.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              onPressed: () {},
                              icon: const Icon(Icons.fingerprint_rounded, size: 22),
                              label: Text(
                                isAr ? 'استخدام البصمة' : 'Use Biometrics',
                                style: font(fontWeight: FontWeight.w700, fontSize: 15),
                              ),
                            ),
                          ).animate().fadeIn(duration: 300.ms, delay: 310.ms),

                          const SizedBox(height: 40),
                        ],
                      ),
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
}

class _RoleTab extends StatelessWidget {
  final String label, emoji;
  final bool selected;
  final VoidCallback onTap;
  const _RoleTab({
    required this.label,
    required this.emoji,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? BazzColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(emoji, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 5),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : BazzColors.textSecondary,
                ),
              ),
              if (selected) ...[
                const SizedBox(width: 5),
                Container(
                  width: 5,
                  height: 5,
                  decoration: const BoxDecoration(
                    color: BazzColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
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
    final paint = Paint()
      ..color = BazzColors.primary.withOpacity(0.03)
      ..strokeWidth = 1;
    const step = 20.0;
    for (double i = 0; i < size.width + size.height; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(0, i), paint);
      canvas.drawLine(
          Offset(size.width - i, size.height), Offset(size.width, size.height - i), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}
