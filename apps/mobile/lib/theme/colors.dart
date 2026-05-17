import 'package:flutter/material.dart';

class BazzColors {
  static const Color primary = Color(0xFF1A3C6E);
  static const Color accent = Color(0xFFFFD700);
  // Spec: Surface background #F5F7FA
  static const Color surface = Color(0xFFF5F7FA);
  static const Color cardBg = Color(0xFFFFFFFF);
  static const Color success = Color(0xFF2ECC71);
  static const Color error = Color(0xFFE53935);
  static const Color warning = Color(0xFFF59E0B);
  static const Color divider = Color(0xFFE2E8F0);
  static const Color textPrimary = Color(0xFF1A202C);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textHint = Color(0xFF94A3B8);

  // Status badge colors — per spec exactly:
  // In Delivery  → bg #FFD700 (golden), text #1A3C6E (navy)
  // Processing   → bg #1A3C6E (navy),   text #FFFFFF
  // Pending      → bg #F3F4F6 (gray),   text #6B7280
  // Delivered    → bg #2ECC71 (green),  text #FFFFFF
  // Cancelled    → bg #E53935 (red),    text #FFFFFF
  static const Color inDeliveryBg = Color(0xFFFFD700);
  static const Color inDeliveryText = Color(0xFF1A3C6E);
  static const Color processingBg = Color(0xFF1A3C6E);
  static const Color processingText = Color(0xFFFFFFFF);
  static const Color pendingBg = Color(0xFFF3F4F6);
  static const Color pendingText = Color(0xFF6B7280);
  static const Color deliveredBg = Color(0xFF2ECC71);
  static const Color deliveredText = Color(0xFFFFFFFF);
  static const Color cancelledBg = Color(0xFFE53935);
  static const Color cancelledText = Color(0xFFFFFFFF);
}