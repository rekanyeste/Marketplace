import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Typography tokens using Titillium Web font family.
class AppTextStyles {
  AppTextStyles._();

  // ── Headings ──────────────────────────────────────────────────
  static TextStyle h1 = GoogleFonts.titilliumWeb(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static TextStyle h2 = GoogleFonts.titilliumWeb(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  static TextStyle h3 = GoogleFonts.titilliumWeb(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Body ──────────────────────────────────────────────────────
  static TextStyle bodyLarge = GoogleFonts.titilliumWeb(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static TextStyle bodyMedium = GoogleFonts.titilliumWeb(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.5,
  );

  static TextStyle bodySmall = GoogleFonts.titilliumWeb(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
  );

  // ── Labels & Buttons ─────────────────────────────────────────
  static TextStyle button = GoogleFonts.titilliumWeb(
    fontSize: 15,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.5,
  );

  static TextStyle label = GoogleFonts.titilliumWeb(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  static TextStyle caption = GoogleFonts.titilliumWeb(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    letterSpacing: 0.2,
  );

  // ── Price ─────────────────────────────────────────────────────
  static TextStyle priceLarge = GoogleFonts.titilliumWeb(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: AppColors.priceBadge,
  );

  static TextStyle priceSmall = GoogleFonts.titilliumWeb(
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: AppColors.priceBadge,
  );

  // ── Chip ──────────────────────────────────────────────────────
  static TextStyle chip = GoogleFonts.titilliumWeb(
    fontSize: 13,
    fontWeight: FontWeight.w600,
  );
}
