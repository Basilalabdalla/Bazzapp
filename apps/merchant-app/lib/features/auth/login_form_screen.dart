import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:local_auth/local_auth.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;
import '../../theme/colors.dart';
import '../../providers/app_state.dart';
import '../../shared/widgets/bazz_logo.dart';
import '../../shared/widgets/lang_toggle.dart';
import '../../shared/widgets/bottom_sheets/need_help_sheet.dart';
import '../../services/auth_service.dart';
import '../../services/api_client.dart';

class LoginFormScreen extends StatefulWidget {
  const LoginFormScreen({super.key});

  @override
  State<LoginFormScreen> createState() => _LoginFormScreenState();
}

class _LoginFormScreenState extends State<LoginFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  bool _obscurePin = true;
  bool _loading = false;
  final _localAuth = LocalAuthentication();

  TextStyle font({FontWeight fontWeight = FontWeight.w400, double fontSize = 14, Color? color}) {
    final isAr = context.read<AppState>().isArabic;
    final c = color ?? BazzColors.textPrimary;
    return isAr
        ? GoogleFonts.cairo(fontWeight: fontWeight, fontSize: fontSize, color: c)
        : GoogleFonts.inter(fontWeight: fontWeight, fontSize: fontSize, color: c);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    try {
      final profile = await AuthService.instance.login(
        _phoneCtrl.text.trim(),
        _pinCtrl.text.trim(),
      );
      if (!mounted) return;
      context.read<AppState>().setMerchant(profile);
      context.go('/home');
    } on ApiException catch (e) {
      if (!mounted) return;
      final isAr = context.read<AppState>().isArabic;
      final message = e.statusCode == 401
          ? (isAr ? 'رقم الهاتف أو PIN غير صحيح' : 'Invalid phone number or PIN')
          : (isAr ? 'حدث خطأ في الخادم' : 'Server error, please try again');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: BazzColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      final isAr = context.read<AppState>().isArabic;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(isAr ? 'تعذّر الوصول إلى الخادم' : 'Could not reach the server'),
          backgroundColor: BazzColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _biometricLogin() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return;
      final authenticated = await _localAuth.authenticate(
        localizedReason: context.read<AppState>().isArabic
            ? 'سجّل دخولك بالبصمة أو بمعرف الوجه'
            : 'Sign in with Face ID or fingerprint',
        options: const AuthenticationOptions(biometricOnly: true),
      );
      if (!mounted || !authenticated) return;
      context.read<AppState>().setRole('merchant');
      context.go('/home');
    } catch (_) {}
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    _pinCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;

    return Scaffold(
      backgroundColor: BazzColors.background,
      body: Stack(
        children: [
          Positioned.fill(child: CustomPaint(painter: _GridPainter())),
          SafeArea(
            child: Column(
              children: [
                // Header — BazZ logo + lang toggle
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BazzLogo(),
                      ChangeNotifierProvider.value(
                        value: appState,
                        child: const LangToggle(),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 24),

                        // Title
                        Center(
                          child: Text(
                            isAr ? 'دخول التاجر' : 'Merchant Login',
                            style: font(fontWeight: FontWeight.w800, fontSize: 26, color: BazzColors.primary),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            isAr ? 'أدخل بياناتك للمتابعة' : 'Enter your credentials to continue',
                            style: font(fontSize: 13, color: BazzColors.textSecondary),
                            textAlign: TextAlign.center,
                          ),
                        ),

                        const SizedBox(height: 36),

                        // Form card
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: BazzColors.primary.withOpacity(0.08),
                                blurRadius: 24,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(24),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Phone field
                                Text(
                                  isAr ? 'رقم الهاتف' : 'Phone Number',
                                  style: font(fontWeight: FontWeight.w600, fontSize: 13, color: BazzColors.primary),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _phoneCtrl,
                                  keyboardType: TextInputType.phone,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  style: font(fontWeight: FontWeight.w500, fontSize: 15),
                                  decoration: _inputDeco(
                                    hint: '05XXXXXXXX',
                                    icon: Icons.phone_outlined,
                                  ),
                                  validator: (v) {
                                    if (v == null || v.length < 9) {
                                      return isAr ? 'رقم هاتف غير صالح' : 'Invalid phone number';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 20),

                                // PIN field
                                Text(
                                  isAr ? 'رمز PIN' : 'PIN Code',
                                  style: font(fontWeight: FontWeight.w600, fontSize: 13, color: BazzColors.primary),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _pinCtrl,
                                  obscureText: _obscurePin,
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  maxLength: 6,
                                  style: font(fontWeight: FontWeight.w700, fontSize: 18, color: BazzColors.primary),
                                  decoration: _inputDeco(
                                    hint: '••••••',
                                    icon: Icons.lock_outline,
                                    counter: false,
                                    suffix: IconButton(
                                      icon: Icon(
                                        _obscurePin ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                        color: BazzColors.textSecondary,
                                        size: 20,
                                      ),
                                      onPressed: () => setState(() => _obscurePin = !_obscurePin),
                                    ),
                                  ),
                                  validator: (v) {
                                    if (v == null || v.length < 4) {
                                      return isAr ? 'PIN يجب أن يكون 4 أرقام على الأقل' : 'PIN must be at least 4 digits';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 8),

                                // Forgot PIN
                                Align(
                                  alignment: isAr ? Alignment.centerLeft : Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {},
                                    style: TextButton.styleFrom(
                                      padding: EdgeInsets.zero,
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: Text(
                                      isAr ? 'نسيت PIN؟' : 'Forgot PIN?',
                                      style: font(fontWeight: FontWeight.w600, fontSize: 13, color: BazzColors.accent),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Sign In button
                                SizedBox(
                                  height: 52,
                                  child: FilledButton(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: BazzColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: _loading ? null : _submit,
                                    child: _loading
                                        ? const SizedBox(
                                            width: 22,
                                            height: 22,
                                            child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                                          )
                                        : Text(
                                            isAr ? 'تسجيل الدخول' : 'Sign In',
                                            style: font(fontWeight: FontWeight.w700, fontSize: 15, color: Colors.white),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 12),

                                // Biometric button
                                SizedBox(
                                  height: 52,
                                  child: FilledButton.icon(
                                    style: FilledButton.styleFrom(
                                      backgroundColor: BazzColors.primary,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    ),
                                    onPressed: _biometricLogin,
                                    icon: const Icon(Icons.face_retouching_natural_rounded, color: Colors.white, size: 22),
                                    label: Text(
                                      isAr ? 'تسجيل الدخول بالبصمة / معرف الوجه' : 'Sign in with Face ID / Biometrics',
                                      style: font(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Need Help? — yellow button at bottom
                        SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: BazzColors.accent,
                              foregroundColor: BazzColors.primary,
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              shadowColor: Colors.transparent,
                            ),
                            onPressed: () => showNeedHelpSheet(context, isAr: isAr),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.headset_mic_outlined, size: 18, color: BazzColors.primary),
                                const SizedBox(width: 8),
                                Text(
                                  isAr ? 'تحتاج مساعدة؟' : 'Need Help?',
                                  style: font(fontWeight: FontWeight.w700, fontSize: 14, color: BazzColors.primary),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
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

  InputDecoration _inputDeco({
    required String hint,
    required IconData icon,
    Widget? suffix,
    bool counter = true,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: BazzColors.primary, size: 20),
      suffixIcon: suffix,
      counterText: counter ? null : '',
      filled: true,
      fillColor: const Color(0xFFF8FAFF),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: BazzColors.primary.withOpacity(0.15)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: BazzColors.primary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: BazzColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: BazzColors.error, width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }
}

// ── Diagonal grid background painter ───────────────────────────────
class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = BazzColors.primary.withOpacity(0.045)
      ..strokeWidth = 1;
    const spacing = 32.0;
    final count = (size.width + size.height) ~/ spacing + 2;
    for (int i = -2; i < count; i++) {
      final x = i * spacing;
      canvas.drawLine(Offset(x, 0), Offset(x + size.height, size.height), paint);
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
