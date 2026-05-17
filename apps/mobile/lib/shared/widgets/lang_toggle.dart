import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../theme/colors.dart';

class LangToggle extends StatelessWidget {
  final bool light;
  const LangToggle({super.key, this.light = false});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isArabic = appState.isArabic;
    final fg = light ? Colors.white : BazzColors.primary;
    final border = light ? Colors.white.withOpacity(0.6) : BazzColors.primary;

    return GestureDetector(
      onTap: appState.toggleLanguage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: border, width: 1.5),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('EN', style: GoogleFonts.inter(fontSize: 11, fontWeight: FontWeight.w600, color: !isArabic ? fg : fg.withOpacity(0.4))),
            Text(' | ', style: GoogleFonts.inter(fontSize: 11, color: fg.withOpacity(0.4))),
            Text('ع', style: GoogleFonts.cairo(fontSize: 11, fontWeight: FontWeight.w600, color: isArabic ? fg : fg.withOpacity(0.4))),
          ],
        ),
      ),
    );
  }
}