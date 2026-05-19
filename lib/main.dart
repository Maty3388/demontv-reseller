import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'services/api.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await AdminApi.loadToken();
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: "DemonTv Admin",
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      appBarTheme: const AppBarTheme(elevation: 0),
    ),
    initialRoute: AdminApi.token != null ? "/dashboard" : "/",
    routes: {
      "/":          (_) => const LoginScreen(),
      "/dashboard": (_) => const DashboardScreen(),
    },
  );
}
