import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette
  static const Color navyDeep = Color(0xFF0D1B2A);
  static const Color navyMid = Color(0xFF1A2D42);
  static const Color navyLight = Color(0xFF243B55);
  static const Color navySurface = Color(0xFF1E3048);

  // Accent - Emerald
  static const Color emerald = Color(0xFF10B981);
  static const Color emeraldLight = Color(0xFF34D399);
  static const Color emeraldDark = Color(0xFF059669);
  static const Color emeraldGlow = Color(0x2010B981);

  // Accent - Orange
  static const Color orange = Color(0xFFF97316);
  static const Color orangeLight = Color(0xFFFB923C);
  static const Color orangeDark = Color(0xFFEA580C);
  static const Color orangeGlow = Color(0x20F97316);

  // Neutral
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF8FAFC);
  static const Color textPrimary = Color(0xFFF1F5F9);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  // Card / Surface
  static const Color cardSurface = Color(0xFF1A2D42);
  static const Color cardBorder = Color(0xFF243B55);
  static const Color glassSurface = Color(0x1AFFFFFF);
  static const Color glassBorder = Color(0x33FFFFFF);

  // Semantic
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Prayer Colors
  static const Color prayerSubuh = Color(0xFF6366F1);
  static const Color prayerDzuhur = Color(0xFFF59E0B);
  static const Color prayerAshar = Color(0xFF10B981);
  static const Color prayerMaghrib = Color(0xFFF97316);
  static const Color prayerIsya = Color(0xFF8B5CF6);

  // Habit Grid
  static const Color habitEmpty = Color(0xFF243B55);
  static const Color habitLow = Color(0xFF1B4332);
  static const Color habitMid = Color(0xFF166534);
  static const Color habitHigh = Color(0xFF15803D);
  static const Color habitFull = Color(0xFF10B981);

  // Gradient presets
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDeep, navyMid],
  );

  static const LinearGradient emeraldGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [emerald, emeraldDark],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange, orangeDark],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyMid, navyLight],
  );
}
