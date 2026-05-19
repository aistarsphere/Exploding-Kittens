import 'package:flutter/material.dart';

class AppColors {
  static const Color bgDeep    = Color(0xFF1A0806);
  static const Color bgMid     = Color(0xFF4A1A12);
  static const Color bgLight   = Color(0xFF7A2A1C);
  static const Color gold      = Color(0xFFF1C40F);
  static const Color goldLight = Color(0xFFF0E0C0);
  static const Color goldDim   = Color(0xFFC8B090);
  static const Color crimson   = Color(0xFFC0392B);
  static const Color crimsonDk = Color(0xFF6A1D12);
  static const Color surface   = Color(0xFF2A0E0A);
  static const Color surfaceDm = Color(0xFF1A0806);
  static const Color errorRed  = Color(0xFFFF6B5A);
  static const Color badgeOff  = Color(0xFFA08870);
}

class AppTheme {
  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    fontFamily: 'Cairo',
    scaffoldBackgroundColor: AppColors.bgDeep,
    colorScheme: const ColorScheme.dark(
      primary:    AppColors.crimson,
      secondary:  AppColors.gold,
      surface:    AppColors.surface,
      onSurface:  AppColors.goldLight,
      error:      AppColors.crimson,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(color: AppColors.gold,      fontWeight: FontWeight.w800, letterSpacing: 2),
      titleLarge:   TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.w700, letterSpacing: 1.5),
      titleMedium:  TextStyle(color: AppColors.goldLight, fontWeight: FontWeight.w600),
      bodyMedium:   TextStyle(color: AppColors.goldLight),
      bodySmall:    TextStyle(color: AppColors.goldDim),
      labelSmall:   TextStyle(color: AppColors.goldDim,   letterSpacing: 1.5, fontSize: 10),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.crimson,
        foregroundColor: Colors.white,
        textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w800, letterSpacing: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        side: const BorderSide(color: AppColors.gold, width: 1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.goldLight,
        side: const BorderSide(color: Color(0x30F1C40F)),
        textStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700, letterSpacing: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF2A1612),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0x30F1C40F)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: Color(0x30F1C40F)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.crimson, width: 2),
      ),
      labelStyle: const TextStyle(color: AppColors.goldDim),
      hintStyle: const TextStyle(color: Color(0x80F0E0C0)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
    ),
  );
}

class AppGradients {
  static const BoxDecoration pageBackground = BoxDecoration(
    gradient: RadialGradient(
      center: Alignment(0, -0.1),
      radius: 1.3,
      colors: [AppColors.bgLight, AppColors.bgMid, AppColors.bgDeep],
      stops: [0.0, 0.55, 0.90],
    ),
  );

  static const LinearGradient primaryButton = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.crimson, AppColors.crimsonDk],
  );

  static const LinearGradient surface = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xF01A0806), Color(0xF00A0403)],
  );
}
