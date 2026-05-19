import 'package:flutter/material.dart';
import '../services/api.dart';
import '../theme/theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override State<LoginScreen> createState() => _LoginState();
}

class _LoginState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) {
      setState(() => _error = 'Completa todos los campos');
      return;
    }
    setState(() { _loading = true; _error = null; });
    final r = await AdminApi.login(_email.text.trim(), _pass.text.trim());
    if (!mounted) return;
    setState(() => _loading = false);
    if (r['token'] != null) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      setState(() => _error = r['error'] ?? 'Credenciales incorrectas');
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AdminTheme.bg,
    body: Center(child: SingleChildScrollView(
      padding: const EdgeInsets.all(32),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 72, height: 72,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF00E5FF), Color(0xFFAA00FF)]),
              borderRadius: BorderRadius.circular(20)),
            child: const Center(child: Text('D+', style: TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)))),
          const SizedBox(height: 16),
          const Text('DemonTv Plus', style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
          const Text('Panel Admin', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 14)),
          const SizedBox(height: 40),
          _field(_email, 'Email', Icons.email_outlined, false),
          const SizedBox(height: 12),
          _field(_pass, 'Contraseña', Icons.lock_outline, true),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: const TextStyle(color: AdminTheme.red, fontSize: 13), textAlign: TextAlign.center),
          ],
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, height: 50,
            child: ElevatedButton(
              onPressed: _loading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AdminTheme.cyan,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              child: _loading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black))
                : const Text('Iniciar Sesion', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)))),
        ]),
      ),
    )),
  );

  Widget _field(TextEditingController c, String hint, IconData icon, bool obscure) =>
    TextField(
      controller: c, obscureText: obscure,
      style: const TextStyle(color: Colors.white),
      onSubmitted: (_) => _login(),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: AdminTheme.textSecondary),
        hintText: hint,
        hintStyle: const TextStyle(color: AdminTheme.textHint),
        filled: true, fillColor: AdminTheme.surface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)));
}
