import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'live_tv_screen.dart';
import 'vod_screen.dart';
import 'settings_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override State<MainScreen> createState() => _State();
}

class _State extends State<MainScreen> {
  int _idx = 0;

  static const _screens = [
    LiveTvScreen(),
    VodScreen(type: 'movies'),
    VodScreen(type: 'series'),
    SettingsScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.background,
    body: IndexedStack(index: _idx, children: _screens),
    bottomNavigationBar: _buildNav(),
  );

  Widget _buildNav() => Container(
    decoration: BoxDecoration(color: const Color(0xFF111111), border: Border(top: BorderSide(color: AppTheme.border, width: 0.5))),
    child: SafeArea(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        _NavItem(icon: Icons.live_tv_outlined, activeIcon: Icons.live_tv, index: 0, selected: _idx, onTap: (i) => setState(() => _idx = i)),
        _NavItem(icon: Icons.movie_outlined, activeIcon: Icons.movie, index: 1, selected: _idx, onTap: (i) => setState(() => _idx = i)),
        GestureDetector(
          onTap: () => setState(() => _idx = 2),
          child: Container(width: 58, height: 58,
            decoration: BoxDecoration(shape: BoxShape.circle,
              gradient: const LinearGradient(colors: AppTheme.buttonGradient, begin: Alignment.topLeft, end: Alignment.bottomRight),
              boxShadow: [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.35), blurRadius: 16, spreadRadius: 2)]),
            child: Icon(_idx == 2 ? Icons.theaters : Icons.theaters_outlined, color: Colors.black, size: 26)),
        ),
        _NavItem(icon: Icons.video_library_outlined, activeIcon: Icons.video_library, index: 3, selected: _idx, onTap: (i) => setState(() => _idx = i)),
        _NavItem(icon: Icons.person_outline, activeIcon: Icons.person, index: 4, selected: _idx, onTap: (i) => setState(() => _idx = i)),
      ]),
    )),
  );
}

class _NavItem extends StatelessWidget {
  final IconData icon, activeIcon;
  final int index, selected;
  final void Function(int) onTap;
  const _NavItem({required this.icon, required this.activeIcon, required this.index, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isSelected = selected == index;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(index),
      child: Padding(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          isSelected
            ? ShaderMask(blendMode: BlendMode.srcIn,
                shaderCallback: (b) => const LinearGradient(colors: AppTheme.buttonGradient, begin: Alignment.topLeft, end: Alignment.bottomRight).createShader(b),
                child: Icon(activeIcon, size: 26, color: Colors.white))
            : Icon(icon, size: 26, color: const Color(0xFF5C5C5C)),
          if (isSelected) Container(margin: const EdgeInsets.only(top: 4), width: 4, height: 4,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: AppTheme.buttonGradient))),
        ])),
    );
  }
}
