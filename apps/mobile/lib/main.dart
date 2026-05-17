import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'providers/app_state.dart';
import 'features/auth/splash_screen.dart';
import 'features/auth/login_screen.dart';
import 'features/auth/login_form_screen.dart';
import 'features/home/merchant_home_screen.dart';
import 'features/orders/add_order_screen.dart';
import 'features/orders/current_orders_screen.dart';
import 'features/orders/order_history_screen.dart';
import 'features/reports/reports_screen.dart';
import 'features/reports/orders_report_screen.dart';
import 'features/reports/drivers_report_screen.dart';
import 'features/reports/areas_report_screen.dart';
import 'features/reports/time_report_screen.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/login/form', builder: (_, state) {
      final role = (state.extra as String?) ?? 'merchant';
      return LoginFormScreen(role: role);
    }),
    GoRoute(path: '/home', builder: (_, __) => const MerchantHomeScreen()),
    GoRoute(path: '/orders/add', builder: (_, __) => const AddOrderScreen()),
    GoRoute(path: '/orders/current', builder: (_, __) => const CurrentOrdersScreen()),
    GoRoute(path: '/orders/history', builder: (_, __) => const OrderHistoryScreen()),
    GoRoute(path: '/reports', builder: (_, __) => const ReportsScreen()),
    GoRoute(path: '/reports/orders', builder: (_, __) => const OrdersReportScreen()),
    GoRoute(path: '/reports/drivers', builder: (_, __) => const DriversReportScreen()),
    GoRoute(path: '/reports/areas', builder: (_, __) => const AreasReportScreen()),
    GoRoute(path: '/reports/time', builder: (_, __) => const TimeReportScreen()),
  ],
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    // On light surface use dark icons (primary color)
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light, // iOS
  ));
  runApp(ChangeNotifierProvider(create: (_) => AppState(), child: const BazzApp()));
}

class BazzApp extends StatelessWidget {
  const BazzApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final isAr = appState.isArabic;

    return MaterialApp.router(
      title: 'BazZ',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: _router,
      locale: isAr ? const Locale('ar') : const Locale('en'),
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) => Directionality(
        textDirection: isAr ? TextDirection.rtl : TextDirection.ltr,
        child: child!,
      ),
    );
  }
}