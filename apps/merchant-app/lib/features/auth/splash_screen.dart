import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../../shared/widgets/bazz_logo.dart';
import '../../theme/colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _glowCtrl;
  late final Animation<double> _glowAnim;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _glowAnim = Tween<double>(begin: 0.12, end: 0.45).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );
    _init();
  }

  @override
  void dispose() {
    _glowCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    await Future.delayed(const Duration(milliseconds: 2200));
    if (!mounted) return;
    final hasSession = await context.read<AppState>().restoreSession();
    if (!mounted) return;
    context.go(hasSession ? '/home' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BazzColors.primary,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Pulsing golden radial glow
            AnimatedBuilder(
              animation: _glowAnim,
              builder: (_, __) => Container(
                width: 240,
                height: 240,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      BazzColors.accent.withOpacity(_glowAnim.value),
                      BazzColors.accent.withOpacity(_glowAnim.value * 0.35),
                      Colors.transparent,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),
            ),
            // BazZ logo — entry animation then looping shimmer
            BazzLogoWhite(fontSize: 64)
                .animate()
                .scale(
                  begin: const Offset(0.7, 0.7),
                  end: const Offset(1.0, 1.0),
                  duration: 700.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms)
                .animate(onPlay: (c) => c.repeat())
                .shimmer(
                  duration: 1800.ms,
                  delay: 800.ms,
                  color: Colors.white.withOpacity(0.55),
                  blendMode: BlendMode.srcATop,
                ),
          ],
        ),
      ),
    );
  }
}
