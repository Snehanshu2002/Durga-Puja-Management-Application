import 'package:flutter/material.dart';

class AppColors {
  // ═══════════════════════════════════════════════════════════════════
  // Royal Indigo & Golden Amber Palette — Modern, Soothing, High Contrast
  // ═══════════════════════════════════════════════════════════════════

  // Primary / Brand — Royal Indigo
  static const Color primary = Color(0xFF1E3A8A); // Deep Royal Indigo Blue
  static const Color primaryLight = Color(0xFF2563EB); // Bright Indigo
  static const Color primaryDark = Color(0xFF0F172A); // Slate 900 Deep Navy
  static const Color primarySurface = Color(0xFFEFF6FF); // Very light ice-blue tint

  // Secondary — Steel / Sky Blue
  static const Color secondary = Color(0xFF0284C7);
  static const Color secondaryLight = Color(0xFF38BDF8);
  static const Color secondaryDark = Color(0xFF0369A1);

  // Accent — Festive Warm Gold / Amber
  static const Color accent = Color(0xFFD97706); // Warm Amber Gold
  static const Color accentLight = Color(0xFFFBBF24);
  static const Color accentDark = Color(0xFFB45309);
  static const Color accentSurface = Color(0xFFFFFBEB); // Soft cream gold tint

  // Backgrounds — Clean, soothing, non-fatiguing
  static const Color backgroundLight = Color(0xFFF8FAFC); // Slate 50 ultra-clean
  static const Color surfaceLight = Color(0xFFFFFFFF);

  static const Color backgroundDark = Color(0xFF0F172A); // Slate 900
  static const Color surfaceDark = Color(0xFF1E293B); // Slate 800

  // Text
  static const Color textPrimaryLight = Color(0xFF0F172A); // Crisp Slate 900
  static const Color textSecondaryLight = Color(0xFF64748B); // Slate 500

  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Semantic
  static const Color success = Color(0xFF059669); // Emerald Green
  static const Color successLight = Color(0xFFECFDF5);
  static const Color expense = Color(0xFFDC2626); // Clean red for expenses
  static const Color expenseLight = Color(0xFFFEF2F2);
  static const Color error = Color(0xFFDC2626);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningLight = Color(0xFFFFFBEB);

  // UI Elements
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderDark = Color(0xFF334155);
  static const Color divider = Color(0xFFF1F5F9);

  // Role Badge Colors (soft/pastel modern tones)
  static const Color roleSuperAdmin = Color(0xFF6366F1); // Indigo
  static const Color rolePresident = Color(0xFFD97706);   // Warm Gold
  static const Color roleTreasurer = Color(0xFF059669);   // Emerald
  static const Color roleManager = Color(0xFF2563EB);     // Royal Blue
  static const Color roleCollector = Color(0xFF0D9488);   // Teal
  static const Color roleViewer = Color(0xFF64748B);      // Slate

  // Navigation
  static const Color navBackground = Color(0xFFFFFFFF);
  static const Color navSelected = Color(0xFF1E3A8A);
  static const Color navIndicator = Color(0xFFDBEAFE); // Soft blue pill
  static const Color navUnselected = Color(0xFF64748B);
}
