import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _State();
}

class _State extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _obscure = true, _loading = false;
  String? _error;

  Future<void> _login() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'Completá los campos');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ApiService.login(_email.text.trim(), _pass.text.trim());
      if (r['token'] != null) {
        Navigator.pushReplacementNamed(context, '/profile');
      } else {
        setState(() => _error = r['error'] ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      setState(() => _error = 'Sin conexión con el servidor');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    appBar: AppBar(title: const Text('DemonTv Plus')),
    body: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(children: [
        const SizedBox(height: 60),
        Row(children: [
          Container(width: 72, height: 72,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppTheme.logoGradient, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
            child: const Icon(Icons.all_inclusive, color: Colors.white, size: 38)),
          const SizedBox(width: 18),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bienvenido a', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
            Text('DemonTv Plus', style: TextStyle(color: AppTheme.textPrimary, fontSize: 26, fontWeight: FontWeight.bold)),
          ]),
        ]),
        const SizedBox(height: 56),
        TextField(controller: _email, keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(prefixIcon: Icon(Icons.mail_outline), hintText: 'Correo electrónico')),
        const SizedBox(height: 16),
        TextField(controller: _pass, obscureText: _obscure,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.lock_outline), hintText: 'Contraseña',
            suffixIcon: IconButton(onPressed: () => setState(() => _obscure = !_obscure),
              icon: Icon(_obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined)))),
        if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: AppTheme.accentRed, fontSize: 13))],
        const Spacer(),
        GradientButton(text: 'Iniciar Sesión', onPressed: _login, isLoading: _loading),
        const SizedBox(height: 32),
      ]),
    )),
  );
}
