import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface    = Color(0xFF1A1A1A);
  static const Color surfaceAlt = Color(0xFF242424);
  static const Color border     = Color(0xFF2E2E2E);
  static const List<Color> buttonGradient = [Color(0xFF00BFFF), Color(0xFFFFD700)];
  static const List<Color> logoGradient   = [Color(0xFF7B2FFF), Color(0xFFFF6B9D), Color(0xFFFFAA00)];
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textHint      = Color(0xFF5C5C5C);
  static const Color accentCyan    = Color(0xFF00CFDD);
  static const Color accentYellow  = Color(0xFFFFD700);
  static const Color accentRed     = Color(0xFFFF3B30);

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      background: background, surface: surface,
      primary: accentCyan, secondary: accentYellow,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF111111),
      foregroundColor: textPrimary, elevation: 0,
      titleTextStyle: TextStyle(color: textPrimary, fontSize: 20, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: surface,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
      hintStyle: const TextStyle(color: textHint, fontSize: 15),
      prefixIconColor: textSecondary, suffixIconColor: textSecondary,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    ),
  );
}

class GradientButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  const GradientButton({super.key, required this.text, required this.onPressed, this.isLoading = false});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: isLoading ? null : onPressed,
    child: Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: AppTheme.buttonGradient, begin: Alignment.centerLeft, end: Alignment.centerRight),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [BoxShadow(color: AppTheme.accentCyan.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: Center(child: isLoading
        ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2.5))
        : Text(text, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 17))),
    ),
  );
}
