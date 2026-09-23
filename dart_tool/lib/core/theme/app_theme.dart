import 'package:flutter/material.dart';

abstract final class AppColors {
  // Teammate Exact CSS Design Tokens
  static const blue = Color(0xFF1248BF);       // --blue
  static const blue2 = Color(0xFF2464DF);      // --blue2
  static const ink = Color(0xFF102653);        // --ink
  static const sky = Color(0xFFE9F1FF);        // --sky
  static const muted = Color(0xFF64738F);      // --muted
  static const line = Color(0xFFDBE5F6);       // --line
  static const surface = Color(0xFFFFFFFF);    // --white
  static const ivory = Color(0xFFF5F8FF);      // body canvas
  static const green = Color(0xFF20775B);      // --green
  static const orange = Color(0xFFB96016);     // --orange
  static const danger = Color(0xFFD94652);     // danger / mic active

  // Gradients
  static const heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF082E92), Color(0xFF1558D0), Color(0xFF83B5FF)],
  );

  static const dashboardGradient = LinearGradient(
    begin: Alignment(-0.8, -0.6),
    end: Alignment(0.9, 0.7),
    colors: [Color(0xFF103FAB), Color(0xFF2667DE), Color(0xFF6A9BFA)],
  );

  static const emergencyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFA3253D), Color(0xFFDB5465)],
  );

  // Shadows
  static const shadowElevation = [
    BoxShadow(
      color: Color(0x1F17438F),
      blurRadius: 35,
      offset: Offset(0, 14),
    ),
  ];

  static const cardShadow = [
    BoxShadow(
      color: Color(0x0A1A448D),
      blurRadius: 14,
      offset: Offset(0, 4),
    ),
  ];

  // Backward compatibility aliases
  static const background = ivory;
  static const white = surface;
  static const teal = blue;
  static const tealDark = ink;
  static const sage = sky;
  static const charcoal = ink;
  static const amber = orange;
  static const success = green;
  static const error = danger;
  static const offline = blue;
}

abstract final class AppSpace {
  static const xSmall = 8.0;
  static const small = 12.0;
  static const medium = 16.0;
  static const large = 24.0;
  static const xLarge = 32.0;
}

abstract final class AppFonts {
  static const heading = 'Fraunces';
  static const headingFallback = ['serif'];
  static const body = 'DM Sans';
  static const bodyFallback = ['sans-serif'];
}

ThemeData buildSmritiTheme({bool isLargeText = false}) {
  final double scale = isLargeText ? 1.125 : 1.0;

  final scheme = ColorScheme.fromSeed(
    seedColor: AppColors.blue,
    brightness: Brightness.light,
    surface: AppColors.surface,
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: AppFonts.body,
    fontFamilyFallback: AppFonts.bodyFallback,
    colorScheme: scheme.copyWith(
      primary: AppColors.blue,
      onPrimary: Colors.white,
      surface: AppColors.surface,
    ),
    scaffoldBackgroundColor: AppColors.ivory,
    textTheme: TextTheme(
      displaySmall: TextStyle(
        fontFamily: AppFonts.heading,
        fontFamilyFallback: AppFonts.headingFallback,
        fontSize: 34 * scale,
        height: 1.1,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFonts.heading,
        fontFamilyFallback: AppFonts.headingFallback,
        fontSize: 27 * scale,
        height: 1.15,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleLarge: TextStyle(
        fontFamily: AppFonts.heading,
        fontFamilyFallback: AppFonts.headingFallback,
        fontSize: 21 * scale,
        height: 1.2,
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.body,
        fontFamilyFallback: AppFonts.bodyFallback,
        fontSize: 17 * scale,
        height: 1.3,
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppFonts.body,
        fontFamilyFallback: AppFonts.bodyFallback,
        fontSize: 16 * scale,
        height: 1.5,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.body,
        fontFamilyFallback: AppFonts.bodyFallback,
        fontSize: 14 * scale,
        height: 1.45,
        color: AppColors.muted,
      ),
      labelLarge: TextStyle(
        fontFamily: AppFonts.body,
        fontFamilyFallback: AppFonts.bodyFallback,
        fontSize: 16 * scale,
        height: 1.2,
        fontWeight: FontWeight.w700,
      ),
    ),
    dividerColor: AppColors.line,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.surface,
      foregroundColor: AppColors.ink,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surface,
      indicatorColor: AppColors.sky,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.muted,
        ),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.blue,
        foregroundColor: Colors.white,
        minimumSize: const Size(64, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    ),
  );
}

