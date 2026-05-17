import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/colors.dart';

class AddOrderScreen extends StatefulWidget {
  const AddOrderScreen({super.key});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  int _count = 1;
  int? _selectedPreset;

  static const _presets = [1, 2, 3, 5, 10, 15, 20];

  void _increment() {
    if (_count < 50) {
      setState(() {
        _count++;
        _selectedPreset = null;
      });
    }
  }

  void _decrement() {
    if (_count > 1) {
      setState(() {
        _count--;
        _selectedPreset = null;
      });
    }
  }

  void _selectPreset(int p) {
    setState(() {
      _count = p;
      _selectedPreset = p;
    });
  }

  void _startAdding() {
    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;
    final font = isAr ? GoogleFonts.cairo : GoogleFonts.inter;

    return Scaffold(
      backgroundColor: BazzColors.surface,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: BazzColors.textPrimary),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
        title: Column(
          children: [
            Text(
              isAr ? 'طلبات جديدة' : 'New Orders',
              style: font(
                  fontSize: 17, fontWeight: FontWeight.w700, color: BazzColors.textPrimary),
            ),
            Text(
              isAr ? 'الخطوة 1 من 3' : 'Step 1 of 3',
              style: font(fontSize: 12, color: BazzColors.textSecondary),
            ),
          ],
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(8),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
            child: Row(
              children: List.generate(3, (i) {
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(right: i < 2 ? 4 : 0),
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: i == 0 ? BazzColors.accent : const Color(0xFFE2E8F0),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Package illustration
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: BazzColors.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(Icons.inventory_2_rounded, color: Colors.white, size: 42),
                  ),
                  Positioned(
                    top: 6,
                    right: 6,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: const BoxDecoration(
                        color: BazzColors.accent,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).scale(begin: const Offset(0.85, 0.85)),

            const SizedBox(height: 28),

            // Heading
            Text(
              isAr ? 'كم طلباً اليوم؟' : 'How many orders today?',
              style: font(
                  fontSize: 22, fontWeight: FontWeight.w800, color: BazzColors.textPrimary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 300.ms, delay: 80.ms),

            const SizedBox(height: 8),

            Text(
              isAr
                  ? 'اختر عدد الطلبات التي تريد إضافتها'
                  : 'Select the number of orders you want to add',
              style: font(fontSize: 14, color: BazzColors.textSecondary),
              textAlign: TextAlign.center,
            ).animate().fadeIn(duration: 300.ms, delay: 120.ms),

            const SizedBox(height: 40),

            // Counter row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Minus button
                TextButton(
                  onPressed: _decrement,
                  style: TextButton.styleFrom(
                    foregroundColor: _count > 1 ? BazzColors.textPrimary : BazzColors.textHint,
                    minimumSize: const Size(48, 48),
                  ),
                  child: Text(
                    '−',
                    style: font(
                      fontSize: 32,
                      fontWeight: FontWeight.w300,
                      color: _count > 1 ? BazzColors.textPrimary : BazzColors.textHint,
                    ),
                  ),
                ),

                const SizedBox(width: 24),

                // Count number
                Text(
                  '$_count',
                  style: font(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: BazzColors.primary,
                  ),
                ),

                const SizedBox(width: 24),

                // Plus button (golden circle)
                GestureDetector(
                  onTap: _increment,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: const BoxDecoration(
                      color: BazzColors.accent,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.add_rounded, color: BazzColors.primary, size: 28),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 160.ms),

            const SizedBox(height: 4),

            Text(
              isAr ? 'طلبات' : 'orders',
              style: font(fontSize: 14, color: BazzColors.textSecondary),
            ),

            const SizedBox(height: 28),

            // Quick select chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                shrinkWrap: true,
                itemCount: _presets.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final p = _presets[i];
                  final sel = _selectedPreset == p;
                  return GestureDetector(
                    onTap: () => _selectPreset(p),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                      decoration: BoxDecoration(
                        color: sel ? BazzColors.accent : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: sel ? BazzColors.accent : BazzColors.divider),
                        boxShadow: sel
                            ? [
                                BoxShadow(
                                    color: BazzColors.accent.withOpacity(0.3),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2))
                              ]
                            : [],
                      ),
                      child: Text(
                        '$p',
                        style: font(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: sel ? BazzColors.primary : BazzColors.textSecondary,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 200.ms),

            const SizedBox(height: 20),

            // "Or type a number" link
            GestureDetector(
              onTap: () {},
              child: Text(
                isAr ? 'أو اكتب رقماً' : 'Or type a number',
                style: font(
                  fontSize: 13,
                  color: BazzColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ).copyWith(decoration: TextDecoration.underline),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 240.ms),

            const SizedBox(height: 20),

            // Info row
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline_rounded, size: 14, color: BazzColors.textHint),
                const SizedBox(width: 6),
                Text(
                  isAr ? 'الحد الأقصى 50 طلباً في الدفعة' : 'Maximum 50 orders per batch',
                  style: font(fontSize: 12, color: BazzColors.textSecondary),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms, delay: 280.ms),

            const SizedBox(height: 40),

            // Start Adding Orders button
            SizedBox(
              width: double.infinity,
              height: 54,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: BazzColors.accent,
                  foregroundColor: BazzColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: _startAdding,
                child: Text(
                  isAr ? 'ابدأ إضافة الطلبات ›' : 'Start Adding Orders ›',
                  style: font(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms, delay: 320.ms),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
