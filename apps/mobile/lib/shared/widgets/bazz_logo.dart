import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/colors.dart';

class BazzLogo extends StatelessWidget {
  final double fontSize;
  final Color textColor;

  const BazzLogo({super.key, this.fontSize = 22, this.textColor = BazzColors.primary});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text('Baz', style: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w800, color: textColor, letterSpacing: 1)),
        _GoldenZ(fontSize: fontSize),
      ],
    );
  }
}

class _GoldenZ extends StatelessWidget {
  final double fontSize;
  const _GoldenZ({required this.fontSize});

  @override
  Widget build(BuildContext context) {
    final dotSize = fontSize * 0.18;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Text('Z', style: GoogleFonts.inter(fontSize: fontSize, fontWeight: FontWeight.w800, color: BazzColors.accent, letterSpacing: 1)),
        Positioned(top: 2, left: -1, child: _RedDot(size: dotSize)),
        Positioned(top: 2, right: -1, child: _RedDot(size: dotSize)),
        Positioned(bottom: 2, left: -1, child: _RedDot(size: dotSize)),
        Positioned(bottom: 2, right: -1, child: _RedDot(size: dotSize)),
      ],
    );
  }
}

class _RedDot extends StatelessWidget {
  final double size;
  const _RedDot({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size, height: size,
      decoration: const BoxDecoration(color: BazzColors.error, shape: BoxShape.circle),
    );
  }
}

class BazzLogoWhite extends StatelessWidget {
  final double fontSize;
  const BazzLogoWhite({super.key, this.fontSize = 22});

  @override
  Widget build(BuildContext context) => BazzLogo(fontSize: fontSize, textColor: Colors.white);
}