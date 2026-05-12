import 'package:flutter/material.dart';

/// Curated marketplace color palette — dark-mode-first with teal/emerald accents.
class AppColors {
  AppColors._();

  // ── Brand Accent ──────────────────────────────────────────────
  static const Color primary = Color(0xFF00C9A7);       // Teal-green
  static const Color primaryLight = Color(0xFF5EEAD4);   // Light teal
  static const Color primaryDark = Color(0xFF0D9488);    // Dark teal
  static const Color accent = Color(0xFFFBBF24);         // Warm amber

  // ── Surfaces ──────────────────────────────────────────────────
  static const Color scaffoldDark = Color(0xFF0F172A);   // Deep navy
  static const Color cardDark = Color(0xFF1E293B);       // Elevated card
  static const Color surfaceDark = Color(0xFF334155);    // Secondary surface
  static const Color inputDark = Color(0xFF1E293B);      // Input background

  // ── Text ──────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFFF1F5F9);    // Almost white
  static const Color textSecondary = Color(0xFF94A3B8);   // Muted slate
  static const Color textTertiary = Color(0xFF64748B);    // Subtle hint
  static const Color textOnPrimary = Color(0xFF0F172A);   // On teal buttons

  // ── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // ── Misc ──────────────────────────────────────────────────────
  static const Color divider = Color(0xFF334155);
  static const Color shimmer = Color(0xFF475569);
  static const Color priceBadge = Color(0xFF10B981);
  static const Color soldBadge = Color(0xFFEF4444);

  // ── Gradients ─────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00C9A7), Color(0xFF0EA5E9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B), Color(0xFF0F172A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
