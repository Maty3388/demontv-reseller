import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../utils/device_type.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _State();
}

class _State extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false, _showPass = false;
  String? _error;

  Future<void> _login() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'Completá todos los campos');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ApiService.login(_email.text.trim(), _pass.text.trim());
      if (r['token'] != null) {
        Navigator.pushReplacementNamed(context, '/main');
      } else {
        setState(() => _error = r['error'] ?? 'Error al iniciar sesión');
      }
    } catch (e) {
      setState(() => _error = 'Sin conexión con el servidor');
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (isTV(context)) return _buildTV();
    return _buildPhone();
  }

  // ── Layout TV ─────────────────────────────────────────────
  Widget _buildTV() => Scaffold(
    backgroundColor: Colors.black,
    body: Row(children: [
      // Panel izquierdo
      Expanded(flex: 2, child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(colors: AppTheme.logoGradient, begin: Alignment.topLeft, end: Alignment.bottomRight)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 120, height: 120,
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), borderRadius: BorderRadius.circular(30)),
            child: const Center(child: Text('∞', style: TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 24),
          const Text('DemonTv Plus', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold, letterSpacing: 2)),
          const SizedBox(height: 8),
          const Text('Tu entretenimiento sin límites', style: TextStyle(color: Colors.white70, fontSize: 16)),
        ]),
      )),
      // Panel derecho - Login
      Expanded(flex: 3, child: Container(
        color: const Color(0xFF0A0A0A),
        padding: const EdgeInsets.all(60),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Iniciar Sesión', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text('Ingresá tus credenciales para continuar', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
          const SizedBox(height: 40),
          _TVField(controller: _email, hint: 'Correo electrónico', icon: Icons.email_outlined, autofocus: true),
          const SizedBox(height: 16),
          _TVField(controller: _pass, hint: 'Contraseña', icon: Icons.lock_outline, obscure: !_showPass,
            suffix: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary),
              onPressed: () => setState(() => _showPass = !_showPass))),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.accentRed.withOpacity(0.15), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [const Icon(Icons.error_outline, color: AppTheme.accentRed, size: 18), const SizedBox(width: 8), Text(_error!, style: const TextStyle(color: AppTheme.accentRed, fontSize: 14))])),
          ],
          const SizedBox(height: 32),
          SizedBox(width: double.infinity, height: 56,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCyan,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: _loading
                ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5)
                : const Text('INICIAR SESIÓN', style: TextStyle(color: Colors.black, fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.5)))),
        ]),
      )),
    ]),
  );

  // ── Layout Phone ──────────────────────────────────────────
  Widget _buildPhone() => Scaffold(
    backgroundColor: AppTheme.background,
    body: SafeArea(child: SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(children: [
        const SizedBox(height: 60),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(width: 72, height: 72,
            decoration: BoxDecoration(gradient: const LinearGradient(colors: AppTheme.logoGradient, begin: Alignment.topLeft, end: Alignment.bottomRight), borderRadius: BorderRadius.circular(20)),
            child: const Center(child: Text('∞', style: TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)))),
          const SizedBox(width: 16),
          const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Bienvenido a', style: TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
            Text('DemonTv Plus', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          ]),
        ]),
        const SizedBox(height: 48),
        _PhoneField(controller: _email, hint: 'Correo electrónico', icon: Icons.email_outlined),
        const SizedBox(height: 14),
        _PhoneField(controller: _pass, hint: 'Contraseña', icon: Icons.lock_outline, obscure: !_showPass,
          suffix: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: AppTheme.textSecondary, size: 20),
            onPressed: () => setState(() => _showPass = !_showPass))),
        if (_error != null) ...[
          const SizedBox(height: 12),
          Text(_error!, style: const TextStyle(color: AppTheme.accentRed, fontSize: 13), textAlign: TextAlign.center),
        ],
        const SizedBox(height: 28),
        GradientButton(text: _loading ? '' : 'Iniciar Sesión', onPressed: _loading ? () {} : _login, isLoading: _loading),
        const SizedBox(height: 32),
      ]),
    )),
  );
}

class _TVField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure, autofocus;
  final Widget? suffix;
  const _TVField({required this.controller, required this.hint, required this.icon, this.obscure = false, this.autofocus = false, this.suffix});
  @override Widget build(BuildContext context) => TextField(
    controller: controller, obscureText: obscure, autofocus: autofocus,
    style: const TextStyle(color: Colors.white, fontSize: 18),
    decoration: InputDecoration(
      prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 22),
      suffixIcon: suffix,
      hintText: hint,
      filled: true, fillColor: const Color(0xFF1C1C1E),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.accentCyan, width: 2)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18)));
}

class _PhoneField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final bool obscure;
  final Widget? suffix;
  const _PhoneField({required this.controller, required this.hint, required this.icon, this.obscure = false, this.suffix});
  @override Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(14)),
    child: TextField(
      controller: controller, obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AppTheme.textSecondary, size: 20),
        suffixIcon: suffix,
        hintText: hint,
        border: InputBorder.none,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16))));
}
