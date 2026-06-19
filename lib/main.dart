import 'package:flutter/material.dart';
import 'services/api.dart';
import 'services/notification_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ResellerApi.loadToken();
  try { await NotificationService.init(); } catch (_) {}
  runApp(const FluxTvResellerApp());
}

class FluxTvResellerApp extends StatelessWidget {
  const FluxTvResellerApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'FluxTv Reseller',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      scaffoldBackgroundColor: AdminTheme.bg,
      colorScheme: ColorScheme.dark(primary: AdminTheme.cyan),
      useMaterial3: false,
    ),
    initialRoute: ResellerApi.isLoggedIn ? '/dashboard' : '/',
    routes: {
      '/': (ctx) => const LoginScreen(),
      '/dashboard': (ctx) => const DashboardScreen(),
    },
  );
}
