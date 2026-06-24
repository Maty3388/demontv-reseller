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
  bool _loading = false, _showPass = false;
  String? _error;

  Future<void> _login() async {
    if (_email.text.isEmpty || _pass.text.isEmpty) { setState(() => _error = 'Completá todos los campos'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      final r = await ResellerApi.login(_email.text.trim(), _pass.text.trim());
      if (!mounted) return;
      if (r['token'] != null) { Navigator.pushReplacementNamed(context, '/dashboard'); }
      else { setState(() => _error = r['error'] ?? 'Error al iniciar sesión'); }
    } catch (e) { setState(() => _error = 'Sin conexión'); }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AdminTheme.bg,
    body: Center(child: SingleChildScrollView(child: Padding(padding: const EdgeInsets.all(32),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network('https://raw.githubusercontent.com/Maty3388/demontv-reseller/master/assets/logo.png', width: 80, height: 80, fit: BoxFit.cover)),
        const Text('FluxTv Reseller', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        const Text('Panel de Revendedor', style: TextStyle(color: AdminTheme.textSecondary, fontSize: 13)),
        const SizedBox(height: 36),
        TextField(controller: _email, style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: 'Email', hintStyle: const TextStyle(color: AdminTheme.textSecondary),
            prefixIcon: const Icon(Icons.email_outlined, color: AdminTheme.textSecondary),
            filled: true, fillColor: AdminTheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        const SizedBox(height: 12),
        TextField(controller: _pass, obscureText: !_showPass, style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(hintText: 'Contraseña', hintStyle: const TextStyle(color: AdminTheme.textSecondary),
            prefixIcon: const Icon(Icons.lock_outline, color: AdminTheme.textSecondary),
            suffixIcon: IconButton(icon: Icon(_showPass ? Icons.visibility_off : Icons.visibility, color: AdminTheme.textSecondary),
              onPressed: () => setState(() => _showPass = !_showPass)),
            filled: true, fillColor: AdminTheme.surface,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
        if (_error != null) ...[const SizedBox(height: 12), Text(_error!, style: const TextStyle(color: AdminTheme.red, fontSize: 13), textAlign: TextAlign.center)],
        const SizedBox(height: 24),
        SizedBox(width: double.infinity, height: 50,
          child: ElevatedButton(onPressed: _loading ? null : _login,
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6C3DE0), foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: _loading ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2) : const Text('INGRESAR', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)))),
      ])))));
}
