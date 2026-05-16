import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: Container(
      decoration: const BoxDecoration(gradient: LinearGradient(
        begin: Alignment.topCenter, end: Alignment.bottomCenter,
        colors: [Color(0xFF1A0A0A), AppTheme.background], stops: [0.0, 0.4])),
      child: SafeArea(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const Spacer(),
        const Text('Selecciona tu Perfil', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        const SizedBox(height: 48),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          _Avatar(emoji: '😜', name: 'Perfil 1'),
          _Avatar(emoji: '🙂', name: 'Perfil 2'),
          _Avatar(emoji: '😎', name: 'Perfil 3'),
        ]),
        const SizedBox(height: 48),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Text('Si has iniciado sesión en otro dispositivo, esta se cerrará al continuar.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary.withOpacity(0.7), fontSize: 14, height: 1.5))),
        const Spacer(),
      ])),
    ),
  );
}

class _Avatar extends StatelessWidget {
  final String emoji, name;
  const _Avatar({required this.emoji, required this.name});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => Navigator.pushReplacementNamed(context, '/main'),
    child: Padding(padding: const EdgeInsets.symmetric(horizontal: 14),
      child: Column(children: [
        Container(width: 90, height: 90,
          decoration: BoxDecoration(color: AppTheme.surface, borderRadius: BorderRadius.circular(22), border: Border.all(color: AppTheme.border, width: 2)),
          child: Center(child: Text(emoji, style: const TextStyle(fontSize: 44)))),
        const SizedBox(height: 10),
        Text(name, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
      ])),
  );
}
